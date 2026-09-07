# Migração: levar o cérebro de um agente para o outro

O cérebro é uma pasta de Markdown. Migrar não é converter: é garantir que o outro agente **enxergue a mesma pasta pelas portas dele**. Três cenários.

## 1. Do Claude Code para o Codex

Você usou só o Claude Code e o cérebro cresceu. O Codex precisa de `AGENTS.md`, `.agents/skills/` e um `openai.yaml` por skill.

```bash
cd ~/meu-cerebro
bash scripts/duplo.sh sync --fonte claude    # AGENTS.md a partir do CLAUDE.md; skills espelhadas
bash scripts/duplo.sh verificar
```

O `verificar` vai acusar `X não tem agents/openai.yaml` para cada skill criada só no Claude Code. Crie, em `.claude/skills/X/agents/openai.yaml`:

```yaml
interface:
  display_name: "Nome legível"
  short_description: "Uma frase do que a skill faz"
  default_prompt: "Use $X para ..."
policy:
  allow_implicit_invocation: false
```

Depois `sync` de novo. Aí:

- **MCP:** o que estava em `.mcp.json` / `~/.claude.json` precisa ser cadastrado no Codex com `codex mcp add <nome> ...` (grava em `~/.codex/config.toml`). Atualize `conexoes.md` dizendo qual agente tem cada MCP.
- **Memória automática:** o que o Claude Code guardou em `~/.claude/projects/...` não migra. O que importa deveria estar no cérebro (contexto, decisões). Se algo só existia na memória do agente, é hora de escrever em `contexto/` ou `decisoes/`.
- **Rotinas:** rotinas agendadas no Claude Code (`/schedule`) não migram; refaça com `cron` + `codex exec` se precisar rodar pelo Codex. Anote em `rotinas/registro.md` qual mecanismo roda cada uma.
- **Invocação:** onde o manual diz `/skill`, o Codex entende `$skill`. O kit astra-2cerebro escreve `/nome` no manual e funciona nos dois; não reescreva.

## 2. Do Codex para o Claude Code

Simétrico:

```bash
bash scripts/duplo.sh sync --fonte agents    # CLAUDE.md a partir do AGENTS.md
bash scripts/duplo.sh verificar
```

Atenção: o canônico das skills é `.claude/skills`. Se você criou skills **só** em `.agents/skills` enquanto usava o Codex, o `verificar` acusa "existe só no espelho" e o `sync` não copia de volta (não apaga, não inventa). Recupere à mão, uma vez:

```bash
for s in .agents/skills/*/; do n=$(basename "$s"); [ -d ".claude/skills/$n" ] || cp -R "$s" ".claude/skills/$n"; done
bash scripts/duplo.sh sync && bash scripts/duplo.sh verificar
```

- **MCP:** `claude mcp add <nome> <comando-ou-url>` para cada servidor que estava em `~/.codex/config.toml`.
- **Memória:** `~/.codex/memories/` não migra; mesma regra — o que importa vai para o cérebro.
- **Permissões:** o perfil `codigo` usa `--permission-mode acceptEdits` no Claude Code, o análogo aproximado de `-s workspace-write`.

## 3. Para um terceiro agente que leia `AGENTS.md`

Qualquer agente que siga o padrão `AGENTS.md` já lê o manual do cérebro sem mudar nada: por isso o `AGENTS.md` é a fonte canônica do manual no cerebro-duplo.

O que verificar no agente novo:

| Pergunta | Se sim | Se não |
|---|---|---|
| Lê `AGENTS.md` na raiz do projeto? | Nada a fazer. | Copie o conteúdo para o arquivo que ele lê (ex.: `.<agente>/instrucoes.md`) e trate como terceiro espelho: adicione um `cp` no seu fluxo depois do `sync`. |
| Tem noção de skills em pasta (`SKILL.md`)? | Aponte para `.claude/skills` (canônico) ou espelhe uma terceira pasta com o mesmo `cp -R` do `sync`. | As skills viram texto no manual: cole a seção "Passos" das skills que mais usa no `AGENTS.md`, ou peça "leia `.claude/skills/wiki/SKILL.md` e execute". |
| Suporta MCP? | Cadastre os mesmos servidores; anote em `conexoes.md`. | Tarefas com MCP ficam nos outros dois agentes (linha 1 da tabela de roteamento). |
| Tem flag de modelo/esforço? | Acrescente um bloco `DUPLO_<AGENTE>_MODELO/ESFORCO/EXTRA` em cada `perfis/*.env` e uma função `cmd_<agente>` no `duplo.sh` (copie `cmd_codex`, troque as flags). | Use o perfil só como registro: `uso registrar` aceita apenas `claude` e `codex` por padrão; amplie o `case` em `cmd_uso` para aceitar o nome novo. |

Para o `verificar` cobrir o terceiro espelho, adicione em `verificar_manual` um `cmp` extra contra o arquivo do agente novo. São poucas linhas; a estrutura do script foi feita para isso.

## 4. Levar o cérebro para outra máquina

Não é migração de agente, mas é a pergunta seguinte:

1. Copie a pasta inteira (ou `git clone` do repositório privado). Inclua `.claude/` e `.agents/` (pastas ocultas somem em cópias descuidadas).
2. `bash scripts/duplo.sh verificar` na máquina nova.
3. Reconfigure MCP nos dois agentes (as configurações ficam fora do cérebro, em `~/.claude.json` e `~/.codex/config.toml`).
4. Ajuste `scripts/perfis/*.env` se o plano for outro.
5. `registro-uso.md` vai junto: o histórico de cota continua.

## Regra geral

Se algo importante só existe **fora** da pasta do cérebro (memória do agente, config de MCP, agendamento), a migração vai perdê-lo. A defesa é registrar dentro: `conexoes.md` para MCP, `rotinas/registro.md` para agendamentos, `contexto/` e `decisoes/` para o que o agente "lembrava".
