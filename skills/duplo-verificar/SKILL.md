---
name: duplo-verificar
description: Roda a verificação de paridade do cérebro entre Claude Code e Codex (scripts/duplo.sh verificar) e transforma a saída em um relatório curto com o conserto proposto para cada item, sem consertar nada sozinha. Use quando o usuário disser "verifica a paridade", "os manuais estão iguais?", "as skills estão sincronizadas?", "o Codex não vê a skill", "AGENTS.md e CLAUDE.md divergem", "check parity", "are the manuals in sync", "verify skills mirror", ou antes de trocar de agente.
argument-hint: "[caminho do cérebro; padrão: pasta atual]"
---

# Verificar paridade

Os dois agentes leem o **mesmo cérebro**, mas por arquivos diferentes: o Claude Code lê `CLAUDE.md` e `.claude/skills/`; o Codex lê `AGENTS.md` e `.agents/skills/`. Se esses pares divergem, cada agente passa a viver em um cérebro diferente sem ninguém perceber. Esta skill mede isso e diz o que fazer. **Ela não conserta**, salvo se o usuário pedir explicitamente.

## Entrada

Opcional: o caminho do cérebro. Sem argumento, usa a pasta atual.

## Passos

1. **Ache o script.** Procure, nesta ordem: `scripts/duplo.sh` no cérebro, `duplo.sh` na pasta atual, `$DUPLO_HOME/duplo.sh`. Se não achar nenhum, pare e diga ao usuário como instalar (`bash instalar.sh <cerebro>` a partir do repo cerebro-duplo).
2. **Rode** `bash scripts/duplo.sh --dir "<cerebro>" verificar` e guarde a saída inteira e o código de saída.
3. **Classifique cada linha** da saída:
   - `PROBLEMA:` → item bloqueante (quebra a paridade). Código de saída 1.
   - `AVISO:` → item não bloqueante (rota do manual sem arquivo, skill só no espelho).
   - `OK:` → não repita no relatório; some no rodapé.
4. **Escreva o relatório** no formato abaixo. Para cada item, proponha **um** conserto, o menor possível, usando a tabela de consertos.
5. **Não execute o conserto.** Termine perguntando, em uma linha, se o usuário quer que você rode os comandos propostos. Só rode se ele disser sim, e rode exatamente o que propôs.

## Formato do relatório

```
Paridade do cérebro <caminho> — <N> problema(s), <M> aviso(s)

Problemas (bloqueiam)
1. <o que está errado, uma linha>
   conserto: <comando ou edição>
2. ...

Avisos
- <o que> → <conserto ou "deixar: o /iniciar cria depois">

OK: <resumo do que passou, uma linha>
Quer que eu aplique os consertos acima? (sim/não)
```

Se não houver problema nem aviso: uma linha, "Paridade OK: manuais idênticos, N skills espelhadas, rotas válidas", e nada mais.

## Tabela de consertos

| Saída do verificar | Conserto proposto |
|---|---|
| `AGENTS.md e CLAUDE.md divergem` | Olhe o diff. Se a edição boa está em `AGENTS.md`: `duplo.sh sync --fonte agents`. Se está em `CLAUDE.md`: `duplo.sh sync --fonte claude`. Se as duas têm coisa boa: mescle à mão em `AGENTS.md` e depois `sync --fonte agents`. |
| `AGENTS.md não existe` / `CLAUDE.md não existe` | `duplo.sh sync --fonte <o que existe>`. |
| `skill 'X' difere entre .claude/skills e .agents/skills` | Se a mudança boa está em `.claude/skills` (canônico): `duplo.sh sync`. Se alguém editou o espelho: copie a edição para `.claude/skills/X` e então `duplo.sh sync`. |
| `skill 'X' existe em .claude/skills mas não em .agents/skills` | `duplo.sh sync`. |
| `skill 'X' existe só no espelho .agents/skills` | Se ainda vale: `cp -R .agents/skills/X .claude/skills/X`. Se foi aposentada: `mv .agents/skills/X arquivo/skills-X`. O `sync` nunca apaga; a decisão é do usuário. |
| `X não tem agents/openai.yaml` | Criar `X/agents/openai.yaml` com `interface.display_name`, `short_description`, `default_prompt` (usando `$X`) e `policy.allow_implicit_invocation: false`, em `.claude/skills/X`, e então `duplo.sh sync`. |
| `X não tem SKILL.md` | A pasta não é uma skill. Mover para `arquivo/` ou criar o `SKILL.md` com frontmatter `name` e `description`. |
| `rota do manual aponta para caminho inexistente: P` | Se `P` é um dos arquivos que o `/iniciar` cria (`contexto/*.md`, `referencias/voz.md`, `wiki/index.md`, `auditorias/historico.md`): deixar, e sugerir rodar `/iniciar`. Senão: corrigir a rota com `/vincular` ou criar o arquivo. |
| `.claude/skills não existe` | O cérebro não tem skills instaladas: instalar o kit astra-2cerebro ou copiar as skills. |

## Limites

- Não edita arquivos sem pedido explícito.
- Não interpreta o conteúdo das skills; só a paridade dos arquivos.
- Se o `verificar` falhar por erro de execução (script não encontrado, pasta errada), relate o erro literal, não invente diagnóstico.
