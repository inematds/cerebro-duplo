# cerebro-duplo — um cérebro, dois agentes

Playbook + ferramental para usar **o mesmo segundo cérebro** (a pasta de Markdown criada pelo kit [astra-2cerebro](https://github.com/inematds/astra-2cerebro)) com o **Claude Code** (modelos Claude) e com o **Codex CLI** (modelos da OpenAI), escolhendo o agente, o modelo e o esforço certos para cada tarefa, mantendo manuais e skills em paridade, e registrando uso por sessão.

Bash puro. Sem dependências. Versão 1.0.0.

## O problema

Você tem um segundo cérebro: contexto, decisões, projetos, wiki, rotinas. Dois agentes conseguem lê-lo, mas cada um por uma porta diferente:

| | Claude Code | Codex CLI |
|---|---|---|
| Manual que o agente lê ao abrir | `CLAUDE.md` | `AGENTS.md` |
| Pasta de skills do projeto | `.claude/skills/<nome>/SKILL.md` | `.agents/skills/<nome>/SKILL.md` (+ `agents/openai.yaml`) |
| Como invocar uma skill | `/nome` | `$nome` |

Sem cuidado, isso vira **dois cérebros**: uma rota editada só no `AGENTS.md`, uma skill corrigida só em `.claude/skills`, e cada agente passa a viver em uma realidade. E, sem um critério, você acaba gastando o modelo mais caro em "acha aquele e-mail" e o mais barato em auditoria.

O cerebro-duplo resolve as três coisas:

1. **Paridade** — `duplo.sh verificar` mede; `duplo.sh sync` conserta; a skill `duplo-verificar` relata e propõe.
2. **Roteamento** — a skill `qual-agente` decide agente + modelo + esforço e devolve o comando. Perfis de execução (`perfis/*.env`) guardam modelo e esforço por tipo de tarefa.
3. **Uso e cota** — `duplo.sh uso registrar` anota cada sessão; `uso resumo` mostra onde a cota está indo. Nada de preço inventado: o registro é em minutos e sessões, o custo em dinheiro vem da tabela do provedor.

## Como funciona

```
meu-cerebro/
├── AGENTS.md  ══ idênticos ══  CLAUDE.md          ← duplo.sh verificar / sync
├── .claude/skills/  ══ idênticas ══  .agents/skills/
│     ├── qual-agente/        ← decide agente, modelo, esforço
│     ├── duplo-verificar/    ← relatório de paridade
│     └── (as 8 skills do astra-2cerebro)
├── scripts/duplo.sh          ← CLI
├── scripts/perfis/*.env      ← modelo + esforço por perfil (padrao, rotina, raciocinio, codigo)
└── registro-uso.md           ← uma linha por sessão
```

O canônico é `AGENTS.md` (qualquer agente que siga o padrão AGENTS.md o lê) e `.claude/skills` (é de onde o kit astra-2cerebro sincroniza). O espelho é regenerado, nunca editado à mão.

## Comandos

Todos aceitam `--dir <cerebro>` (padrão: pasta atual).

| Comando | O que faz | Sai com 1 se... |
|---|---|---|
| `duplo.sh verificar` | `AGENTS.md` = `CLAUDE.md`? Cada skill espelhada e idêntica? Cada skill tem `SKILL.md` e `agents/openai.yaml`? Rotas do manual existem? | houver PROBLEMA (rota quebrada é só AVISO) |
| `duplo.sh sync [--fonte agents\|claude]` | Regrava o manual do outro lado a partir da fonte (padrão `agents`); copia `.claude/skills` → `.agents/skills`. Nunca apaga skill que só existe no espelho; avisa. | erro de execução |
| `duplo.sh claude [perfil] [--so-mostrar]` | Abre o Claude Code no cérebro com `--model` e `--effort` do perfil. Imprime o comando antes. | perfil inexistente |
| `duplo.sh codex [perfil] [--so-mostrar]` | Abre o Codex no cérebro com `-C`, `-m` e `-c model_reasoning_effort` do perfil. Imprime o comando antes. | perfil inexistente |
| `duplo.sh uso registrar <agente> <perfil> <minutos> "<tarefa>"` | Acrescenta uma linha em `<cerebro>/registro-uso.md` (cria do template). | agente ≠ claude/codex, minutos não numéricos |
| `duplo.sh uso resumo` | Sessões e minutos por agente e por agente+perfil. | não há registro |
| `duplo.sh perfis` | Lista os perfis e seus modelos. | |
| `duplo.sh ajuda` | Ajuda. | |

Comandos gerados (saída real de `--so-mostrar` nesta máquina, Claude Code 2.1.263 e Codex 0.153.3):

```
$ duplo.sh --dir test/fixture claude raciocinio --so-mostrar
perfil: raciocinio (perfis/raciocinio.env)
comando: cd /…/test/fixture && claude --model fable --effort high --name duplo:raciocinio

$ duplo.sh --dir test/fixture codex rotina --so-mostrar
perfil: rotina (perfis/rotina.env)
comando: codex -C /…/test/fixture -m gpt-6-astra -c model_reasoning_effort=\"low\"
```

## Perfis

| Perfil | Claude Code | Codex | Para quê |
|---|---|---|---|
| `raciocinio` | `fable` / `high` | `gpt-6-astra` / `high` | `/auditar`, `/evoluir`, arquitetura, wiki grande |
| `padrao` | `sonnet` / `medium` | `gpt-6-astra` / `medium` | dia a dia |
| `rotina` | `sonnet` / `low` | `gpt-6-astra` / `low` | achar documento, resumir reunião, e-mail |
| `codigo` | `fable` / `high` + `--permission-mode acceptEdits` | `gpt-6-astra` / `high` + `-s workspace-write` | código longo, refatoração |

Os nomes de modelo são os do plano desta máquina; edite `perfis/*.env` para o seu. Aliases do Claude Code (`fable`, `opus`, `sonnet`) e níveis de esforço (`low`…`max`) foram lidos do `claude --help`; no Codex, o esforço vai pela chave de configuração `model_reasoning_effort` (ver [docs/comparativo-runtimes.md](docs/comparativo-runtimes.md)).

## Roteamento (resumo)

A tabela completa, com justificativas, está em [docs/roteamento.md](docs/roteamento.md). O essencial:

| Tarefa | Agente | Perfil |
|---|---|---|
| Usa um MCP específico (calendário, e-mail, navegador) | o que **tem o MCP** configurado | `padrao` |
| Código longo, refatoração | o agente onde o **repo já está aberto** | `codigo` |
| Auditoria, arquitetura, decisão difícil, wiki grande | qualquer um | `raciocinio` |
| Achar documento, resumir reunião, redigir e-mail | qualquer um | `rotina` |
| Entrevista, conversa de descoberta | o que você prefere conversar | `padrao` |
| Rotina agendada, sem supervisão | o que já tem o agendamento | `rotina` |

Regras de cota: semana apertada → cai um degrau (`raciocinio` → `padrao` → `rotina`) ou troca de agente; auditoria nunca cai degrau (adia); sempre registrar uso ao terminar.

## Instalação em 1 minuto

```bash
git clone https://github.com/inematds/cerebro-duplo.git
cd cerebro-duplo
bash instalar.sh ~/meu-cerebro      # a pasta criada pelo astra-2cerebro
```

Isso copia as duas skills para `.claude/skills` e `.agents/skills` do cérebro, o `duplo.sh` (com `perfis/` e `modelos/`) para `scripts/`, e roda `verificar`. Detalhes e "instruções para o agente" em [INSTALAR.md](INSTALAR.md).

## Um dia de uso

```bash
cd ~/meu-cerebro

# 08:30 — resumir a reunião de ontem (fontes/reuniao-2026-09-06.md)
bash scripts/duplo.sh claude rotina           # abre o Claude Code com sonnet/low
#   > /wiki  (ingere só a fonte nova)
bash scripts/duplo.sh uso registrar claude rotina 8 "resumo reunião 06/09"

# 10:00 — refatorar o script de conexão do calendário; o repo já está aberto no Codex
bash scripts/duplo.sh codex codigo            # gpt-6-astra/high, sandbox workspace-write
bash scripts/duplo.sh uso registrar codex codigo 40 "refatorar scripts/calendario.sh"

# 15:00 — "qual agente eu uso para a auditoria?"  → dentro de qualquer sessão: /qual-agente ou $qual-agente
#   resposta: raciocinio, no agente com mais cota sobrando (veja o resumo)
bash scripts/duplo.sh uso resumo
bash scripts/duplo.sh codex raciocinio        # $auditar
bash scripts/duplo.sh uso registrar codex raciocinio 25 "auditoria mensal"

# 18:00 — editei uma skill no Claude Code; o Codex precisa ver o mesmo
bash scripts/duplo.sh verificar               # acusa a diferença
bash scripts/duplo.sh sync                    # espelha
```

## Testes

`bash test/testes.sh` roda o `duplo.sh` contra `test/fixture` (um cérebro pequeno do astra-2cerebro, sem `apps/`) e contra cópias temporárias quebradas de propósito. Nunca toca na fixture.

Resultado real desta versão (Linux, bash 5.2):

```
== resultado: 38 passaram, 0 falharam
```

O que os testes cobrem:

- `verificar` passa na fixture íntegra (0 problemas; as 6 rotas que o `/iniciar` cria depois aparecem como AVISO).
- Manual divergente → código 1 com o diff; `sync` conserta (nos dois sentidos, `--fonte agents` e `--fonte claude`) e `verificar` volta a passar.
- Skill alterada no espelho, `openai.yaml` removido, skill sem cópia → código 1 com cada item nomeado; `sync` conserta e `verificar` volta a passar com "8 skills idênticas".
- Skill só no espelho → PROBLEMA no `verificar`, AVISO no `sync`, e o `sync` não apaga.
- `openai.yaml` faltando no canônico continua sendo problema depois do `sync` (o sync não inventa arquivo).
- Rota quebrada no manual → AVISO, código 0.
- `uso registrar` cria `registro-uso.md` do template, copia modelo/esforço do perfil, escapa `|` na tarefa, recusa agente desconhecido e minutos não numéricos; `uso resumo` soma certo (2 sessões/45 min, 1/10, total 3/55).
- `claude --so-mostrar` e `codex --so-mostrar` imprimem os comandos com as flags reais; perfil `codigo` acrescenta as flags extras; sem perfil usa `padrao`; perfil inexistente falha listando os disponíveis.
- `ajuda`, `perfis`, `versao` (bate com `VERSION`), comando desconhecido e `--dir` inválido.
- `instalar.sh` instala num cérebro copiado e o `duplo.sh` instalado funciona sozinho (10 skills idênticas, acha os perfis ao lado dele).

## Documentação

- [INSTALAR.md](INSTALAR.md) — instalação, atualização, instruções para o agente.
- [docs/comparativo-runtimes.md](docs/comparativo-runtimes.md) — Claude Code × Codex: manual, skills, invocação, MCP, memória, agendamento, flags reais, limitações.
- [docs/roteamento.md](docs/roteamento.md) — a tabela completa de roteamento com justificativas.
- [docs/paridade.md](docs/paridade.md) — por que os manuais precisam ser idênticos, o que quebra, checklist.
- [docs/custo-e-cota.md](docs/custo-e-cota.md) — registro de uso, como ler, como decidir degraus.
- [docs/migracao.md](docs/migracao.md) — levar um cérebro de um agente para o outro, e para um terceiro que leia `AGENTS.md`.
- [docs/faq.md](docs/faq.md) — perguntas frequentes.
- [CHANGELOG.md](CHANGELOG.md).

## Créditos e licença

Construído sobre o kit [astra-2cerebro](https://github.com/inematds/astra-2cerebro), que define a estrutura do cérebro, as 8 skills e a convenção `AGENTS.md` = `CLAUDE.md` / `.claude/skills` = `.agents/skills`. O `duplo.sh sync` faz o que o `scripts/sincronizar-skills.sh` do kit faz, mais o manual e a verificação.

MIT — Copyright (c) 2026 inematds. Veja [LICENSE](LICENSE).
