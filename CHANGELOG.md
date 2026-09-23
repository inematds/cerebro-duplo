# Changelog

Formato: semver `vX.XX.YY`. Mais recente no topo.

## 1.1.0 — 2026-09-23

- Perfis `raciocinio` e `codigo` usam `${INEMA_CLAUDE_TOPO:-opus}` no lugar de `fable`. Nesta máquina,
  `duplo.sh` lê o modelo do arquivo central `~/.config/inema/modelos.env` (hoje `claude-opus-5-5`);
  sem o arquivo, cai no alias `opus`.

## 1.0.0 — 2026-09-07

Primeira versão.

- `duplo.sh` com `verificar`, `sync` (`--fonte agents|claude`), `claude`/`codex [perfil] [--so-mostrar]`, `uso registrar`, `uso resumo`, `perfis`, `versao`, `ajuda`.
- Perfis `padrao`, `rotina`, `raciocinio`, `codigo` (modelo + esforço por agente).
- Skills `qual-agente` (roteamento) e `duplo-verificar` (relatório de paridade), com `agents/openai.yaml` para o Codex.
- `instalar.sh` que copia skills, script, perfis e template para dentro do cérebro.
- Template `modelos/registro-uso.md`.
- Testes em `test/testes.sh` contra `test/fixture` (38 asserções).
- Documentação: README, INSTALAR, comparativo de runtimes, roteamento, paridade, custo e cota, migração, FAQ.
