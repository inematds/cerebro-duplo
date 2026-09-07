---
name: rotina
description: Define uma rotina recorrente do segundo cérebro (manual, agendada ou por evento) com gatilho, saída esperada, como parar e registro de execuções em rotinas/registro.md, para a cadência ter evidência. Use quando o usuário disser "rotina", "cria uma rotina", "todo dia/semana faz X", "agenda isso", "automatiza", "cadência", "schedule", "cron", ou quiser algo acontecendo sem pedir.
argument-hint: "<o que deve acontecer e com que frequência>"
---

# Rotina

Cadência é o quarto pilar: coisas úteis acontecendo sem o usuário pedir, **com registro**. Uma rotina só existe de verdade quando tem execuções anotadas. Configuração sem execução não vale nada na auditoria, e nem deveria.

Regra de ouro: **não automatize o que ainda não funciona manualmente.** A primeira versão de qualquer rotina é manual, rodada pelo usuário em dia fixo, por pelo menos duas execuções. Só depois vira agendada.

## Passo 1: entender a rotina

Leia `AGENTS.md` / `CLAUDE.md`, `rotinas/registro.md`, `contexto/prioridades.md` e `conexoes.md`. Pergunte só o que faltar:

1. **O que** deve acontecer e **qual saída** ela produz (um arquivo, uma mensagem, uma atualização em algum lugar). Saída vaga ("ficar de olho") não é rotina.
2. **Com que frequência** e **quando** (dia da semana, hora). Peça o horário real.
3. **De onde vem o dado** (uma conexão de `conexoes.md`? um arquivo? a wiki?). Se depende de uma conexão que não existe, pare aqui e diga: primeiro a conexão.
4. **Quem lê a saída** e o que faz com ela. Se ninguém lê, elimine a rotina antes de criar.
5. **Como parar** e o que acontece se rodar duas vezes no mesmo dia (duplicidade).

## Passo 2: escolher o mecanismo

| Mecanismo | Quando | Como |
|---|---|---|
| `manual` | Sempre, na primeira versão | O usuário roda um comando ou prompt salvo em dia fixo. O kit registra a execução |
| `agendado` | Depois de 2 execuções manuais boas | Cron, agendador do sistema, ou a rotina agendada do próprio agente (Claude Code tem `/schedule` e `/loop`; Codex tem agendamentos no app). Escolha o que o usuário já tem |
| `evento` | Quando um arquivo chega, um webhook dispara, um hook do agente roda | Só com o gatilho comprovado |

Se a rotina precisa de um script, escreva-o em `scripts/rotina-<slug>.(sh|py)` com: entrada, saída, código de saída diferente de zero em falha, e uma linha de log com data e resultado. Sem IA dentro do script quando regra determinística resolve.

Se a rotina precisa de raciocínio (resumir, classificar, redigir), o prompt vai em `rotinas/<slug>.md` para o usuário (ou o agendador) invocar com `claude -p "$(cat rotinas/<slug>.md)"` ou equivalente no Codex.

## Passo 3: registrar

1. Acrescente uma linha em **Rotinas ativas** de `rotinas/registro.md`: ID curto (`R01`, `R02`...), nome, gatilho, mecanismo, saída esperada, como parar, data.
2. Crie `rotinas/<slug>.md` com: objetivo, passo a passo, entrada, saída, comando exato para rodar à mão, o que fazer se falhar, e como desligar.
3. Se houver agendamento, anote onde ele está (linha do cron, nome da rotina no agente) na página da rotina.
4. Registre a decisão em `decisoes/registro.md` se a rotina tiver custo ou risco.

## Passo 4: primeira execução

Rode a rotina uma vez, à mão, agora, com o usuário. Registre em **Registro de execuções**: data e hora, ID, resultado (`ok` / `falhou` / `parcial`), saída produzida (caminho ou link), observação. Se falhou, conserte antes de considerar a rotina criada.

## Toda execução futura

Cada execução acrescenta uma linha no registro, inclusive as que falharam. Rotina que roda e não registra é rotina que a auditoria não vê. Se for agendada, o próprio script ou prompt acrescenta a linha.

## Fechamento

Uma tela: ID, nome, próximo disparo, comando manual, onde está o registro, e a lembrança: **duas execuções manuais boas antes de agendar**.

## Limites

- Não crie agendamento no sistema sem o usuário confirmar o mecanismo e o horário.
- Nunca guarde credenciais na página da rotina ou no registro.
- Não crie rotinas para "manter o cérebro"; a auditoria e a revisão da wiki já são rituais. Rotinas são para o trabalho do usuário.
- Uma rotina por vez. Rotina composta vira duas.
