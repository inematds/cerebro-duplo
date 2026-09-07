# Histórico automático de auditorias

Leia no início de toda auditoria. Os relatórios datados são o histórico durável; cada novo relatório carrega os achados anteriores. `auditorias/historico.md` é o resumo de uma linha por auditoria. Não mantenha banco separado de notas nem dependa desta conversa.

## 1. Selecionar a evidência anterior

1. Localize `auditorias/` na raiz do cérebro. Olhe nomes e metadados primeiro, não o conteúdo inteiro de todas. A pasta pode ter outros tipos de auditoria (custo, código, segurança): não são linha de base.
2. Use `tipo: cerebro`, identidade do cérebro, data, status e versão da rubrica para escolher. Relatório antigo sem metadados: leia títulos e escopo, rotule como legado. Nunca chute notas, IDs ou datas de memória. Não altere arquivos históricos.
3. Leia o registro de achados do relatório aplicável mais recente e, se diferente, o relatório completo comparável mais recente. No máximo dois relatórios inteiros no início.
4. Compare notas só para o mesmo cérebro, mesma rubrica e escopo materialmente equivalente (runtimes, domínios, fluxos, sondagens). Cérebro diferente, rubrica diferente, amostra mais estreita ou mais larga, ou relatório parcial não sustentam um delta simples. Comparação por achado ainda pode valer.
5. Registre o link do relatório anterior e, separadamente, a linha de base de nota, se houver. Sem relatório elegível: **primeira linha de base registrada**.

## 2. Manter identidade e status dos achados

Cada achado novo ganha ID estável `A-AAAA-MM-DD-NN`. Preserve o ID nas rodadas seguintes, casando por rota ou fluxo afetado, runtime e modo de falha. Renomeações verificadas se registram, não viram achados duplicados. Classe (defeito, lacuna de verificação, oportunidade, diferença intencional), confiança na evidência e status de progresso são campos separados.

Carregue o registro completo do relatório anterior para o novo, inclusive itens fora da amostra de hoje e entradas compactas dos já fechados. Preserve datas de primeira observação e de última verificação. Item que ficou fora das três ações recomendadas não está fechado. Status:

| Status | Evidência necessária |
|---|---|
| Novo | Primeira observação neste histórico. Diga "detectado agora", não "introduzido agora", a menos que a evidência anterior prove |
| Ainda aberto | Rechecado e o defeito ou lacuna permanece, ou a oportunidade confirmada continua pendente |
| Resolvido | O critério de conclusão original passa com evidência atual. Edição proposta, timestamp alterado, cópia instalada ou sucesso autodeclarado não resolvem |
| Reaberto | Antes resolvido; a mesma falha se demonstra de novo. Mantenha o ID e cite o fechamento anterior |
| Não rechecado | Não coberto, inacessível ou evidência insuficiente hoje. Preserve o último estado verificado |
| Não se aplica mais | Requisito mudou, fluxo aposentado, ou outra mudança de escopo evidenciada. Não é conserto |

Achado antes resolvido e não checado hoje é `Não rechecado` com último estado `Resolvido`, não defeito reaberto. Suspeita anterior desmentida: registre a correção e a evidência; não chame de conserto nem apague a observação antiga.

Para cada achado: ID, classe, alvo e runtime, primeira observação, status anterior, status atual, data e estado da última verificação, evidência, critério de conclusão.

## 3. Explicar o progresso com honestidade

Tabela compacta e narrativa curta:

| ID | Estado anterior | Esta rodada | Evidência / mudança prática | Próxima checagem |
|---|---|---|---|---|

- Separe **consertos reais**, **evidência nova**, **regressões** e **mudanças de escopo ou rubrica**. Mais logs podem justificar mais crédito sem melhoria do sistema; defeito recém-descoberto pode baixar a nota sem regressão recente.
- Comparação válida de nota: mostre os quatro subtotais, brutos, tetos e finais anterior e atual, e qual evidência de critério mudou. Senão, diga **notas não diretamente comparáveis** e por quê.
- Mostre contagens de achados por status. Não afirme melhoria só porque a nota subiu ou a contagem de abertos caiu.

## 4. Salvar cada rodada com segurança

1. Use o [modelo](modelos/relatorio.md). Nome do arquivo: `auditorias/AAAA-MM-DD-HHMM.md` (hora local). Se já existir, acrescente sufixo. Nunca substitua uma rodada anterior do mesmo dia.
2. Preencha todas as seções com evidência real ou explicação explícita de não checado / parcial. Mantenha a conta completa dos critérios, o registro atual de achados, links dos anteriores e os critérios de conclusão. Sem placeholder de exemplo, sem resultado inventado.
3. Releia o relatório salvo: metadados, links, conta, IDs e status, redação de segredos, coerência com o que foi dito no chat.
4. Acrescente uma linha em `auditorias/historico.md` (crie com o cabeçalho abaixo se não existir), **mais recente no topo**:

```
# Histórico de auditorias

| Data | Relatório | Contexto | Conexões | Capacidades | Cadência | Bruto | Final | Estágio | Principal achado |
|---|---|---|---|---|---|---|---|---|---|
```

5. Se a auditoria parar no meio, salve com `status: parcial`, notas indisponíveis como `null`, motivo e achados não checados carregados. Parcial não é linha de base.
6. Se não conseguir gravar, diga **relatório não salvo**, entregue no chat e descreva o bloqueio. Não salve em outro lugar em silêncio nem afirme que o histórico foi atualizado. Pedido explícito para não salvar prevalece: diga **não salvo a seu pedido**.

O cérebro permanece inalterado além do relatório novo e da linha no histórico. Não acrescente entrada em `decisoes/registro.md` a cada auditoria nem atualize os manuais automaticamente. Relatório é evidência de um momento, nunca fato canônico atual.
