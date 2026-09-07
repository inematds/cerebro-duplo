# Rotinas

Rotinas ativas e registro de execuções. Criadas por `/rotina`. O `/auditar` usa este arquivo como evidência de cadência: uma rotina só conta se tiver execuções registradas.

## Rotinas ativas

| ID | Nome | Gatilho | Mecanismo | Saída esperada | Como parar | Criada em |
|---|---|---|---|---|---|---|

**Mecanismos:** `manual` (você roda um comando em dia fixo), `agendado` (cron, agendador do sistema, ou rotina agendada do agente), `evento` (hook, webhook, chegada de arquivo).

## Registro de execuções

Mais recente no topo. Uma linha por execução.

| Data e hora | ID | Resultado | Saída produzida | Observação |
|---|---|---|---|---|
