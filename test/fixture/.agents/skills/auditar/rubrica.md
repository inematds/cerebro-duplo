# Rubrica dos 4 pilares, v1

## Regras de pontuação

Cinco critérios por pilar, 5 pontos cada. Use **só 0, 1, 3 ou 5**: o maior patamar totalmente sustentado por evidência. **0** significa ausente, contradito, ou sem evidência nem para 1 ponto. Patamares maiores exigem o que os menores pedem. Não interpole, não comece do máximo descontando, não dê ponto por infraestrutura irrelevante, não substitua evidência por otimismo.

Amostra limitada prova o critério amostrado, não o sistema inteiro: nomeie a amostra e o escopo não resolvido. Se não há fluxos ou conexões relevantes para amostrar, os critérios que dependem deles ficam em 0, não "completos por vacuidade". Documentação pode valer 1 onde indicado; não é resultado funcionando.

## Contexto: uma sessão nova entende e recupera? (25)

| ID | Critério | 1 ponto | 3 pontos | 5 pontos |
|---|---|---|---|---|
| C1 | Contexto personalizado | Identidade e propósito existem, sem placeholder | Identidade, público, prioridades e preferências de colaboração têm fontes específicas e usáveis | Tudo isso é consistente entre as fontes atuais amostradas, com prioridades concretas e expectativa clara de "pronto" |
| C2 | Rotas e achabilidade | O manual dá pelo menos uma rota específica usável | Pelo menos 3 das 5 sondagens acham pela rota declarada; índices de projetos e conhecimento existem onde precisam | As 5 acham pela rota; comparação com as pastas reais não revela omissão importante nem rota quebrada |
| C3 | Frescor | Fatos que mudam têm fonte e data | Fatos amostrados têm regra de atualização e evidência atual, ou são explicitamente históricos com rota para a fonte atual | Todos os fatos atuais amostrados verificados dentro do intervalo esperado; caches, se existem, são consistentes e mantidos |
| C4 | Autoridade da fonte | Pelo menos uma fonte canônica identificada | Regras distinguem contexto estável, status atual e registros originais; afirmações amostradas apontam para fonte | Todas as cadeias amostradas resolvem; duplicatas têm papéis explícitos; sem conflito material fonte × manual |
| C5 | Continuidade | Existe um registro real de decisão ou de estado de projeto | O projeto ativo amostrado tem entregável atual, razão da decisão e próximo passo acessíveis pelo ponto de entrada | Um segundo projeto ou fio de conhecimento também se retoma a partir de registros duráveis |

Não é exigido cache, layout específico de wiki, manual longo ou número de projetos. Cérebro de projeto único: o "segundo fio" de C5 pode ser uma decisão anterior distinta do mesmo projeto.

## Conexões: alcança a informação de que precisa? (25)

Inventarie os domínios aplicáveis antes de pontuar. Marque os irrelevantes com motivo ligado à função do usuário. Não premie conectar ferramenta que o usuário não usa.

| ID | Critério | 1 ponto | 3 pontos | 5 pontos |
|---|---|---|---|---|
| N1 | Acesso aos domínios relevantes | Pelo menos um domínio relevante tem leitura bem-sucedida, mas menos da metade | Metade ou mais (não todos) dos domínios aplicáveis têm leitura bem-sucedida | Todos os domínios aplicáveis têm leitura bem-sucedida dentro do intervalo esperado |
| N2 | Recuperação útil | Uma consulta específica e a resposta esperada estão documentadas | Uma consulta real ligada a prioridade devolve o registro certo, com intervalo de datas e fonte | Duas consultas distintas ligadas a prioridade devolvem resultados adequados, com paginação ou limites de exportação verificados |
| N3 | Rotas de acesso reproduzíveis | Uma conexão tem caminho de ferramenta ou script e propósito documentados | Todos os domínios aplicáveis têm rota documentada ou status explícito de "não conectado"; rotas conectadas têm instruções seguras de autenticação e exemplos | A rota amostrada é reproduzida sem depender do contexto do chat; todos os domínios conectados têm guia usável |
| N4 | Limites de ação adequados | Escopos de leitura e escrita e limites de aprovação estão documentados | Para um fluxo de escrita necessário, há registro de escrita autorizada bem-sucedida ou teste em sandbox; ou o escopo somente-leitura é deliberado e verificado | Operações amostradas respeitam as permissões pretendidas e têm proteção verificada contra falha e duplicidade. Não faça escrita ao vivo para ganhar ponto |
| N5 | Frescor e visibilidade de falha | Timestamps e expectativas de frescor documentados | Leituras amostradas estão dentro da expectativa e falhas aparecem em vez de serem substituídas por dado velho sem rótulo | Todo domínio aplicável tem sucesso recente e tratamento demonstrado de autenticação expirada ou dado velho em pelo menos uma conexão |

Um só domínio aplicável com leitura bem-sucedida satisfaz N1 em 5, não os outros critérios automaticamente. Arquivo local ou exportação satisfaz um domínio quando é a fonte real e suficientemente atual. Sem bônus por quantidade de MCPs, chaves ou acesso de escrita que o usuário não precisa.

## Capacidades: os fluxos relevantes produzem resultado usável? (25)

Até três fluxos ligados às prioridades, escolhidos antes de olhar as saídas. Um só fluxo: avalie honestamente; não exija skills desnecessárias. Prioridade sem fluxo: mantenha a lacuna na amostra.

| ID | Critério | 1 ponto | 3 pontos | 5 pontos |
|---|---|---|---|---|
| P1 | Encaixe e invocação | Um fluxo tem gatilho claro ligado a uma necessidade declarada | Um fluxo amostrado tem invocação bem-sucedida com as entradas pretendidas | Todos os fluxos amostrados têm evidência de invocação bem-sucedida, com fronteiras claras entre gatilhos que se sobrepõem |
| P2 | Qualidade da saída | Existe exemplo de saída e critério de aceite | Uma saída real foi conferida contra critério de aceite significativo | Todos os fluxos amostrados têm saída usável verificada contra critério, não só "concluído" autodeclarado |
| P3 | Tratamento de falha | Casos de entrada faltante e efeitos colaterais estão documentados | Pelo menos um caso de entrada faltante, fonte velha ou dependência caída foi testado e tratado | Todo fluxo amostrado tem resultado de caso-limite relevante e respeita limites de autorização e efeito colateral |
| P4 | Portabilidade e descoberta | Arquivos, dependências e rota de invocação documentados | Pontos de entrada, referências e registros no runtime resolvem; espelho `.agents/skills` corresponde | Uma execução limpa registrada reproduz o fluxo sem estado oculto da conversa nem dependência não documentada |
| P5 | Uso real repetido | Pelo menos um uso real datado evidenciado | Um fluxo amostrado tem dois usos reais bem-sucedidos com referência às saídas | Todos os fluxos amostrados têm usos reais repetidos; correções estão refletidas na versão atual e validadas |

Quantidade de skills e recência de arquivo valem zero por si. Script determinístico ou prompt simples pode pontuar tanto quanto um agente complexo. Skill nova não prova uso repetido rodando teste sintético duas vezes.

## Cadência: trabalho útil acontece de forma confiável ao longo do tempo? (25)

Use agendamentos reais e horários devidos. Ritual manual é útil, mas não é execução sem supervisão. Configuração não estabelece execução.

| ID | Critério | 1 ponto | 3 pontos | 5 pontos |
|---|---|---|---|---|
| D1 | Gatilho real | Existe ritual humano explícito ou configuração real de agendador | Pelo menos um gatilho habilitado tem host verificado e saída esperada | Esse gatilho comprovadamente rodou no ambiente pretendido, sem supervisão, com os requisitos de runtime disponíveis |
| D2 | Execuções devidas | Uma conclusão manual datada ou uma tentativa automática incompleta registrada | Uma execução automática devida concluiu com a saída esperada | Duas ou mais execuções automáticas devidas distintas concluíram; sem execução perdida não explicada no período |
| D3 | Observabilidade | Registro de status e comportamento de notificação de falha documentados | Execuções inspecionadas têm timestamps duráveis, resultado e caminho verificado de reporte de falha | Uma falha real ou simulada com segurança chegou ao mecanismo de reporte, e a recuperação está evidenciada |
| D4 | Controle e recuperação | Existem instruções de parar, dono, permissões e recuperação | Configuração confirma esses controles e proteção contra duplicidade | Teste anterior ou isolado demonstra parada, recuperação e prevenção de duplicidade sem efeito colateral |
| D5 | Ciclo de manutenção | Frequência de revisão e responsabilidades de limpeza definidas | Uma revisão concluída consertou um problema real ou verificou que nada era necessário, com evidência | Dois ciclos de revisão registrados, com verificação dos consertos e rotas e contexto mantidos |

Não dispare jobs, não mude agendamentos, não envie alertas de teste nem desligue automação durante a auditoria. Sistema só manual: **máximo 10/25 em Cadência**, mesmo com disciplina forte. Rotina recém-habilitada espera a evidência de execução devida; dois testes manuais seguidos não são duas execuções devidas.

## Tetos e estágios

1. Some os critérios de cada pilar. Se as cinco sondagens não recuperam nem o propósito principal do usuário nem uma fonte de prioridade ou status com autoridade, **Contexto fica limitado a 10**. Mostre o subtotal bruto e o teto.
2. Aplique o teto de 10 em Cadência quando nenhum gatilho automático estiver verificado (inclui sistema sem gatilho nenhum). O teto nunca dá ponto.
3. Some os quatro subtotais: **total bruto**.
4. Aplique todos os tetos relevantes; o menor vence:
   - Algum pilar abaixo de 10: total limitado a **49**.
   - Algum pilar abaixo de 15, ou menos de duas execuções automáticas devidas verificadas: limitado a **69**.
   - Algum pilar abaixo de 20, ou conflito material não resolvido de rota ou autoridade: limitado a **84**.
5. Nota final = mínimo entre total bruto e tetos. Explique cada teto aplicado. Nunca altere a conta em silêncio.

| Nota final | Estágio |
|---|---|
| 0 a 24 | Não comprovado |
| 25 a 49 | Fundação |
| 50 a 69 | Funcionando, com lacunas |
| 70 a 84 | Confiável no escopo verificado |
| 85 a 100 | Mantido e comprovado |

Nunca chame uma nota alta de "autônomo", "seguro" ou "completo" em geral. Diga o que foi amostrado. Evidência desconhecida é lacuna de verificação, não prova de que está quebrado. Os tetos existem para uma biblioteca grande de skills não compensar conexões e cadência ausentes.

## Calibração

- Template recém-instalado, skills com nome "diaria", chaves de API e arquivos recentes: sem crédito de execução, saída ou acesso a domínio. Instalação limpa fica em Não comprovado, não pula para 70.
- Manual personalizado, boas referências, 60 skills e 10 agentes, mas nenhuma saída ou execução observada: presença não dá Capacidades nem Cadência cheias.
- Contexto, Conexões e Capacidades em 25 cada e Cadência só manual em 10: bruto 85, final 69.
- Todos os pilares em 21 com duas execuções devidas e sem conflito: bruto e final 84. Em 23 cada, nas mesmas condições: 92.
- Cache velho obrigatório que contradiz a fonte canônica reduz frescor e autoridade e impede nota acima de 84 até resolver. Ausência de cache não penaliza.
- Rotina mensal com duas execuções devidas evidenciadas ganha crédito de repetição; job diário recém-configurado sem execuções, não.
