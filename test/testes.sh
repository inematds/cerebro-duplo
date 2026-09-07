#!/usr/bin/env bash
# Testes do cerebro-duplo. Rodam duplo.sh contra test/fixture (um cérebro pequeno
# do kit astra-2cerebro) e contra cópias temporárias que são quebradas de propósito.
#
# Uso: bash test/testes.sh
# Sai com 1 se algum teste falhar. Nunca toca em test/fixture.

set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DUPLO="$RAIZ/duplo.sh"
FIXTURE="$RAIZ/test/fixture"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/cerebro-duplo-teste.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

PASSOU=0; FALHOU=0
passa() { PASSOU=$((PASSOU + 1)); echo "PASS: $1"; }
falha() { FALHOU=$((FALHOU + 1)); echo "FAIL: $1"; [ -n "${2:-}" ] && printf '%s\n' "$2" | sed 's/^/      /'; }

# assert <nome> <codigo-esperado> <codigo-obtido> <saida> [padrão-que-deve-aparecer]
assert() {
  local nome="$1" esp="$2" obt="$3" saida="$4" padrao="${5:-}"
  if [ "$esp" != "$obt" ]; then falha "$nome (código esperado $esp, obtido $obt)" "$saida"; return; fi
  if [ -n "$padrao" ] && ! grep -qE -- "$padrao" <<<"$saida"; then falha "$nome (saída sem '$padrao')" "$saida"; return; fi
  passa "$nome"
}

copiar_fixture() { rm -rf "$1"; cp -R "$FIXTURE" "$1"; }

echo "== cerebro-duplo testes — fixture: $FIXTURE"

# 1. verificar passa na fixture íntegra
saida="$(bash "$DUPLO" --dir "$FIXTURE" verificar 2>&1)"; cod=$?
assert "verificar passa na fixture íntegra" 0 "$cod" "$saida" "0 problema"

# 2. quebra o manual: verificar falha com código 1 e mostra o diff
C="$TMP/manual"; copiar_fixture "$C"
echo "- linha só no CLAUDE.md" >> "$C/CLAUDE.md"
saida="$(bash "$DUPLO" --dir "$C" verificar 2>&1)"; cod=$?
assert "verificar falha quando AGENTS.md e CLAUDE.md divergem" 1 "$cod" "$saida" "divergem"
assert "verificar mostra o diff do manual" 1 "$cod" "$saida" "linha só no CLAUDE.md"

# 3. sync (fonte agents) conserta o manual e verificar volta a passar
saida="$(bash "$DUPLO" --dir "$C" sync 2>&1)"; cod=$?
assert "sync conserta o manual a partir de AGENTS.md" 0 "$cod" "$saida" "CLAUDE.md gravado"
saida="$(bash "$DUPLO" --dir "$C" verificar 2>&1)"; cod=$?
assert "verificar passa depois do sync do manual" 0 "$cod" "$saida" "0 problema"

# 4. sync --fonte claude leva a edição de CLAUDE.md para AGENTS.md
echo "- rota nova no CLAUDE.md" >> "$C/CLAUDE.md"
bash "$DUPLO" --dir "$C" sync --fonte claude >/dev/null 2>&1
if grep -q "rota nova no CLAUDE.md" "$C/AGENTS.md"; then passa "sync --fonte claude copia CLAUDE.md para AGENTS.md"; else falha "sync --fonte claude copia CLAUDE.md para AGENTS.md"; fi

# 5. quebra as skills: edição no espelho + openai.yaml removido + skill sem cópia
S="$TMP/skills"; copiar_fixture "$S"
echo "edição perdida no espelho" >> "$S/.agents/skills/rotina/SKILL.md"
rm -f "$S/.agents/skills/wiki/agents/openai.yaml"
rm -rf "$S/.agents/skills/vincular"
saida="$(bash "$DUPLO" --dir "$S" verificar 2>&1)"; cod=$?
assert "verificar falha quando skill difere no espelho" 1 "$cod" "$saida" "skill 'rotina' difere"
assert "verificar acusa openai.yaml faltando" 1 "$cod" "$saida" "wiki não tem agents/openai.yaml"
assert "verificar acusa skill sem cópia no espelho" 1 "$cod" "$saida" "skill 'vincular' existe em .claude/skills mas não"

# 6. sync conserta as skills e verificar volta a passar
saida="$(bash "$DUPLO" --dir "$S" sync 2>&1)"; cod=$?
assert "sync sincroniza as skills quebradas" 0 "$cod" "$saida" "3 sincronizada"
saida="$(bash "$DUPLO" --dir "$S" verificar 2>&1)"; cod=$?
assert "verificar passa depois do sync das skills" 0 "$cod" "$saida" "8 skills idênticas"

# 7. skill só no espelho: verificar acusa, sync avisa e não apaga
mkdir -p "$S/.agents/skills/orfa"; echo "---" > "$S/.agents/skills/orfa/SKILL.md"
saida="$(bash "$DUPLO" --dir "$S" verificar 2>&1)"; cod=$?
assert "verificar acusa skill só no espelho" 1 "$cod" "$saida" "skill 'orfa' existe só no espelho"
saida="$(bash "$DUPLO" --dir "$S" sync 2>&1)"; cod=$?
assert "sync avisa sobre skill só no espelho" 0 "$cod" "$saida" "AVISO: skill 'orfa'"
if [ -d "$S/.agents/skills/orfa" ]; then passa "sync não apaga skill só no espelho"; else falha "sync não apaga skill só no espelho"; fi

# 8. openai.yaml faltando no canônico também é problema (o sync propaga a falta)
rm -rf "$S/.agents/skills/orfa"
rm -f "$S/.claude/skills/evoluir/agents/openai.yaml"
bash "$DUPLO" --dir "$S" sync >/dev/null 2>&1
saida="$(bash "$DUPLO" --dir "$S" verificar 2>&1)"; cod=$?
assert "verificar acusa openai.yaml faltando no canônico" 1 "$cod" "$saida" "evoluir não tem agents/openai.yaml"

# 9. rota quebrada é aviso, não problema
R="$TMP/rotas"; copiar_fixture "$R"
printf '\n- Coisa nova → `pasta-que-nao-existe/arquivo.md`\n' >> "$R/AGENTS.md"
cp "$R/AGENTS.md" "$R/CLAUDE.md"
saida="$(bash "$DUPLO" --dir "$R" verificar 2>&1)"; cod=$?
assert "rota quebrada gera AVISO sem mudar o código de saída" 0 "$cod" "$saida" "AVISO: rota do manual aponta para caminho inexistente: pasta-que-nao-existe/arquivo.md"

# 10. uso registrar cria o arquivo a partir do template e uso resumo conta certo
U="$TMP/uso"; copiar_fixture "$U"
saida="$(bash "$DUPLO" --dir "$U" uso registrar claude raciocinio 30 "auditoria mensal" 2>&1)"; cod=$?
assert "uso registrar cria registro-uso.md" 0 "$cod" "$saida" "criado: .*registro-uso.md"
if head -1 "$U/registro-uso.md" | grep -q "Registro de uso"; then passa "registro-uso.md vem do template"; else falha "registro-uso.md vem do template"; fi
bash "$DUPLO" --dir "$U" uso registrar claude raciocinio 15 "revisar wiki" >/dev/null 2>&1
bash "$DUPLO" --dir "$U" uso registrar codex rotina 10 "resumo | com pipe" >/dev/null 2>&1
saida="$(bash "$DUPLO" --dir "$U" uso resumo 2>&1)"; cod=$?
assert "uso resumo roda" 0 "$cod" "$saida"
assert "uso resumo soma por agente (claude 2 sessões, 45 min)" 0 "$cod" "$saida" '\| claude \| 2 \| 45 \|'
assert "uso resumo soma por agente+perfil (codex/rotina 1 sessão, 10 min)" 0 "$cod" "$saida" '\| codex \| rotina \| 1 \| 10 \|'
assert "uso resumo total (3 sessões, 55 min)" 0 "$cod" "$saida" "total: 3 sessões, 55 minutos"
if grep -q "| fable | high | 30 |" "$U/registro-uso.md"; then passa "registro copia modelo/esforço do perfil"; else falha "registro copia modelo/esforço do perfil" "$(cat "$U/registro-uso.md")"; fi
saida="$(bash "$DUPLO" --dir "$U" uso registrar gemini rotina 5 "x" 2>&1)"; cod=$?
assert "uso registrar recusa agente desconhecido" 1 "$cod" "$saida" "agente deve ser claude ou codex"
saida="$(bash "$DUPLO" --dir "$U" uso registrar claude rotina cinco "x" 2>&1)"; cod=$?
assert "uso registrar recusa minutos não numéricos" 1 "$cod" "$saida" "minutos deve ser inteiro"

# 11. claude/codex --so-mostrar imprimem comandos plausíveis sem executar
saida="$(bash "$DUPLO" --dir "$FIXTURE" claude raciocinio --so-mostrar 2>&1)"; cod=$?
assert "claude --so-mostrar imprime cd + claude --model --effort" 0 "$cod" "$saida" "cd .*test/fixture && claude --model fable --effort high --name duplo:raciocinio"
saida="$(bash "$DUPLO" --dir "$FIXTURE" codex rotina --so-mostrar 2>&1)"; cod=$?
assert "codex --so-mostrar imprime codex -C -m -c model_reasoning_effort" 0 "$cod" "$saida" 'codex -C .*test/fixture -m gpt-6-astra -c model_reasoning_effort=\\"low\\"'
saida="$(bash "$DUPLO" --dir "$FIXTURE" codex codigo --so-mostrar 2>&1)"; cod=$?
assert "perfil codigo acrescenta flags extras no codex" 0 "$cod" "$saida" "\-s workspace-write"
saida="$(bash "$DUPLO" --dir "$FIXTURE" claude --so-mostrar 2>&1)"; cod=$?
assert "sem perfil usa o padrao" 0 "$cod" "$saida" "perfil: padrao"
saida="$(bash "$DUPLO" --dir "$FIXTURE" claude inexistente --so-mostrar 2>&1)"; cod=$?
assert "perfil inexistente falha e lista os disponíveis" 1 "$cod" "$saida" "perfil 'inexistente' não existe"

# 12. ajuda, perfis, versao, comando desconhecido, --dir inválido
saida="$(bash "$DUPLO" ajuda 2>&1)"; cod=$?
assert "ajuda sai com 0 e lista os comandos" 0 "$cod" "$saida" "uso registrar"
saida="$(bash "$DUPLO" perfis 2>&1)"; cod=$?
assert "perfis lista os 4 perfis" 0 "$cod" "$saida" "raciocinio"
saida="$(bash "$DUPLO" versao 2>&1)"; cod=$?
assert "versao bate com VERSION" 0 "$cod" "$saida" "cerebro-duplo $(cat "$RAIZ/VERSION")"
saida="$(bash "$DUPLO" --dir "$FIXTURE" inventado 2>&1)"; cod=$?
assert "comando desconhecido sai com 1" 1 "$cod" "$saida" "comando desconhecido"
saida="$(bash "$DUPLO" --dir "$TMP/nao-existe" verificar 2>&1)"; cod=$?
assert "--dir inexistente sai com 1" 1 "$cod" "$saida" "não existe"

# 13. instalar.sh instala num cérebro e o duplo.sh instalado funciona sozinho
I="$TMP/instalado"; copiar_fixture "$I"
saida="$(bash "$RAIZ/instalar.sh" "$I" 2>&1)"; cod=$?
assert "instalar.sh roda sem erro" 0 "$cod" "$saida" "Instalado em"
for p in .claude/skills/qual-agente/SKILL.md .agents/skills/qual-agente/agents/openai.yaml .claude/skills/duplo-verificar/SKILL.md .agents/skills/duplo-verificar/SKILL.md scripts/duplo.sh scripts/perfis/raciocinio.env scripts/modelos/registro-uso.md; do
  [ -f "$I/$p" ] || falha "instalar.sh não criou $p"
done
saida="$(bash "$I/scripts/duplo.sh" --dir "$I" verificar 2>&1)"; cod=$?
assert "duplo.sh instalado verifica o cérebro com as 10 skills" 0 "$cod" "$saida" "10 skills idênticas"
saida="$(cd "$I" && bash scripts/duplo.sh codex raciocinio --so-mostrar 2>&1)"; cod=$?
assert "duplo.sh instalado acha os perfis ao lado dele" 0 "$cod" "$saida" "perfil: raciocinio"

echo "== resultado: $PASSOU passaram, $FALHOU falharam"
[ "$FALHOU" -eq 0 ]
