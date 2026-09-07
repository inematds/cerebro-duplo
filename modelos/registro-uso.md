# Registro de uso — cerebro-duplo

Uma linha por sessão. Preenchido por `duplo.sh uso registrar <agente> <perfil> <minutos> "<tarefa>"` (ou à mão, no mesmo formato).

- **Agente:** `claude` ou `codex`.
- **Perfil:** o perfil usado (`padrao`, `rotina`, `raciocinio`, `codigo`, ou o seu).
- **Modelo / Esforço:** copiados do perfil no momento do registro, para o histórico não mudar quando você editar o perfil.
- **Minutos:** duração aproximada da sessão. É a medida de esforço humano; para custo em dinheiro, consulte a tabela de preços do provedor e o painel de uso da sua conta (Anthropic Console / OpenAI Platform ou o painel do plano).

`duplo.sh uso resumo` soma sessões e minutos por agente e por agente+perfil.

| Data e hora | Agente | Perfil | Modelo | Esforço | Minutos | Tarefa |
|---|---|---|---|---|---|---|
