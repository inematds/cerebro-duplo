# Custo e cota

## O que se registra e o que não se registra

O cerebro-duplo registra **sessões e minutos**, não dinheiro. Motivos:

- Preços mudam, variam por plano (assinatura com limite semanal versus API por token) e por modelo. Qualquer número gravado no repo estaria errado em três meses.
- O que você controla no dia a dia é **quantas vezes e por quanto tempo** abriu cada agente com cada perfil. Isso basta para a regra de degraus.
- O custo em dinheiro está no lugar certo: o painel do provedor (Anthropic Console / painel do plano do Claude; OpenAI Platform / painel do plano do Codex) e a tabela de preços oficial de cada um. Consulte lá. Se quiser, anote o total mensal à mão no fim do `registro-uso.md`.

## O mecanismo

```
bash scripts/duplo.sh uso registrar <agente> <perfil> <minutos> "<tarefa>"
bash scripts/duplo.sh uso resumo
```

`registrar` acrescenta uma linha em `<cerebro>/registro-uso.md`, criado do template `modelos/registro-uso.md` na primeira vez:

```
| Data e hora | Agente | Perfil | Modelo | Esforço | Minutos | Tarefa |
|---|---|---|---|---|---|---|
| 2026-09-07 10:12 | claude | rotina | sonnet | low | 8 | resumo reunião 06/09 |
| 2026-09-07 11:03 | codex | codigo | gpt-6-astra | high | 40 | refatorar scripts/calendario.sh |
```

Modelo e esforço são **copiados do perfil no momento do registro**. Se você mudar o perfil depois, o histórico continua dizendo o que foi usado de fato.

`resumo` lê as linhas e soma:

```
| Agente | Sessões | Minutos |
|---|---|---|
| claude | 2 | 45 |
| codex | 1 | 10 |

| Agente | Perfil | Sessões | Minutos |
|---|---|---|---|
| claude | raciocinio | 2 | 45 |
| codex | rotina | 1 | 10 |

total: 3 sessões, 55 minutos
```

O arquivo é Markdown puro: você pode editar à mão, apagar linhas, ou fazer o `/auditar` ler como evidência de cadência.

## Como ler o resumo

Três perguntas, nesta ordem:

1. **Um agente está muito acima do outro?** Se sim, e você tem limite semanal nos dois, a próxima tarefa "qualquer um" vai para o de baixo.
2. **Quanto de `raciocinio` já foi esta semana?** É o perfil que consome mais. Se a auditoria ainda não rodou e a cota está no fim, é sinal de ordem errada: auditoria primeiro, rotina depois.
3. **Há sessões longas em `rotina`?** Sessão de 40 minutos em `rotina` costuma ser tarefa mal classificada (era `padrao` ou `codigo`), ou modelo barato patinando. Reclassifique na tabela de roteamento.

## Degraus: quando descer e quando não descer

A escada é `raciocinio` → `padrao` → `rotina`.

| Sinal | Decisão |
|---|---|
| Aviso de limite em um agente; tarefa sem MCP e sem repo aberto | Troque de agente, mesmo perfil. |
| Aviso de limite; tarefa presa (MCP ou repo aberto) | Desça um degrau no mesmo agente. |
| Limite nos dois | Desça um degrau em tudo; auditoria adiada (não desce). |
| Resposta rasa em `padrao` | Suba um degrau **na mesma sessão** (`/model` nos dois agentes) em vez de reabrir. |
| Tarefa longa em `raciocinio` | Divida em plano (curto, `raciocinio`) + execução (longo, `padrao`). |
| Rotina agendada | Sempre `rotina`. Se o resultado está ruim, o problema é o procedimento, não o modelo. |

## Reduzir consumo sem descer degrau

- **Contexto enxuto.** O manual e o mapa de rotas já dizem onde as coisas estão; não cole arquivos inteiros no prompt. Cite o caminho.
- **Sessões nomeadas** (`--name duplo:<perfil>` no Claude Code) ajudam a retomar em vez de recomeçar.
- **`wiki/` em vez de `fontes/`.** Perguntar à wiki (páginas resumidas) custa menos tokens do que reler a fonte bruta.
- **Um agente para o dia.** Trocar de agente a cada tarefa reconstrói contexto; agrupe as tarefas por agente quando puder.

## Registrar sem esquecer

A skill `qual-agente` termina toda resposta com a linha `ao fechar: duplo.sh uso registrar ...`. Se quiser algo automático, um alias no shell:

```bash
duplo-fim() { bash scripts/duplo.sh uso registrar "$@"; }
```

Ou uma rotina manual no cérebro (`/rotina`): toda sexta, rodar `uso resumo` e anotar a leitura em `rotinas/registro.md`. Duas execuções e ela vira hábito; três e o `/auditar` conta como cadência.
