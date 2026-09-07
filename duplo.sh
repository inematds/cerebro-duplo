#!/usr/bin/env bash
# duplo.sh — um cérebro, dois agentes.
#
# CLI do cerebro-duplo: verifica e sincroniza a paridade entre Claude Code e
# Codex dentro de um segundo cérebro (kit astra-2cerebro), abre o agente certo
# com o perfil certo e registra uso por sessão.
#
# Uso: duplo.sh [--dir <cerebro>] <comando> [args]
# Rode `duplo.sh ajuda` para a lista completa.
#
# Sem dependências além de bash, coreutils, diff e awk.

set -euo pipefail

DUPLO_VERSAO="1.0.0"

# ---------------------------------------------------------------------------
# Localização dos arquivos do próprio cerebro-duplo
# ---------------------------------------------------------------------------
# O script pode estar no repo (./duplo.sh, com ./perfis e ./modelos ao lado) ou
# instalado dentro do cérebro (<cerebro>/scripts/duplo.sh, com
# <cerebro>/scripts/perfis e <cerebro>/scripts/modelos). Os dois layouts funcionam.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

achar_pasta() {
  # $1 = nome da pasta (perfis | modelos). Devolve o primeiro caminho existente.
  local nome="$1"
  for base in "$SCRIPT_DIR" "$SCRIPT_DIR/.." "${DUPLO_HOME:-}"; do
    [ -n "$base" ] && [ -d "$base/$nome" ] && { echo "$base/$nome"; return 0; }
  done
  return 1
}

# ---------------------------------------------------------------------------
# Saída
# ---------------------------------------------------------------------------
PROBLEMAS=0
AVISOS=0

problema() { PROBLEMAS=$((PROBLEMAS + 1)); echo "PROBLEMA: $*"; }
aviso()    { AVISOS=$((AVISOS + 1));       echo "AVISO: $*"; }
ok()       { echo "OK: $*"; }
erro()     { echo "ERRO: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Argumentos globais
# ---------------------------------------------------------------------------
DIR="$PWD"
SO_MOSTRAR=0
FONTE="agents"
ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --dir)        [ $# -ge 2 ] || erro "--dir precisa de um caminho"; DIR="$2"; shift 2 ;;
    --dir=*)      DIR="${1#--dir=}"; shift ;;
    --so-mostrar) SO_MOSTRAR=1; shift ;;
    --fonte)      [ $# -ge 2 ] || erro "--fonte precisa de agents|claude"; FONTE="$2"; shift 2 ;;
    --fonte=*)    FONTE="${1#--fonte=}"; shift ;;
    -h|--help)    ARGS=(ajuda); shift ;;
    *)            ARGS+=("$1"); shift ;;
  esac
done

COMANDO="${ARGS[0]:-ajuda}"
[ ${#ARGS[@]} -gt 0 ] && ARGS=("${ARGS[@]:1}")

DIR="${DIR%/}"
[ -d "$DIR" ] || erro "pasta do cérebro não existe: $DIR"
DIR="$(cd "$DIR" && pwd)"

# ---------------------------------------------------------------------------
# ajuda
# ---------------------------------------------------------------------------
cmd_ajuda() {
  cat <<'EOF'
duplo.sh — um cérebro, dois agentes (Claude Code + Codex)

Uso: duplo.sh [--dir <cerebro>] <comando> [args]
     --dir é opcional; o padrão é a pasta atual.

Comandos
  verificar                    Confere a paridade do cérebro:
                               - AGENTS.md e CLAUDE.md existem e são idênticos (mostra o diff)
                               - cada skill de .claude/skills tem cópia idêntica em .agents/skills
                                 e vice-versa (ignora node_modules)
                               - cada skill tem SKILL.md e agents/openai.yaml
                               - rotas do manual que apontam para caminho inexistente (AVISO)
                               Sai com código 1 se houver PROBLEMA. Avisos não mudam o código.

  sync [--fonte agents|claude] Torna as cópias idênticas:
                               - manual: CLAUDE.md a partir de AGENTS.md (padrão) ou o inverso
                               - skills: .claude/skills -> .agents/skills (canônico é .claude)
                               Nunca apaga skill que existe só no espelho; avisa.

  claude [perfil] [--so-mostrar]
  codex  [perfil] [--so-mostrar]
                               Abre o agente dentro do cérebro com modelo e esforço do perfil
                               (perfis/<perfil>.env; padrão: padrao). Imprime o comando antes
                               de executar. Com --so-mostrar só imprime.

  uso registrar <agente> <perfil> <minutos> "<tarefa>"
                               Acrescenta uma linha em <cerebro>/registro-uso.md
                               (cria a partir do template modelos/registro-uso.md).
  uso resumo                   Resume sessões e minutos por agente e por agente+perfil.

  perfis                       Lista os perfis disponíveis.
  versao                       Mostra a versão.
  ajuda                        Esta mensagem.

Exemplos
  duplo.sh --dir ~/meu-cerebro verificar
  duplo.sh --dir ~/meu-cerebro sync --fonte claude
  duplo.sh --dir ~/meu-cerebro claude raciocinio
  duplo.sh --dir ~/meu-cerebro codex rotina --so-mostrar
  duplo.sh --dir ~/meu-cerebro uso registrar codex rotina 12 "resumo da reunião de segunda"
  duplo.sh --dir ~/meu-cerebro uso resumo
EOF
}

# ---------------------------------------------------------------------------
# verificar
# ---------------------------------------------------------------------------
verificar_manual() {
  local a="$DIR/AGENTS.md" c="$DIR/CLAUDE.md"
  local falta=0
  [ -f "$a" ] || { problema "AGENTS.md não existe em $DIR"; falta=1; }
  [ -f "$c" ] || { problema "CLAUDE.md não existe em $DIR"; falta=1; }
  [ "$falta" -eq 1 ] && return 0
  if cmp -s "$a" "$c"; then
    ok "AGENTS.md e CLAUDE.md são idênticos"
  else
    problema "AGENTS.md e CLAUDE.md divergem (diff abaixo, AGENTS.md à esquerda)"
    diff -u "$a" "$c" | head -60 | sed 's/^/    /' || true
    echo "    conserto: duplo.sh --dir \"$DIR\" sync --fonte agents   (ou --fonte claude)"
  fi
}

verificar_skill_pasta() {
  # $1 = pasta da skill; confere SKILL.md e agents/openai.yaml
  local pasta="$1" rel="${1#$DIR/}"
  [ -f "$pasta/SKILL.md" ]          || problema "$rel não tem SKILL.md"
  [ -f "$pasta/agents/openai.yaml" ] || problema "$rel não tem agents/openai.yaml (o Codex precisa dele)"
}

verificar_skills() {
  local origem="$DIR/.claude/skills" espelho="$DIR/.agents/skills"
  local nome
  if [ ! -d "$origem" ] && [ ! -d "$espelho" ]; then
    aviso "nenhuma pasta de skills (.claude/skills nem .agents/skills)"
    return 0
  fi
  [ -d "$origem" ]  || problema ".claude/skills não existe (o Claude Code não verá skill nenhuma)"
  [ -d "$espelho" ] || problema ".agents/skills não existe (o Codex não verá skill nenhuma)"

  local total=0 iguais=0
  if [ -d "$origem" ]; then
    for d in "$origem"/*/; do
      [ -d "$d" ] || continue
      nome="$(basename "$d")"
      total=$((total + 1))
      verificar_skill_pasta "$origem/$nome"
      if [ ! -d "$espelho/$nome" ]; then
        problema "skill '$nome' existe em .claude/skills mas não em .agents/skills"
        continue
      fi
      verificar_skill_pasta "$espelho/$nome"
      if diff -rq --exclude=node_modules "$origem/$nome" "$espelho/$nome" >/dev/null 2>&1; then
        iguais=$((iguais + 1))
      else
        problema "skill '$nome' difere entre .claude/skills e .agents/skills:"
        diff -rq --exclude=node_modules "$origem/$nome" "$espelho/$nome" 2>&1 | sed 's/^/    /' || true
      fi
    done
  fi
  if [ -d "$espelho" ]; then
    for d in "$espelho"/*/; do
      [ -d "$d" ] || continue
      nome="$(basename "$d")"
      if [ ! -d "$origem/$nome" ]; then
        problema "skill '$nome' existe só no espelho .agents/skills (sem origem em .claude/skills). Copie para .claude/skills ou mova para arquivo/."
      fi
    done
  fi
  [ "$total" -gt 0 ] && [ "$iguais" -eq "$total" ] && ok "$total skills idênticas nos dois lados"
  return 0
}

verificar_rotas() {
  # Extrai caminhos entre crases do manual e confere se existem.
  # Ignora placeholders (<...>, {{...}}, *) e nomes sem cara de caminho.
  local manual="$DIR/AGENTS.md"
  [ -f "$manual" ] || manual="$DIR/CLAUDE.md"
  [ -f "$manual" ] || return 0
  local quebradas=0 checadas=0 rota
  while IFS= read -r rota; do
    [ -n "$rota" ] || continue
    case "$rota" in
      *'<'*|*'{{'*|*'*'*|/*|~*|http*) continue ;;
    esac
    checadas=$((checadas + 1))
    if [ ! -e "$DIR/$rota" ]; then
      quebradas=$((quebradas + 1))
      aviso "rota do manual aponta para caminho inexistente: $rota"
    fi
  done < <(grep -o '`[^`]*`' "$manual" | tr -d '`' \
           | grep -E '^[A-Za-z0-9_][A-Za-z0-9_./-]*(\.md|\.json|\.yaml|\.toml|\.sh|/)$' \
           | sort -u)
  if [ "$quebradas" -eq 0 ]; then
    ok "$checadas rotas do manual apontam para caminhos existentes"
  else
    echo "    (rotas quebradas são AVISO: o /iniciar cria vários desses arquivos depois; use /vincular para corrigir as demais)"
  fi
}

cmd_verificar() {
  echo "== cerebro-duplo verificar — $DIR"
  verificar_manual
  verificar_skills
  verificar_rotas
  echo "== resultado: $PROBLEMAS problema(s), $AVISOS aviso(s)"
  [ "$PROBLEMAS" -eq 0 ]
}

# ---------------------------------------------------------------------------
# sync
# ---------------------------------------------------------------------------
cmd_sync() {
  local a="$DIR/AGENTS.md" c="$DIR/CLAUDE.md"
  case "$FONTE" in
    agents) [ -f "$a" ] || erro "AGENTS.md não existe; use --fonte claude"
            if cmp -s "$a" "$c" 2>/dev/null; then echo "manual: já idêntico"; else cp "$a" "$c"; echo "manual: CLAUDE.md gravado a partir de AGENTS.md"; fi ;;
    claude) [ -f "$c" ] || erro "CLAUDE.md não existe; use --fonte agents"
            if cmp -s "$a" "$c" 2>/dev/null; then echo "manual: já idêntico"; else cp "$c" "$a"; echo "manual: AGENTS.md gravado a partir de CLAUDE.md"; fi ;;
    *) erro "--fonte deve ser agents ou claude (recebi: $FONTE)" ;;
  esac

  local origem="$DIR/.claude/skills" espelho="$DIR/.agents/skills"
  if [ ! -d "$origem" ]; then
    aviso ".claude/skills não existe; nada para sincronizar (o canônico é .claude/skills)"
    return 0
  fi
  mkdir -p "$espelho"
  local total=0 nome
  for d in "$origem"/*/; do
    [ -d "$d" ] || continue
    nome="$(basename "$d")"
    if diff -rq --exclude=node_modules "$origem/$nome" "$espelho/$nome" >/dev/null 2>&1; then
      continue
    fi
    rm -rf "$espelho/$nome"
    cp -R "$origem/$nome" "$espelho/$nome"
    rm -rf "$espelho/$nome/node_modules"
    total=$((total + 1))
  done
  echo "skills: $total sincronizada(s) .claude/skills -> .agents/skills"
  for d in "$espelho"/*/; do
    [ -d "$d" ] || continue
    nome="$(basename "$d")"
    [ -d "$origem/$nome" ] || aviso "skill '$nome' existe só em .agents/skills; não apaguei. Se ainda vale, copie para .claude/skills; se foi aposentada, mova para arquivo/."
  done
  return 0
}

# ---------------------------------------------------------------------------
# perfis e abertura dos agentes
# ---------------------------------------------------------------------------
carregar_perfil() {
  local perfil="$1" pasta
  pasta="$(achar_pasta perfis)" || erro "pasta perfis/ não encontrada ao lado de duplo.sh (rode instalar.sh ou defina DUPLO_HOME)"
  local arq="$pasta/$perfil.env"
  [ -f "$arq" ] || erro "perfil '$perfil' não existe. Disponíveis: $(ls "$pasta" | sed 's/\.env$//' | tr '\n' ' ')"
  # shellcheck disable=SC1090
  . "$arq"
  PERFIL_ARQ="$arq"
}

cmd_perfis() {
  local pasta
  pasta="$(achar_pasta perfis)" || erro "pasta perfis/ não encontrada"
  echo "perfis em $pasta:"
  for f in "$pasta"/*.env; do
    [ -f "$f" ] || continue
    ( . "$f"; printf '  %-12s claude: %s/%s   codex: %s/%s   %s\n' "$(basename "${f%.env}")" \
        "${DUPLO_CLAUDE_MODELO:-?}" "${DUPLO_CLAUDE_ESFORCO:-?}" \
        "${DUPLO_CODEX_MODELO:-?}" "${DUPLO_CODEX_ESFORCO:-?}" "${DUPLO_DESCRICAO:-}" )
  done
}

# Imprime uma string shell-escapada com os argumentos recebidos.
mostrar_cmd() { printf '%q ' "$@"; echo; }

cmd_claude() {
  local perfil="${1:-padrao}"
  carregar_perfil "$perfil"
  # Claude Code 2.1.x: --model <alias|nome>, --effort <low|medium|high|xhigh|max>,
  # --name <nome da sessão>. Não há flag de diretório: entra-se na pasta antes.
  local cmd=(claude --model "${DUPLO_CLAUDE_MODELO}" --effort "${DUPLO_CLAUDE_ESFORCO}" --name "duplo:$perfil")
  # shellcheck disable=SC2206
  [ -n "${DUPLO_CLAUDE_EXTRA:-}" ] && cmd+=(${DUPLO_CLAUDE_EXTRA})
  echo "perfil: $perfil ($PERFIL_ARQ)"
  printf 'comando: cd %q && ' "$DIR"; mostrar_cmd "${cmd[@]}"
  [ "$SO_MOSTRAR" -eq 1 ] && return 0
  command -v claude >/dev/null 2>&1 || erro "claude não está no PATH"
  cd "$DIR" && exec "${cmd[@]}"
}

cmd_codex() {
  local perfil="${1:-padrao}"
  carregar_perfil "$perfil"
  # Codex CLI 0.153.x: -C <dir> define a raiz de trabalho, -m <modelo>,
  # -c chave=valor sobrescreve o config.toml (valor em TOML, por isso as aspas).
  local cmd=(codex -C "$DIR" -m "${DUPLO_CODEX_MODELO}" -c "model_reasoning_effort=\"${DUPLO_CODEX_ESFORCO}\"")
  # shellcheck disable=SC2206
  [ -n "${DUPLO_CODEX_EXTRA:-}" ] && cmd+=(${DUPLO_CODEX_EXTRA})
  echo "perfil: $perfil ($PERFIL_ARQ)"
  printf 'comando: '; mostrar_cmd "${cmd[@]}"
  [ "$SO_MOSTRAR" -eq 1 ] && return 0
  command -v codex >/dev/null 2>&1 || erro "codex não está no PATH"
  exec "${cmd[@]}"
}

# ---------------------------------------------------------------------------
# uso
# ---------------------------------------------------------------------------
REGISTRO="$DIR/registro-uso.md"

template_registro() {
  local pasta
  if pasta="$(achar_pasta modelos)" && [ -f "$pasta/registro-uso.md" ]; then
    cat "$pasta/registro-uso.md"
    return 0
  fi
  cat <<'EOF'
# Registro de uso — cerebro-duplo

Uma linha por sessão. Preenchido por `duplo.sh uso registrar` (ou à mão).
Custo em dinheiro não fica aqui: consulte a tabela do provedor e o painel da conta.
`duplo.sh uso resumo` soma sessões e minutos por agente e por perfil.

| Data e hora | Agente | Perfil | Modelo | Esforço | Minutos | Tarefa |
|---|---|---|---|---|---|---|
EOF
}

cmd_uso() {
  local sub="${1:-}"
  case "$sub" in
    registrar)
      local agente="${2:-}" perfil="${3:-}" minutos="${4:-}" tarefa="${5:-}"
      case "$agente" in claude|codex) ;; *) erro "agente deve ser claude ou codex (recebi: '$agente')" ;; esac
      [ -n "$perfil" ] || erro "informe o perfil"
      [[ "$minutos" =~ ^[0-9]+$ ]] || erro "minutos deve ser inteiro (recebi: '$minutos')"
      [ -n "$tarefa" ] || erro "informe a tarefa entre aspas"
      local modelo="-" esforco="-"
      if pasta="$(achar_pasta perfis)" && [ -f "$pasta/$perfil.env" ]; then
        ( . "$pasta/$perfil.env"
          if [ "$agente" = claude ]; then echo "${DUPLO_CLAUDE_MODELO:-?} ${DUPLO_CLAUDE_ESFORCO:-?}"; else echo "${DUPLO_CODEX_MODELO:-?} ${DUPLO_CODEX_ESFORCO:-?}"; fi ) > "$DIR/.duplo-tmp"
        read -r modelo esforco < "$DIR/.duplo-tmp"; rm -f "$DIR/.duplo-tmp"
      fi
      [ -f "$REGISTRO" ] || { template_registro > "$REGISTRO"; echo "criado: $REGISTRO"; }
      tarefa="${tarefa//|/\\|}"
      printf '| %s | %s | %s | %s | %s | %s | %s |\n' "$(date '+%Y-%m-%d %H:%M')" "$agente" "$perfil" "$modelo" "$esforco" "$minutos" "$tarefa" >> "$REGISTRO"
      echo "registrado: $agente/$perfil $minutos min — $tarefa"
      ;;
    resumo)
      [ -f "$REGISTRO" ] || erro "não há $REGISTRO ainda; registre uma sessão primeiro"
      echo "== resumo de uso — $REGISTRO"
      awk -F'|' '
        /^\| *[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
          ag=$3; pf=$4; min=$7
          gsub(/^ +| +$/, "", ag); gsub(/^ +| +$/, "", pf); gsub(/^ +| +$/, "", min)
          if (min !~ /^[0-9]+$/) next
          sa[ag]++; ma[ag]+=min
          k=ag "|" pf; sp[k]++; mp[k]+=min
          st++; mt+=min
        }
        END {
          if (st == 0) { print "nenhuma sessão registrada"; exit }
          print ""
          print "| Agente | Sessões | Minutos |"; print "|---|---|---|"
          n=asorti(sa, ka); for (i=1;i<=n;i++) { a=ka[i]; printf "| %s | %d | %d |\n", a, sa[a], ma[a] }
          print ""
          print "| Agente | Perfil | Sessões | Minutos |"; print "|---|---|---|---|"
          n=asorti(sp, kp); for (i=1;i<=n;i++) { k=kp[i]; split(k, p, "|"); printf "| %s | %s | %d | %d |\n", p[1], p[2], sp[k], mp[k] }
          print ""
          printf "total: %d sessões, %d minutos\n", st, mt
        }' "$REGISTRO" 2>/dev/null || cmd_uso_resumo_portavel
      ;;
    *) erro "uso: subcomando deve ser 'registrar' ou 'resumo'" ;;
  esac
}

# Fallback sem asorti (awk que não é gawk).
cmd_uso_resumo_portavel() {
  awk -F'|' '
    /^\| *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/ {
      ag=$3; pf=$4; min=$7
      gsub(/^ +| +$/, "", ag); gsub(/^ +| +$/, "", pf); gsub(/^ +| +$/, "", min)
      if (min !~ /^[0-9]+$/) next
      sa[ag]++; ma[ag]+=min; k=ag "|" pf; sp[k]++; mp[k]+=min; st++; mt+=min
    }
    END {
      if (st == 0) { print "nenhuma sessão registrada"; exit }
      print ""; print "| Agente | Sessões | Minutos |"; print "|---|---|---|"
      for (a in sa) printf "| %s | %d | %d |\n", a, sa[a], ma[a]
      print ""; print "| Agente | Perfil | Sessões | Minutos |"; print "|---|---|---|---|"
      for (k in sp) { split(k, p, "|"); printf "| %s | %s | %d | %d |\n", p[1], p[2], sp[k], mp[k] }
      print ""; printf "total: %d sessões, %d minutos\n", st, mt
    }' "$REGISTRO"
}

# ---------------------------------------------------------------------------
# despacho
# ---------------------------------------------------------------------------
case "$COMANDO" in
  verificar) cmd_verificar ;;
  sync)      cmd_sync ;;
  claude)    cmd_claude "${ARGS[@]:-}" ;;
  codex)     cmd_codex "${ARGS[@]:-}" ;;
  uso)       cmd_uso "${ARGS[@]:-}" ;;
  perfis)    cmd_perfis ;;
  versao|--version|-v) echo "cerebro-duplo $DUPLO_VERSAO" ;;
  ajuda|help) cmd_ajuda ;;
  *) echo "comando desconhecido: $COMANDO" >&2; cmd_ajuda >&2; exit 1 ;;
esac
