# cerebro-duplo — one brain, two agents

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

Playbook + tools for using **the same second brain** (the Markdown folder created by the [astra-2cerebro](https://github.com/inematds/astra-2cerebro) kit) with **Claude Code** (Claude models) and **Codex CLI** (OpenAI models), choosing the right agent, model, and effort for each task, keeping manuals and skills in sync, and logging usage by session.

Pure Bash. No dependencies. Version 1.0.0.

## 📖 User guide

Complete guide (landing page + walkthrough): **https://inematds.github.io/cerebro-duplo/guia/en/**

## The problem

You have a second brain: context, decisions, projects, wiki, routines. Two agents can read it, but each through a different entry point:

| | Claude Code | Codex CLI |
|---|---|---|
| Manual the agent reads when it opens | `CLAUDE.md` | `AGENTS.md` |
| Project skills folder | `.claude/skills/<nome>/SKILL.md` | `.agents/skills/<nome>/SKILL.md` (+ `agents/openai.yaml`) |
| How to invoke a skill | `/nome` | `$nome` |

Without care, this becomes **two brains**: a route edited only in `AGENTS.md`, a skill fixed only in `.claude/skills`, and each agent starts living in a different reality. And without a clear criterion, you end up spending the most expensive model on “find that email” and the cheapest one on an audit.

cerebro-duplo solves all three:

1. **Parity** — `duplo.sh verificar` measures; `duplo.sh sync` fixes; the `duplo-verificar` skill reports and proposes.
2. **Routing** — the `qual-agente` skill chooses the agent + model + effort and returns the command. Execution profiles (`perfis/*.env`) store the model and effort by task type.
3. **Usage and quota** — `duplo.sh uso registrar` logs each session; `uso resumo` shows where the quota is going. No made-up prices: the log records minutes and sessions, while the monetary cost comes from the provider’s pricing table.

## How it works

```
meu-cerebro/
├── AGENTS.md  ══ idênticos ══  CLAUDE.md          ← duplo.sh verificar / sync
├── .claude/skills/  ══ idênticas ══  .agents/skills/
│     ├── qual-agente/        ← decides agent, model, effort
│     ├── duplo-verificar/    ← parity report
│     └── (the 8 astra-2cerebro skills)
├── scripts/duplo.sh          ← CLI
├── scripts/perfis/*.env      ← model + effort by profile (padrao, rotina, raciocinio, codigo)
└── registro-uso.md           ← one line per session
```

The canonical files are `AGENTS.md` (any agent that follows the AGENTS.md standard reads it) and `.claude/skills` (where the astra-2cerebro kit syncs from). The mirror is regenerated, never edited by hand.

## Commands

All accept `--dir <cerebro>` (default: current folder).

| Command | What it does | Exits with 1 if... |
|---|---|---|
| `duplo.sh verificar` | `AGENTS.md` = `CLAUDE.md`? Is each mirrored skill identical? Does each skill have `SKILL.md` and `agents/openai.yaml`? Do the manual’s routes exist? | there is an ISSUE (a broken route is only a WARNING) |
| `duplo.sh sync [--fonte agents\|claude]` | Rewrites the manual on the other side from the source (default `agents`); copies `.claude/skills` → `.agents/skills`. Never deletes a skill that exists only in the mirror; warns. | execution error |
| `duplo.sh claude [perfil] [--so-mostrar]` | Opens Claude Code in the brain with the profile’s `--model` and `--effort`. Prints the command first. | profile does not exist |
| `duplo.sh codex [perfil] [--so-mostrar]` | Opens Codex in the brain with the profile’s `-C`, `-m`, and `-c model_reasoning_effort` settings. Prints the command first. | profile does not exist |
| `duplo.sh uso registrar <agente> <perfil> <minutos> "<tarefa>"` | Appends a line to `<cerebro>/registro-uso.md` (creates it from the template). | agent ≠ claude/codex, minutes are not numeric |
| `duplo.sh uso resumo` | Sessions and minutes by agent and by agent+profile. | there is no log |
| `duplo.sh perfis` | Lists profiles and their models. | |
| `duplo.sh ajuda` | Help. | |

Generated commands (actual `--so-mostrar` output on this machine, Claude Code 2.1.263 and Codex 0.153.3):

```
$ duplo.sh --dir test/fixture claude raciocinio --so-mostrar
perfil: raciocinio (perfis/raciocinio.env)
comando: cd /…/test/fixture && claude --model claude-opus-5-5 --effort high --name duplo:raciocinio

$ duplo.sh --dir test/fixture codex rotina --so-mostrar
perfil: rotina (perfis/rotina.env)
comando: codex -C /…/test/fixture -m gpt-6-astra -c model_reasoning_effort=\"low\"
```

## Profiles

| Profile | Claude Code | Codex | What for |
|---|---|---|---|
| `raciocinio` | top (`claude-opus-5-5`) / `high` | `gpt-6-astra` / `high` | `/auditar`, `/evoluir`, architecture, large wiki |
| `padrao` | `sonnet` / `medium` | `gpt-6-astra` / `medium` | day-to-day |
| `rotina` | `sonnet` / `low` | `gpt-6-astra` / `low` | find a document, summarize a meeting, email |
| `codigo` | top (`claude-opus-5-5`) / `high` + `--permission-mode acceptEdits` | `gpt-6-astra` / `high` + `-s workspace-write` | long code, refactoring |

Model names are those on this machine’s plan; edit `perfis/*.env` for yours. Claude Code aliases (`fable`, `opus`, `sonnet`) and effort levels (`low`…`max`) were read from `claude --help`; in Codex, effort is set through the `model_reasoning_effort` configuration key (see [docs/comparativo-runtimes.md](docs/comparativo-runtimes.md)).

## Routing (summary)

The complete table, with justifications, is in [docs/roteamento.md](docs/roteamento.md). The essentials:

| Task | Agent | Profile |
|---|---|---|
| Uses a specific MCP (calendar, email, browser) | the one **with the MCP** configured | `padrao` |
| Long code, refactoring | the agent where the **repo is already open** | `codigo` |
| Audit, architecture, difficult decision, large wiki | either | `raciocinio` |
| Find a document, summarize a meeting, draft an email | either | `rotina` |
| Interview, discovery conversation | the one you prefer talking to | `padrao` |
| Scheduled routine, unsupervised | the one that already has the schedule | `rotina` |

Quota rules: tight week → move down one level (`raciocinio` → `padrao` → `rotina`) or switch agents; never move down a level for an audit (postpone it); always log usage when finished.

## Install in 1 minute

```bash
git clone https://github.com/inematds/cerebro-duplo.git
cd cerebro-duplo
bash instalar.sh ~/meu-cerebro      # the folder created by astra-2cerebro
```

This copies both skills to the brain’s `.claude/skills` and `.agents/skills`, `duplo.sh` (with `perfis/` and `modelos/`) to `scripts/`, and runs `verificar`. Details and “instructions for the agent” are in [INSTALAR.md](INSTALAR.md).

## A day of use

```bash
cd ~/meu-cerebro

# 08:30 — summarize yesterday's meeting (fontes/reuniao-2026-09-06.md)
bash scripts/duplo.sh claude rotina           # opens Claude Code with sonnet/low
#   > /wiki  (ingests only the new source)
bash scripts/duplo.sh uso registrar claude rotina 8 "meeting summary 06/09"

# 10:00 — refactor the calendar connection script; the repo is already open in Codex
bash scripts/duplo.sh codex codigo            # gpt-6-astra/high, workspace-write sandbox
bash scripts/duplo.sh uso registrar codex codigo 40 "refactor scripts/calendario.sh"

# 15:00 — "which agent should I use for the audit?"  → in any session: /qual-agente or $qual-agente
#   answer: raciocinio, in the agent with more quota remaining (see the summary)
bash scripts/duplo.sh uso resumo
bash scripts/duplo.sh codex raciocinio        # $auditar
bash scripts/duplo.sh uso registrar codex raciocinio 25 "monthly audit"

# 18:00 — I edited a skill in Claude Code; Codex needs to see the same one
bash scripts/duplo.sh verificar               # reports the difference
bash scripts/duplo.sh sync                    # mirrors it
```

## Tests

`bash test/testes.sh` runs `duplo.sh` against `test/fixture` (a small astra-2cerebro brain, without `apps/`) and against intentionally broken temporary copies. It never touches the fixture.

Actual result for this version (Linux, bash 5.2):

```
== result: 38 passed, 0 failed
```

What the tests cover:

- `verificar` passes on the intact fixture (0 issues; the 6 routes created later by `/iniciar` appear as WARNINGS).
- Divergent manual → exit code 1 with the diff; `sync` fixes it (in both directions, `--fonte agents` and `--fonte claude`) and `verificar` passes again.
- Skill changed in the mirror, `openai.yaml` removed, skill without a copy → exit code 1 with each item named; `sync` fixes it and `verificar` passes again with “8 identical skills”.
- Skill only in the mirror → ISSUE in `verificar`, WARNING in `sync`, and `sync` does not delete it.
- `openai.yaml` missing from the canonical copy remains an issue after `sync` (`sync` does not invent a file).
- Broken route in the manual → WARNING, exit code 0.
- `uso registrar` creates `registro-uso.md` from the template, copies the profile’s model/effort, escapes `|` in the task, rejects an unknown agent and non-numeric minutes; `uso resumo` sums correctly (2 sessions/45 min, 1/10, total 3/55).
- `claude --so-mostrar` and `codex --so-mostrar` print commands with the actual flags; the `codigo` profile adds the extra flags; without a profile, uses `padrao`; a nonexistent profile fails and lists the available ones.
- `ajuda`, `perfis`, `versao` (matches `VERSION`), unknown command, and invalid `--dir`.
- `instalar.sh` installs in a copied brain and the installed `duplo.sh` works on its own (10 identical skills, finds the profiles next to it).

## Documentation

- [INSTALAR.md](INSTALAR.md) — installation, updates, instructions for the agent.
- [docs/comparativo-runtimes.md](docs/comparativo-runtimes.md) — Claude Code × Codex: manual, skills, invocation, MCP, memory, scheduling, actual flags, limitations.
- [docs/roteamento.md](docs/roteamento.md) — the complete routing table with justifications.
- [docs/paridade.md](docs/paridade.md) — why the manuals need to be identical, what breaks, checklist.
- [docs/custo-e-cota.md](docs/custo-e-cota.md) — usage log, how to read it, how to choose levels.
- [docs/migracao.md](docs/migracao.md) — moving a brain from one agent to another, and to a third that reads `AGENTS.md`.
- [docs/faq.md](docs/faq.md) — frequently asked questions.
- [CHANGELOG.md](CHANGELOG.md).

## Credits and license

Built on the [astra-2cerebro](https://github.com/inematds/astra-2cerebro) kit, which defines the brain structure, the 8 skills, and the `AGENTS.md` = `CLAUDE.md` / `.claude/skills` = `.agents/skills` convention. `duplo.sh sync` does what the kit’s `scripts/sincronizar-skills.sh` does, plus the manual and verification.

MIT — Copyright (c) 2026 inematds. See [LICENSE](LICENSE).
