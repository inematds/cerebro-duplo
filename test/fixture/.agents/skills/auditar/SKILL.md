---
name: auditar
description: Audita o segundo cérebro com evidências: pontua os 4 pilares (Contexto, Conexões, Capacidades, Cadência) de 0 a 100, testa as rotas do manual, confere AGENTS.md e CLAUDE.md, e salva relatório datado em auditorias/ com histórico de notas. Use quando o usuário disser "auditar", "auditoria", "qual minha nota", "checa meu cérebro", "audit", "o que está faltando", ou semanalmente durante a construção.
---

# Auditar

Responda a uma pergunta: **este cérebro acha a informação certa e faz trabalho útil de forma confiável?** Pontue **Contexto, Conexões, Capacidades e Cadência, 25 pontos cada**, pela [rubrica](rubrica.md). A nota mede **confiabilidade verificada**, não utilidade geral. Pasta criada, skill instalada, chave configurada ou afirmação confiante **não é prova** de sistema funcionando.

Rode localmente, no cérebro atual. Sem subagentes, a menos que o usuário peça. A auditoria é **somente leitura**: não conserta, não move, não instala, não muda agendamento, não envia nada. Sua única escrita é o relatório novo em `auditorias/` e a linha nova em `auditorias/historico.md`. Depois, `/vincular` conserta rota e `/evoluir` fecha lacuna.

Nunca infle nem deprima a nota para motivar outra rodada. A nota sobe quando a evidência melhora.

## 1. Escopo e evidência

- Pegue a data real e a raiz do cérebro. Leia `AGENTS.md` e `CLAUDE.md`. Compare: o kit promete que são idênticos. Diferença de conteúdo é achado.
- Leia [historico.md](historico.md) e o relatório anterior mais recente em `auditorias/` (se houver) antes de escolher as sondagens. Recheque os achados importantes anteriores; não assuma que continuam válidos.
- Siga o mapa de rotas do manual primeiro. Leia `projetos/README.md` e `wiki/index.md` antes de listar pastas. Ignore dependências, caches, saídas geradas e `arquivo/`, a menos que uma rota aponte para lá.
- Identifique, a partir do contexto real: função do usuário, objetivo, prioridades atuais e até três fluxos de trabalho importantes. Placeholder `{{...}}` não preenchido não conta. Não exija dado de receita de quem não tem função de receita.
- Inspecione `.claude/skills/` e `.agents/skills/`, `conexoes.md`, `referencias/*-api.md`, `rotinas/registro.md`, e configurações reais de agendamento.
- Classifique cada achado como **verificado**, **documentado mas não verificado**, **ausente**, **desatualizado** ou **conflitante**, com arquivo e linha, ou data de execução. Data de modificação de arquivo não prova execução.
- Se faltar tempo para verificar algo, marque como não verificado e diga a cobertura. Nunca dê pontos por falta de tempo para checar.

## 2. Testar rotas e recuperação de contexto

Monte um mapa compacto: **necessidade → manual/índice → fonte específica → regra de frescor**. Compare com as pastas reais: projetos sem rota, contagens velhas, caminhos quebrados, duas fontes para a mesma verdade, material aposentado tratado como ativo.

Siga as rotas declaradas para estas cinco perguntas, adaptadas ao trabalho real do usuário:

1. O que esta pessoa faz, para quem, e o que importa agora?
2. Onde está a prioridade, o compromisso ou o status atual com autoridade, e como eu verificaria?
3. Onde está o entregável mais recente e o próximo passo de um projeto ativo importante?
4. Onde está uma decisão anterior, uma lição, ou um item de conhecimento específico, e a fonte que o sustenta?
5. Onde está um registro externo, ativo ou documento original de uso comum, e como se acessa?

Para cada uma: pergunta, rota tentada, fonte, resultado, e se foi achado **direto pela rota**, **só por busca ampla**, ou **não achado**. Busca ampla que acha não prova que a rota funciona.

Frescor e autoridade: contexto estável pode viver na wiki; métrica e status atuais devem resolver para um sistema vivo ou exportação datada. Verifique datas e sinalize conflitos. Um cache ou resumo "quente" não ganha ponto por existir; verifique se duplica páginas canônicas e se tem mecanismo real de atualização. Cheque se uma sessão nova entenderia o usuário e retomaria o projeto sem depender desta conversa. Manual compacto e certo vale mais que manual longo.

## 3. Verificar os outros três pilares

Primeiro, a [checagem de compatibilidade](compatibilidade.md): rotas quebradas, trabalho sem rota, diferenças entre os dois manuais, skills presentes nos dois runtimes.

**Conexões:** liste os domínios aplicáveis (finanças, clientes, agenda, comunicação, tarefas, reuniões, conhecimento; acrescente outros se forem materiais). Para cada um: relevância, mecanismo, rota de acesso, **evidência de leitura bem-sucedida com data**, limitações. MCP configurado ou chave no `.env` não estabelece autenticação. Use leituras seguras e estreitas quando disponíveis, ou evidência datada dentro do intervalo esperado (sem intervalo documentado, 30 dias). Não imprima segredos nem registros privados em massa. Não rode script desconhecido sem checar efeitos colaterais.

**Capacidades:** escolha até três fluxos ligados às prioridades, não os mais bonitos. Examine gatilho, entradas, destino da saída, exemplos de saída real, verificação, tratamento de falha, uso repetido. Fluxo faltante para uma prioridade permanece como lacuna. Quantidade e complexidade de skills não ganham bônus. Não dispare fluxo pago só para auditar.

**Cadência:** inspecione `rotinas/registro.md`, agendamentos reais, hooks, e as execuções registradas. Para cada rotina: host, gatilho, saída esperada, última execução devida, evidência de sucesso ou falha, como parar. Skill chamada `diaria-*`, modelo, ou arquivo recente não estabelece cadência. Ritual manual útil ganha crédito limitado e é rotulado como manual.

## 4. Pontuar e priorizar

Leia a [rubrica](rubrica.md) inteira. Atribua os 20 critérios, aplique os tetos. Mostre os quatro subtotais, a soma bruta, cada teto aplicado e por quê, a nota final e o estágio. Distinga **não verificado** de **quebrado**.

Ordene as lacunas pelo efeito no trabalho do usuário: resposta errada ou velha e fonte inacessível vêm antes de arrumação cosmética. Dê até três consertos concretos, cada um com rota ou fluxo afetado, evidência e critério de conclusão. Não invente três defeitos em um sistema saudável. Distinga conserto de verificação.

Agrupe em **defeitos confirmados**, **lacunas de verificação** e **oportunidades**; diferenças intencionais à parte. Dê a cada achado um ID estável (`A-<data>-01`) e reutilize entre seções e auditorias.

## 5. Relatório

Estrutura, com o registro de evidências compacto:

1. **Auditoria: data, cérebro, rubrica v1.** Escopo, runtimes, limites de verificação, conclusão em linguagem simples. Comece pelo que funciona e pela discrepância mais importante.
2. **Achados em AGENTS.md / CLAUDE.md:** seção obrigatória, mesmo sem problemas (veja abaixo).
3. **Compatibilidade e rotas:** matriz e achados de [compatibilidade.md](compatibilidade.md).
4. **Sondagens de rota:** as cinco, com fonte e status direto / busca / não achado.
5. **O que funciona:** até três pontos fortes com evidência.
6. **Confiabilidade verificada:** quatro linhas `/25`, soma bruta, tetos, final `/100`, estágio. IDs de critério e pontos, para a conta ser reproduzível.
7. **Principais melhorias:** até três, rotuladas conserto / verificar / opcional, com evidência, próxima ação exata, benefício e o que provaria conclusão.
8. **Progresso desde a auditoria anterior:** link do relatório base, transições dos achados, explicação de mudança de nota. Separe conserto real, evidência nova, regressão, mudança de escopo. Sem relatório comparável, é linha de base nova, não melhoria.
9. **Próxima rodada:** um prompt pronto para `/evoluir` com a lacuna mais valiosa, evidência e critério de aceite. `/vincular <alvo> <uso>` para conserto só de rota. `/entrevista` para contexto genuinamente faltante.
10. **Registro salvo:** escreva o relatório com o [modelo](modelos/relatorio.md), releia e linke o arquivo salvo. Acrescente a linha em `auditorias/historico.md`. Nunca diga "salvo" sem confirmar.

### Seção obrigatória: achados em AGENTS.md / CLAUDE.md

Nomeie os manuais inspecionados. Marque cada um como **verificado**, **ausente** ou **não verificado**. Diga se são idênticos, se conflitam, ou se diferem de propósito. Tabela:

| Arquivo e seção/linha | Regra ou rota faltante | Achado e efeito prático | Mudança recomendada |
|---|---|---|---|

Separe **problema no manual** de **problema no arquivo para onde ele aponta**. Inclua uma frase sobre o que os manuais já fazem bem. Sem problemas: diga "Nenhum problema de manual no escopo inspecionado" e os limites de cobertura. Termine dizendo se algum manual foi alterado (em auditoria padrão: **"Nenhum manual foi alterado."**).

## Depois

Recomende rodar `/auditar` de novo após o conserto escolhido e semanalmente durante a construção, depois em intervalo de manutenção. Compare notas só quando escopo e rubrica coincidem. Nota pode cair quando a evidência envelhece. Não prometa nota maior só por rodar de novo.

Se a auditoria parar no meio, salve um relatório marcado como parcial, sem nota inventada. Se não conseguir gravar, diga **relatório não salvo**, entregue no chat e explique o bloqueio. Pedido explícito para não salvar prevalece.
