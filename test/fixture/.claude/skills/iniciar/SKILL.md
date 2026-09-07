---
name: iniciar
description: Entrevista inicial de 7 perguntas que monta o segundo cérebro no dia 1 (contexto, voz, conexões e manual do agente). Use quando o usuário disser "iniciar", "me configura", "onboarding", "começar", "preenche meu cérebro", "set me up", "onboard", ou tiver acabado de instalar o kit. Pode rodar de novo a qualquer momento depois de editar entrevista-inicial.md.
disable-model-invocation: true
argument-hint: "[nome do usuário, opcional]"
---

# Iniciar

Um único fluxo: lê (ou cria) `entrevista-inicial.md`, faz as 7 perguntas que faltam, e no final gera os arquivos do dia 1 de uma vez. Não existe passo separado de "montar estrutura". É tudo aqui.

**O momento uau:** no fim, sugira que o usuário abra uma conversa nova e pergunte *"quem sou eu e no que devo focar esta semana?"*. A resposta tem que citar o contexto real dele. É isso que mostra que funcionou.

## Quando NÃO rodar

- Se o usuário quer só adicionar uma conexão nova: aponte `conexoes.md` ou diga para pedir "quero conectar X".
- Se quer aprofundar um tema específico: é `/entrevista`, não `/iniciar`.

## Execução

### Antes de tudo

Leia `AGENTS.md` e `CLAUDE.md` da raiz. Os caminhos abaixo são os padrões do kit. Se o projeto já tiver contexto, voz ou conexões em outro lugar, use o que existe em vez de criar fonte paralela. Este skill atualiza o contexto pessoal, não reescreve o manual inteiro.

Se `entrevista-inicial.md` não existir, copie o [modelo](assets/entrevista-inicial.md) para a raiz. Preencha só o que outras fontes do projeto já respondem com clareza, citando de onde veio. O resto fica para a conversa.

### Passo 1: ler a entrevista

Abra `entrevista-inicial.md`. Veja quais das perguntas P1 a P7 têm resposta e quais ainda têm `[Sua resposta aqui]`.

- **Todas respondidas** → pule para o Passo 3.
- **Algumas** → diga quais estão respondidas e pergunte se quer completar agora ou montar com o que há. Decisão do usuário.
- **Nenhuma** → Passo 2.

### Passo 2: a entrevista (7 perguntas, limite fixo)

Uma pergunta por vez. **Grave cada resposta em `entrevista-inicial.md` antes de fazer a próxima**, para o usuário poder parar e voltar.

**P1. Quem é você, o que faz (ou vende) e para quem?** Se não houver negócio, descreva o trabalho e para quem ele importa.

**P2. Cole 1 ou 2 coisas que você escreveu recentemente. Sem editar.**
*A única pergunta com regra dura.* A amostra tem que ser **colada de um texto real**, não escrita agora no chat. Se o usuário começar a digitar um texto novo, recuse com gentileza:

> Para. Cola do original. Se você escrever agora, no meio da nossa conversa, a amostra já sai com o tom da conversa. Abre seu último e-mail ou post em outra aba e cola sem mexer. É a única regra que não dá para dobrar.

Peça duas amostras. Um e-mail e um post, ou duas de qualquer tipo.

**P3. Quais são as 2 ou 3 maiores prioridades dos próximos 90 dias?** Se a resposta for "crescer", insista em número, prazo ou entregável.

**P4. Onde o dinheiro entra e onde é acompanhado?** Aceite "não se aplica" e pergunte o que a pessoa acompanha no lugar.

**P5. Onde você fala com clientes, equipe e o mundo no dia a dia?**

**P6. Onde vivem gravações de reunião, anotações e documentos importantes?**

**P7. Qual é a tarefa que come sua semana, e onde você acompanha o trabalho?** Guarde a "dor principal": o `/evoluir` usa.

A agenda (domínio 3 de `conexoes.md`) se infere da P5: Gmail → Google Calendar; Outlook → Outlook Calendar. Confirme no Passo 3.

### Passo 3: gerar os arquivos do dia 1

Com a entrevista completa, gere (ou atualize) em um único lote. Se já existirem versões anteriores, copie-as antes para `arquivo/entrevista-inicial-AAAA-MM-DD-HHMM/`.

1. `contexto/sobre-mim.md`: de P1 (identidade, função) e P7 (dor principal). Um parágrafo curto para cada.
2. `contexto/sobre-o-trabalho.md`: de P1 (oferta ou função, público) e P4 (modelo de receita ou o que acompanha). Um parágrafo.
3. `contexto/prioridades.md`: de P3. Lista numerada, uma linha por prioridade, com a data da entrevista no topo.
4. `referencias/voz.md`: de P2. Amostras coladas sem edição, com um cabeçalho curto: "Siga este registro ao redigir. Não imite a voz em conteúdo externo sem mostrar o rascunho antes." Abaixo das amostras, 3 a 5 linhas descrevendo o que você observou (tamanho de frase, formalidade, vícios, o que a pessoa evita).
5. `conexoes.md`: preencha as 7 linhas com P4 a P7. Cada uma com mecanismo `não conectado`, autenticação `—`, última leitura `—`. As conexões se ligam no dia 2.
6. **Manual (`AGENTS.md` e `CLAUDE.md`)**: substitua os `{{...}}` com nome, prioridade principal, resumo da base de conhecimento (P1 + P3) e resumo das conexões (P4 a P7). Em um manual já personalizado, atualize só essas seções e preserve o resto. Os dois arquivos ficam idênticos.

### Passo 4: tela de encerramento

Uma tela. Três linhas:

```
✓ Dia 1 pronto. Seu cérebro sabe quem você é, o que faz, o que importa neste trimestre e como você escreve.

Hoje: abra uma conversa nova e pergunte "quem sou eu e no que devo focar esta semana?".
Amanhã: escolha uma ferramenta em conexoes.md e me peça para conectar.
Dia 7: rode /auditar para ver sua nota.
```

Quando o usuário fizer a pergunta de teste, responda usando só os arquivos de contexto: 3 itens de prioridade, no registro de voz de P2, cada um ligado a uma prioridade de P3, e uma linha final: "Se eu tivesse que escolher uma coisa para segunda-feira, seria X, porque Y." Genérico é falha.

## Regras

1. **Sete perguntas. Nenhuma a mais.**
2. **A amostra de voz não pode ser digitada no chat.** Recuse e peça para colar.
3. **Geração em lote único.** Depois do Passo 2, escreva tudo do Passo 3 de uma vez. Sem confirmar arquivo por arquivo. O usuário itera editando `entrevista-inicial.md` e rodando de novo.
4. **Idempotente.** Rodar de novo com a entrevista editada atualiza os arquivos de contexto e guarda as versões anteriores em `arquivo/`. Pula perguntas já respondidas, a menos que o usuário queira revisar.
5. **Não crie skills extras.** Nada de `/hoje`, `/rascunho`, `/conectar`. Novas capacidades nascem no `/evoluir`.
6. **Não peça chave de API nem crie `.env`.** Conexões são o dia 2.

## Verificação

- Instalação limpa → `/iniciar` → 7 respostas → arquivos gerados → pergunta de teste cita P1, P3 e P7. Genérico = falha.
- Rodar de novo com uma prioridade alterada → só `contexto/prioridades.md` e a seção de prioridades do manual mudam; versão anterior em `arquivo/`.
- Digitar amostra de voz no chat → o skill recusa e pede para colar.
