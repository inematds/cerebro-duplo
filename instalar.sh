#!/usr/bin/env bash
# instalar.sh — instala o cerebro-duplo dentro de um cérebro (kit astra-2cerebro).
#
# Uso: bash instalar.sh <pasta-do-cerebro>
#
# O que faz:
#   - copia skills/qual-agente e skills/duplo-verificar para
#     <cerebro>/.claude/skills/ e <cerebro>/.agents/skills/ (cópias idênticas)
#   - copia duplo.sh para <cerebro>/scripts/duplo.sh
#   - copia perfis/ e modelos/ para <cerebro>/scripts/perfis e <cerebro>/scripts/modelos
#     (o duplo.sh procura essas pastas ao lado dele)
#   - roda duplo.sh verificar no final
# Não apaga nada. Se já existir, sobrescreve só os arquivos do cerebro-duplo.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CEREBRO="${1:-}"

[ -n "$CEREBRO" ] || { echo "Uso: bash instalar.sh <pasta-do-cerebro>" >&2; exit 1; }
[ -d "$CEREBRO" ] || { echo "ERRO: pasta não existe: $CEREBRO" >&2; exit 1; }
CEREBRO="$(cd "$CEREBRO" && pwd)"

if [ ! -f "$CEREBRO/AGENTS.md" ] && [ ! -f "$CEREBRO/CLAUDE.md" ]; then
  echo "AVISO: $CEREBRO não tem AGENTS.md nem CLAUDE.md. É mesmo um cérebro do astra-2cerebro? Continuando assim mesmo."
fi

for skill in qual-agente duplo-verificar; do
  for destino in "$CEREBRO/.claude/skills" "$CEREBRO/.agents/skills"; do
    mkdir -p "$destino"
    rm -rf "$destino/$skill"
    cp -R "$AQUI/skills/$skill" "$destino/$skill"
  done
  echo "skill: $skill -> .claude/skills e .agents/skills"
done

mkdir -p "$CEREBRO/scripts"
cp "$AQUI/duplo.sh" "$CEREBRO/scripts/duplo.sh"
chmod +x "$CEREBRO/scripts/duplo.sh"
rm -rf "$CEREBRO/scripts/perfis" "$CEREBRO/scripts/modelos"
cp -R "$AQUI/perfis" "$CEREBRO/scripts/perfis"
cp -R "$AQUI/modelos" "$CEREBRO/scripts/modelos"
echo "script: scripts/duplo.sh (+ scripts/perfis, scripts/modelos)"

echo
echo "Instalado em $CEREBRO. Verificando paridade:"
bash "$CEREBRO/scripts/duplo.sh" --dir "$CEREBRO" verificar || true
echo
echo "Próximos passos:"
echo "  - no Claude Code: /qual-agente e /duplo-verificar"
echo "  - no Codex:       \$qual-agente e \$duplo-verificar"
echo "  - no terminal:    bash scripts/duplo.sh ajuda"
echo "  - edite scripts/perfis/*.env com os modelos do seu plano"
