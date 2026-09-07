---
name: entrevista
description: Entrevista o usuário a fundo sobre um tema (prioridades, equipe, clientes, um plano, uma decisão), salvando cada resposta em arquivo para nada se perder. Use quando o usuário disser "me entrevista", "entrevista", "me pergunta sobre X", "tira isso da minha cabeça", "grill me", "brainstorm", "discovery", ou quiser alimentar o segundo cérebro com contexto novo.
argument-hint: "<tema ou objetivo da entrevista>"
---

# Entrevista

Entreviste o usuário sem pressa sobre o tema, uma pergunta por vez, descendo cada ramo até chegar a um entendimento compartilhado. O objetivo real é **tirar o que está na cabeça dele e colocar em um arquivo Markdown durável e organizado**, para nada se perder quando o contexto da conversa encher.

## O arquivo de captura é o ponto

Entrevistas longas enchem o contexto. Se você guardar as respostas só na memória da conversa, vai esquecer, misturar ou perder algo. Por isso você **grava em disco depois de cada resposta**. O arquivo é a fonte da verdade, não o seu contexto. O usuário nunca deve precisar pedir "salva o que já falamos".

## Contexto existente

Leia `AGENTS.md` / `CLAUDE.md` e só as páginas de contexto e capturas anteriores relevantes ao tema. Reaproveite fatos já salvos; pergunte sobre lacunas, mudanças, decisões e trade-offs. Instalar o skill não inicia uma entrevista.

## Preparação (antes da primeira pergunta)

1. **Crie o arquivo** em `entrevistas/AAAA-MM-DD-<tema-em-slug>.md` (crie a pasta se não existir). Toda captura vive aqui, independente do tema. Se a sessão gerar um entregável polido (plano, mapa, especificação), esse artefato pode ir para `projetos/`; a captura bruta fica em `entrevistas/`.
   - Pegue a data real do sistema (`date +%F` no Bash, `Get-Date -Format yyyy-MM-dd` no PowerShell).
   - Nunca sobrescreva uma captura existente. Mesmo dia e tema: acrescente hora ou sufixo. Retome uma captura só se o usuário pedir ou se referir claramente a ela; nesse caso leia antes e continue a numeração.
   - Sem tema informado nem inferível: crie `entrevista-sem-tema` com objetivo pendente e pergunte o que explorar.
2. **Escreva o cabeçalho** de imediato: título, data, objetivo da sessão, seção "Pendências" vazia.
3. **Diga onde está salvando**, em uma linha. Aí faça a P1.

## A regra do checkpoint (inegociável)

Depois de CADA resposta, ANTES da próxima pergunta:

- Acrescente ao arquivo: o tema da pergunta, os fatos e decisões (nas palavras do usuário quando o fraseado importa), e pendências (o que ele não soube responder e quem saberia).
- Atualize o resumo corrente se uma resposta posterior mudar algo. Preserve a entrada original, marque como substituída e aponte para a correção.
- Releia o que salvou. Se a gravação falhar, avise e mantenha a resposta visível no chat; não diga que salvou nem continue sem checkpoint funcionando.
- Só então faça a próxima pergunta.

Nunca junte várias respostas em uma gravação só.

## Método

- **Uma pergunta por vez.** Para decisões, ofereça uma sugestão baseada no contexto, rotulada como sugestão. Para fatos pessoais ou de negócio, pergunte de forma neutra; não induza nem salve inferência sua como resposta dele.
- Mantenha distinguíveis: fato confirmado, ideia tentativa, sugestão sua, questão em aberto.
- Resolva dependências em ordem: decida o de cima antes do que depende dele.
- Se dá para responder lendo um arquivo ou o código, leia em vez de perguntar. Se o usuário entregar um documento, leia e pergunte só o que é novo.
- Quando o usuário **não souber**, registre como pendência com o responsável e siga. Não trave.
- Continue até o usuário dizer que acabou, pedir pausa, ou você ter coberto os ramos úteis. Parada explícita se respeita na hora. Perto do fim, ofereça o cheque de completude: "tem algo que a gente não tocou?".

## Estrutura do arquivo

```
# {Tema}: entrevista
Data: {data} · Objetivo: {uma linha}
Status: em andamento / pausada / concluída
Fontes de contexto: {páginas relevantes, se houver}

## Resumo e decisões
(síntese corrente, atualizada durante a sessão)

## Perguntas e respostas
### P1: {tema}
- Perguntado: {pergunta}
- Capturado: {fatos e decisões confirmados, nas palavras do usuário quando importa}
- Tentativo / sugerido: {ideias não confirmadas, rotuladas}
- Pendências: {item → quem responde}
...

## Pendências (aguardando)
- {item} → {quem pode responder}
```

## No fim ou na pausa

- Releia a captura procurando contradições e lacunas. Marque conflitos não resolvidos; não escolha um fato de negócio pelo usuário. Atualize status e ponto de retomada.
- Se a sessão foi explicitamente para **construir ou atualizar o contexto do cérebro**, leve os fatos e preferências confirmados para a página de contexto certa (`contexto/`, `conexoes.md`, `projetos/<x>/README.md`), com link datado para a captura. Preserve o que não mudou. Decisões relevantes vão para `decisoes/registro.md` sem duplicar. Ideias tentativas e sugestões suas ficam rotuladas na captura até serem confirmadas.
- Se foi uma entrevista sobre plano ou decisão sem pedido de atualizar contexto, a captura é o produto. Sugira `/vincular` para rotear um resultado útil ou `/evoluir` para transformar uma oportunidade em melhoria. Não rode nenhum dos dois por conta própria.
- Garanta que o manual roteia para `entrevistas/` (o modelo do kit já roteia). Capturas individuais não precisam de entrada no manual. Captura é evidência datada, não verdade atual automática.
- Feche com um resumo curto: caminho clicável da captura, páginas de contexto atualizadas, pendências restantes, próximo passo ou ponto de retomada.

## Limites

- Escopo: captura local e atualizações de contexto pedidas. Sem edição de memória global, publicação, mensagens ou mudanças em sistemas externos. Não peça nem salve credenciais.
- O kit ignora `entrevistas/` no git por padrão.
- Temas sugeridos para as primeiras sessões: prioridades do trimestre, equipe e responsabilidades, clientes e o que eles pedem, produtos e serviços, processos que se repetem, metas do ano, o que você quer parar de fazer.
