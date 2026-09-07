# Paridade: por que os dois lados precisam ser idênticos

## O que é paridade

Dois pares de arquivos, quatro caminhos, um cérebro:

| Canônico | Espelho | Quem lê o espelho |
|---|---|---|
| `AGENTS.md` | `CLAUDE.md` | Claude Code |
| `.claude/skills/<nome>/` | `.agents/skills/<nome>/` | Codex |

Paridade é: **o espelho é byte a byte igual ao canônico**. Não "parecido", não "equivalente com os caminhos trocados". Igual.

Por que canônicos cruzados? Porque é assim que o kit astra-2cerebro já funciona: o `scripts/sincronizar-skills.sh` do kit copia `.claude/skills` → `.agents/skills` com `cp -R`, e o manual diz "`AGENTS.md` e `CLAUDE.md` têm o mesmo conteúdo". O cerebro-duplo respeita isso e escolhe `AGENTS.md` como fonte padrão do manual porque é o arquivo que um terceiro agente (qualquer um que siga o padrão AGENTS.md) também lê.

## O que quebra quando divergem

| Divergência | O que acontece | Quando você percebe |
|---|---|---|
| Rota nova só no `AGENTS.md` ("faturas → `financeiro/faturas/`") | O Codex acha as faturas; o Claude Code diz que não existe essa pasta e inventa um lugar | Semanas depois, quando alguém pergunta pelo Claude Code |
| Regra de voz editada só no `CLAUDE.md` ("nunca use exclamação") | E-mails redigidos pelo Codex saem com exclamação | No cliente |
| Skill corrigida só em `.claude/skills/wiki` (passo novo de índice) | O `$wiki` do Codex gera wiki sem índice; o `/auditar` desconta nota por "estrutura inconsistente" — e a culpa parece ser do conteúdo | Na auditoria seguinte, com diagnóstico errado |
| Skill nova só em `.claude/skills` | `$nome` não existe no Codex. O usuário conclui que "o Codex não faz isso" | Na primeira tentativa, mas com conclusão errada |
| `agents/openai.yaml` faltando | A skill não aparece direito no seletor `$` do Codex, ou aparece sem descrição | Quando você digita `$` e não encontra |
| Skill aposentada só em `.claude/skills` (apagada), sobra em `.agents/skills` | O Codex continua oferecendo uma skill que já não vale; o manual não a lista | Quando o Codex roda um procedimento antigo |
| Substituição de texto `.claude/skills/` → `.agents/skills/` dentro dos `.md` do espelho | Instruções ficam sem sentido ("copie de `.agents/skills` para `.agents/skills`"); a auditoria não consegue mais distinguir origem de espelho | Ao ler o espelho. O `verificar` acusa como diferença, e o `sync` regrava a cópia canônica. |

O padrão em todos: **a divergência é silenciosa**. Nenhum agente avisa "estou lendo uma versão diferente do meu colega". Só um verificador externo vê os dois lados.

## O que o `verificar` mede

- `AGENTS.md` e `CLAUDE.md` existem e são idênticos (`cmp`); se não, mostra `diff -u`.
- Cada pasta em `.claude/skills` existe em `.agents/skills` com conteúdo idêntico (`diff -rq`, ignorando `node_modules`), e vice-versa.
- Cada skill, nos dois lados, tem `SKILL.md` e `agents/openai.yaml`.
- Cada caminho entre crases no manual, com cara de caminho (`x/y.md`, `pasta/`), existe. Placeholders (`<ferramenta>`, `{{...}}`, `*`) são ignorados.

Severidade:

- **PROBLEMA** → código de saída 1. Tudo que é paridade.
- **AVISO** → código 0. Rotas para arquivos que ainda não existem. Motivo: o template do kit aponta para `contexto/prioridades.md`, `referencias/voz.md`, `wiki/index.md`, `auditorias/historico.md` **antes** de o `/iniciar` criá-los; isso é esperado num cérebro novo, não é quebra. Num cérebro maduro, trate cada aviso como rota a corrigir com `/vincular`.

## O que o `sync` faz (e o que não faz)

- Regrava `CLAUDE.md` a partir de `AGENTS.md` (`--fonte agents`, padrão) ou o inverso (`--fonte claude`). Se já são iguais, não toca.
- Para cada skill em `.claude/skills` cuja cópia difere: apaga a cópia e copia de novo (`rm -rf` + `cp -R`, sem `node_modules`). Skills já idênticas não são tocadas.
- **Não apaga** skill que só existe em `.agents/skills`: avisa. A decisão (recuperar para o canônico ou mover para `arquivo/`) é sua, porque o script não sabe se a skill foi aposentada ou se alguém criou no lado errado.
- **Não cria** `openai.yaml` faltando; só propaga o que existe. Se falta no canônico, o `verificar` continua acusando depois do `sync`.

## Checklist de paridade

Antes de fechar uma sessão em que você editou o manual ou uma skill:

- [ ] Editei o **canônico** (`AGENTS.md`, `.claude/skills/...`), não o espelho?
- [ ] Rodei `bash scripts/duplo.sh sync`?
- [ ] Rodei `bash scripts/duplo.sh verificar` e deu `0 problema(s)`?
- [ ] Se criei skill: tem `SKILL.md` com `name` e `description`, e `agents/openai.yaml` com `display_name`, `short_description`, `default_prompt` (usando `$nome`)?
- [ ] Se aposentei skill: movi a pasta para `arquivo/` nos **dois** lados e tirei a linha do manual?
- [ ] Se adicionei rota: o caminho existe? (`verificar` sem AVISO novo)
- [ ] Anotei em `decisoes/registro.md` se a mudança foi de comportamento?

Antes de trocar de agente no meio de um trabalho:

- [ ] `verificar` → `0 problema(s)`. Senão, o outro agente vai ler outra coisa.

## Se você usa git no cérebro

Faça o `verificar` rodar antes de cada commit. Hook mínimo (`.git/hooks/pre-commit`):

```bash
#!/usr/bin/env bash
bash scripts/duplo.sh --dir "$(git rev-parse --show-toplevel)" verificar >/dev/null || {
  echo "paridade quebrada: rode bash scripts/duplo.sh sync (ou veja o verificar)"; exit 1; }
```

O cérebro tem dados pessoais; o repositório deve ser privado.
