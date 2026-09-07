---
name: evoluir
description: Lê a última auditoria (ou uma dor relatada) e fecha UMA lacuna do segundo cérebro com um artefato entregue: uma conexão, uma skill, um script, uma rotina, ou o conserto de um fluxo existente. Use quando o usuário disser "evoluir", "melhora meu cérebro", "fecha essa lacuna", "o que automatizar agora", "level up", ou depois de um /auditar.
argument-hint: "[lacuna ou achado da auditoria, opcional]"
---

# Evoluir

Uma rodada = **uma** melhoria entregue e verificável. Não é planejamento de várias candidatas. Não é coaching. O usuário pensa; você conduz e constrói.

O que `/evoluir` **não** é: não é `/auditar` (estrutural: "está montado certo?"). `/evoluir` é funcional: "que alavanca estou deixando na mesa?". Se a estrutura estiver bagunçada, `/auditar` primeiro.

## Quando rodar

- Primeira vez: depois da primeira auditoria e de pelo menos uma conexão ligada. Antes disso o resultado é raso.
- Depois: semanal enquanto o cérebro cresce, depois quando uma tarefa manual "coçar".

## O que ler antes

`AGENTS.md` / `CLAUDE.md`, `contexto/prioridades.md`, `contexto/sobre-mim.md` (a dor principal), `conexoes.md`, `decisoes/registro.md` (o que já foi feito ou descartado), o frontmatter das skills em `.claude/skills/*/SKILL.md`, `rotinas/registro.md`, e o relatório mais recente em `auditorias/`. Pergunte só o que não estiver nas fontes.

## Fase 1: escolher a candidata

**Vindo de uma auditoria** (o caso normal): a auditoria já entrega até três melhorias priorizadas com evidência e critério de conclusão. Traga a primeira delas como candidata principal. Pergunte só o contexto que falta. Não persiga pontos; persiga o que muda o trabalho do usuário.

**Sem auditoria recente**: cinco perguntas, uma por vez, em conversa:

1. Me conta sua semana. O que você fez três vezes ou mais?
2. O que foi manual, chato, ou copiar e colar?
3. Onde você pensou "um estagiário esperto faria isso"?
4. Se chegassem 10 vezes mais clientes (ou demandas) amanhã, o que quebraria primeiro?
5. O que traria 10 vezes mais clientes (ou resultado) amanhã?

Saída da fase: lista numerada de 1 a 3 candidatas, cada uma com uma linha de "por que é alavanca". Peça: "escolhe uma".

## Fase 2: escopar a escolhida

Cinco passos, em ordem. Registre as respostas.

**1. Qual gargalo isso resolve, ou qual alavanca abre?** Ligue à fase 1 e às prioridades.

**2. Eliminar, automatizar ou delegar?**
- **Eliminar primeiro:** "o que acontece se a gente simplesmente parar de fazer isso?" Se nada quebra, pare aqui, registre a eliminação em `decisoes/registro.md` e comemore. Não se automatiza desperdício.
- **Automatizar:** pense em três partes. A maior parte é regra determinística (script). Uma parte menor precisa de IA (resumir, classificar, redigir). Um resto continua manual (aprovar, decidir).
- **Delegar:** se for variável demais ou exigir julgamento pesado, sugira uma pessoa. Registre e encerre.

**3. Mapear o processo.** Cinco elementos: gatilho, de onde vem o dado, como o dado muda de forma, onde tem decisão, para onde vai a saída. Se o usuário não consegue descrever os cinco: "se não dá para explicar para uma pessoa, não dá para explicar para uma IA. Rascunha no papel e volta." Encerre.

**4. Escolher o nível de autonomia.**

| Nível | Nome | O que acontece |
|---|---|---|
| 0 | Manual | Sem IA |
| 1 | Sugerido | A IA sugere, o humano decide cada passo |
| 2 | Rascunhado | A IA rascunha, o humano revisa e edita |
| 3 | Supervisionado | A IA executa, o humano confere de tempos em tempos |
| 4 | Autônomo | A IA faz de ponta a ponta |

Padrão: **o menor nível que resolve o problema.** Recuse o nível 4 na primeira versão de qualquer coisa. Se uma decisão não PRECISA ser da IA, não deixe a IA decidir.

**5. Amarrar a uma métrica.** O que isso move: mais clientes, mais valor por cliente, menos custo, ou mais tempo livre para a prioridade X? E um número (tempo de resposta, horas por semana, taxa de erro, conversão). Sem métrica, encerre: "se não move um número, por que construir?".

Saída da fase: entrada datada em `decisoes/registro.md` com os cinco passos, o nível de autonomia e a métrica.

## Fase 3: construir

Pergunte "como você quer que isso exista?", nesta ordem (do mais simples ao mais complexo):

1. **Prompt salvo** em `referencias/prompts/<slug>.md`: o usuário roda à mão. Zero infraestrutura.
2. **Script determinístico** em `scripts/`: sem IA. Melhor para transformação com regra clara.
3. **Skill** em `.claude/skills/<slug>/SKILL.md` (e espelho em `.agents/skills/` via `scripts/sincronizar-skills.sh`): passos com uma chamada de IA dentro. Rascunha, classifica, resume.
4. **Rotina** via `/rotina`: quando o problema é "acontecer sem pedir".
5. **Subagente**: último recurso, só se o trabalho exigir raciocínio mais uso de ferramentas em vários passos.

Padrão: **a opção mais simples que resolve.** Autonomia maior só com pedido explícito.

Se a candidata for um **conserto** de algo que já existe (rota quebrada, conexão morta, skill que falha), conserte o existente. Não crie duplicata. Conserto verificado conta como o artefato da rodada. Rota quebrada e o usuário pediu a edição: use `/vincular`.

Todo artefato novo leva no topo:

```markdown
---
fase: 1  # Rodas de apoio. Rodar à mão e conferir a saída antes de agendar ou dar autonomia.
criado-em: AAAA-MM-DD
metrica: <a métrica da fase 2>
---
```

A fase só avança por edição explícita do usuário, depois de conferir a saída real algumas vezes. Ao construir: passos menores possíveis, zero IA quando dá, teste cada passo antes de encadear, entregue a versão mínima e cresça com uso real.

## Contrato de saída

Toda rodada produz:

1. **Uma entrada em `decisoes/registro.md`** com a especificação.
2. **Uma melhoria entregue**: prompt, script, skill, rotina, ou conserto verificado.
3. **Um fechamento de uma tela**: o que foi escopado, o que foi construído, como rodar, e a lembrança de que está na fase 1.

Feche recomendando `/auditar` de novo. Não afirme nota maior antes da auditoria verificar.

## Regras

1. Uma rodada, um artefato.
2. Eliminar vem antes de automatizar. Eliminação é vitória, não fracasso.
3. Menor autonomia que resolve. Sem nível 4 na primeira versão.
4. Opção mais simples que resolve. Sem subagente por padrão.
5. Métrica obrigatória.
6. Edite só `decisoes/registro.md` e o artefato escolhido (ou o fluxo existente sendo consertado). O resto é leitura.
7. Não rode fluxos pagos nem envie nada externo só para "testar".
