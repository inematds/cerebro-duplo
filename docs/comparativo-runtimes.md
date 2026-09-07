# Comparativo: Claude Code × Codex CLI

O que cada runtime lê, onde configura, e quais flags o `duplo.sh` usa. Cada linha diz de onde veio a informação:

- **[máquina]** — verificado nesta máquina em 2026-09-07 com `claude --help` (Claude Code **2.1.263**) e `codex --help` / `codex exec --help` / `codex mcp --help` (Codex CLI **0.153.3**), mais a inspeção de `~/.codex/` e da estrutura do kit astra-2cerebro. Nenhum agente foi executado.
- **[doc]** — vem da documentação pública dos dois produtos; pode mudar entre versões. Confira antes de depender.

| Aspecto | Claude Code | Codex CLI | Fonte |
|---|---|---|---|
| Arquivo de manual lido ao abrir | `CLAUDE.md` (na pasta do projeto; também `~/.claude/CLAUDE.md` global e `CLAUDE.md` em subpastas) | `AGENTS.md` (na pasta do projeto e nas pais, até a raiz do repo; `~/.codex/AGENTS.md` global) | kit astra-2cerebro [máquina]; hierarquia [doc] |
| Pasta de skills do projeto | `.claude/skills/<nome>/SKILL.md` | `.agents/skills/<nome>/SKILL.md` + `agents/openai.yaml` por skill | kit astra-2cerebro [máquina] |
| Pasta de skills do usuário | `~/.claude/skills/` | `~/.codex/skills/` | [máquina] (as duas existem aqui e têm skills) |
| Formato de invocação | `/nome [args]` | `$nome [args]` | kit astra-2cerebro [máquina] |
| Metadados extras da skill | frontmatter `name`, `description`, `argument-hint` no `SKILL.md` | os mesmos, mais `agents/openai.yaml` com `interface.display_name`, `short_description`, `default_prompt` e `policy.allow_implicit_invocation` | kit astra-2cerebro [máquina] |
| Flag de modelo | `--model <alias\|nome>` — aliases `fable`, `opus`, `sonnet` ou nome completo (ex.: `claude-fable-5`) | `-m, --model <MODEL>` | [máquina] |
| Flag de esforço | `--effort <level>` — `low`, `medium`, `high`, `xhigh`, `max` | **não há flag própria**; usa a chave de config `model_reasoning_effort` via `-c 'model_reasoning_effort="high"'` (o valor é parseado como TOML, por isso as aspas) ou em `~/.codex/config.toml` | flag Claude [máquina]; chave Codex: presente no `config.toml` desta máquina [máquina]; lista de níveis (`minimal`, `low`, `medium`, `high`, alguns modelos `xhigh`) [doc] |
| Diretório de trabalho | não há flag: entre na pasta antes (`cd <cerebro> && claude …`); `--add-dir <dirs...>` libera pastas extras | `-C, --cd <DIR>` define a raiz; `--add-dir <DIR>` libera pastas extras | [máquina] |
| Perfis de configuração | `--settings <arquivo-ou-json>` | `-p, --profile <nome>` aplica `$CODEX_HOME/<nome>.config.toml` por cima do config base | [máquina] |
| Permissões / sandbox | `--permission-mode` — `acceptEdits`, `auto`, `bypassPermissions`, `manual`, `dontAsk`, `plan` | `-s, --sandbox` — `read-only`, `workspace-write`, `danger-full-access`; `-a, --ask-for-approval` — `on-request`, `never` | [máquina] |
| Nome da sessão | `-n, --name <nome>` | não há flag equivalente (sessões são listadas por `codex resume`) | [máquina] |
| Modo não interativo | `-p, --print` (com `--output-format`, `--max-budget-usd`) | `codex exec [PROMPT]` (alias `e`) | [máquina] |
| Onde configurar MCP | `claude mcp add <nome> <comando-ou-url>`; grava em `~/.claude.json` (escopo user) ou `.mcp.json` na raiz do projeto (escopo project); `--mcp-config <arquivos>` e `--strict-mcp-config` por sessão | `codex mcp add\|list\|get\|remove\|login\|logout`; grava em `~/.codex/config.toml` na tabela `[mcp_servers.<nome>]` | comandos [máquina]; arquivos gravados [doc] |
| Memória entre sessões | `CLAUDE.md` (o que você escreve) + memória automática por projeto em `~/.claude/projects/<projeto>/` | `AGENTS.md` (o que você escreve) + memórias em `~/.codex/memories/` (a pasta existe aqui) | Claude [doc]; Codex pasta [máquina], semântica [doc] |
| Rotinas / agendamento | agendamento em nuvem via `/schedule` (routines com cron) e `/loop` para repetição na sessão; ou `cron` do sistema chamando `claude -p` | `cron` do sistema chamando `codex exec`; sem agendador embutido no CLI nesta versão (o `codex --help` não lista) | Claude [doc]; Codex [máquina] (ausência no help) |
| Sessão em segundo plano | `--bg, --background`, `claude agents`, `claude attach <id>`, `claude logs <id>` | `codex agents` (sessões no app-server local), `codex resume`, `codex fork`, `codex queue` | [máquina] |
| Importar config do outro agente | `claude import [source]` ("Import config from another AI coding agent") | não há comando equivalente no help | [máquina] |
| Limitações conhecidas | sem flag de cwd (precisa do `cd`); `--effort` só vale para a sessão; memória automática é por projeto e por máquina | esforço só por config (`-c`), não por flag; não nomeia sessão; skills exigem o `openai.yaml` para aparecer bem no seletor `$` | [máquina] + prática |

## O que o `duplo.sh` gera

```
cd <cerebro> && claude --model <modelo> --effort <nível> --name duplo:<perfil> [extras]
codex -C <cerebro> -m <modelo> -c model_reasoning_effort="<nível>" [extras]
```

Os `[extras]` vêm de `DUPLO_CLAUDE_EXTRA` / `DUPLO_CODEX_EXTRA` no perfil (ex.: `--permission-mode acceptEdits`, `-s workspace-write`).

## Como conferir na sua máquina

```bash
claude --version; claude --help | grep -A2 -E -- '--model|--effort|--permission-mode'
codex --version;  codex --help  | grep -A1 -E -- '-m, --model|-C, --cd|-c, --config|-p, --profile'
grep -E '^(model|model_reasoning_effort)' ~/.codex/config.toml
```

Se a sua versão mostrar flags diferentes, ajuste `cmd_claude` / `cmd_codex` em `duplo.sh` (são duas funções curtas) e os perfis. Nada mais depende disso.
