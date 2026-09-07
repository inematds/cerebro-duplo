# Instalar o cerebro-duplo

## Requisitos

- Um cérebro criado pelo [astra-2cerebro](https://github.com/inematds/astra-2cerebro) (uma pasta com `AGENTS.md`, `CLAUDE.md`, `.claude/skills/`, `.agents/skills/`).
- `bash` 4+, `diff`, `awk`, `cp` (Linux, macOS, Git Bash ou WSL).
- Pelo menos um dos agentes instalado: `claude` (Claude Code) e/ou `codex` (Codex CLI). O `duplo.sh verificar`, `sync` e `uso` funcionam sem nenhum dos dois.

## Caminho 1: instalador no terminal

```bash
git clone https://github.com/inematds/cerebro-duplo.git
cd cerebro-duplo
bash instalar.sh ~/meu-cerebro
```

O `instalar.sh`:

1. Copia `skills/qual-agente` e `skills/duplo-verificar` para `<cerebro>/.claude/skills/` **e** `<cerebro>/.agents/skills/` (cópias idênticas, cada uma com seu `agents/openai.yaml`).
2. Copia `duplo.sh` para `<cerebro>/scripts/duplo.sh`, e `perfis/` e `modelos/` para `<cerebro>/scripts/perfis/` e `<cerebro>/scripts/modelos/` (o script procura essas pastas ao lado dele).
3. Roda `scripts/duplo.sh verificar` e mostra o resultado.

Não apaga nada. Rodar de novo sobrescreve só os arquivos do cerebro-duplo.

## Caminho 2: à mão (ou em Windows sem bash)

Copie:

- `skills/qual-agente/` → `<cerebro>/.claude/skills/qual-agente/` e `<cerebro>/.agents/skills/qual-agente/`
- `skills/duplo-verificar/` → `<cerebro>/.claude/skills/duplo-verificar/` e `<cerebro>/.agents/skills/duplo-verificar/`
- `duplo.sh` → `<cerebro>/scripts/duplo.sh`
- `perfis/` → `<cerebro>/scripts/perfis/`
- `modelos/` → `<cerebro>/scripts/modelos/`

As skills funcionam sem o script (a `qual-agente` é só texto). O `duplo.sh` precisa de bash; no Windows puro, use Git Bash ou WSL.

## Depois de instalar

```bash
cd ~/meu-cerebro
bash scripts/duplo.sh verificar          # deve dar 0 problema(s)
bash scripts/duplo.sh perfis             # confira os modelos
```

- Edite `scripts/perfis/*.env` com os modelos do **seu** plano. Os nomes que vêm no repo (`fable`, `sonnet`, `gpt-6-astra`) são os desta máquina.
- No Claude Code: `/qual-agente <pedido>` e `/duplo-verificar`.
- No Codex: `$qual-agente <pedido>` e `$duplo-verificar`.
- Se quiser que o manual do cérebro mencione as skills novas, adicione duas linhas em `AGENTS.md` (seção "Suas skills") e rode `bash scripts/duplo.sh sync`:

```
- `/qual-agente`: decide agente (Claude Code ou Codex), modelo e esforço para a tarefa e devolve o comando `duplo.sh`.
- `/duplo-verificar`: confere a paridade entre `AGENTS.md`/`CLAUDE.md` e `.claude/skills`/`.agents/skills` e propõe consertos.
```

## Atualizar

```bash
cd cerebro-duplo && git pull
bash instalar.sh ~/meu-cerebro
```

Perfis editados por você em `scripts/perfis/` **são sobrescritos** na atualização: guarde uma cópia ou versione o cérebro (repositório privado).

## Instruções para o agente

Se você é um agente (Claude Code, Codex ou outro que leia `AGENTS.md`) e o usuário pediu "instala o cerebro-duplo no meu cérebro", siga isto sem perguntar mais nada além do caminho do cérebro, se ele não tiver dito:

1. **Descubra o cérebro.** É a pasta que tem `AGENTS.md` e `CLAUDE.md` e a pasta `.claude/skills/`. Se o usuário não disse qual é, pergunte o caminho em uma linha. Se não existir cérebro nenhum, pare e indique o astra-2cerebro (`https://github.com/inematds/astra-2cerebro`).
2. **Obtenha o cerebro-duplo.** `git clone https://github.com/inematds/cerebro-duplo.git` numa pasta temporária ou ao lado dos projetos do usuário. Se não houver `git`, baixe o zip do repositório e descompacte.
3. **Instale.** `bash instalar.sh <cerebro>`. Se não houver bash, faça as cópias do "Caminho 2" acima com as ferramentas que tiver, mantendo os dois lados (`.claude/skills` e `.agents/skills`) byte a byte iguais.
4. **Verifique.** `bash <cerebro>/scripts/duplo.sh --dir <cerebro> verificar`. Se acusar PROBLEMA, mostre a saída ao usuário e proponha o conserto (o `sync` resolve manual e skills espelhadas; skill só no espelho é decisão do usuário). Rotas em AVISO não bloqueiam.
5. **Ajuste os perfis.** Abra `<cerebro>/scripts/perfis/*.env` e confirme com o usuário os nomes de modelo do plano dele. Não invente nomes de modelo: use `claude --help` (aliases e níveis de `--effort`) e o `~/.codex/config.toml` dele (chaves `model` e `model_reasoning_effort`) como fonte.
6. **Registre.** Sugira anotar em `decisoes/registro.md` do cérebro: "instalado cerebro-duplo v<versão>; canônico é AGENTS.md e .claude/skills; perfis em scripts/perfis". Não faça isso sem o usuário concordar.
7. **Não faça** commit, push nem nada fora da pasta do cérebro. Não rode `claude` nem `codex` para testar: isso gasta a cota do usuário. Use `duplo.sh claude padrao --so-mostrar` para mostrar o comando.

Ao terminar, responda em três linhas: onde instalou, o resultado do `verificar`, e os dois comandos que o usuário vai usar (`/qual-agente` ou `$qual-agente`; `bash scripts/duplo.sh ajuda`).
