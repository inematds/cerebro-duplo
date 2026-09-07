---
name: wiki
description: Transforma material bruto de fontes/ (transcrições, documentos, exportações, notas) em páginas de wiki interligadas em wiki/, com índice e log mantidos pelo agente. Também consulta e revisa a wiki. Use quando o usuário disser "wiki", "cria a wiki", "ingere isso", "processa as fontes", "consulta a wiki", "revisa a wiki", "LLM wiki", ou quiser relações entre pessoas, projetos, reuniões e decisões.
argument-hint: "ingerir [caminho] | consultar <pergunta> | revisar"
---

# Wiki

A wiki é a camada interpretada do cérebro. `fontes/` guarda o bruto e nunca muda. `wiki/` guarda páginas escritas e mantidas por você, o agente, com links explícitos entre elas. O ganho é a **relação**: uma pessoa aparece ligada aos projetos em que está, às reuniões de que participou e às decisões que tomou. Sem isso, o cérebro é um depósito.

A ideia segue o método de wiki mantida por LLM popularizado por Andrej Karpathy: o humano traz as fontes e faz perguntas; o modelo escreve, liga e mantém as páginas.

Três operações. Descubra qual pelo `$ARGUMENTS` ou pela conversa. Sem argumento, pergunte qual.

## Estrutura (crie na primeira vez se não existir)

```
wiki/
├── README.md        ← convenções (já vem no kit)
├── index.md         ← uma linha por página: [[nome]] · tipo · resumo de uma frase · atualizado
├── log.md           ← cronológico: o que foi ingerido, criado, revisado (mais recente no topo)
├── entidades/       ← pessoas, empresas, produtos, ferramentas
├── conceitos/       ← temas, métodos, ideias recorrentes
└── fontes/          ← uma página-resumo por fonte bruta processada
```

Cabeçalho de toda página:

```
---
tipo: entidade | conceito | fonte
atualizado: AAAA-MM-DD
fontes: [caminho da fonte bruta 1, caminho 2]
---
```

Links entre páginas: `[[nome-da-pagina]]` (nome do arquivo sem `.md`). Nomes em slug: minúsculas, hífens, sem acento.

## Operação 1: ingerir

Entrada: um arquivo, uma pasta, ou nada (então processa tudo em `fontes/` que ainda não está em `wiki/log.md`).

Para cada fonte:

1. Leia a fonte inteira. Fonte muito grande: leia em partes, mas não pule partes.
2. Crie `wiki/fontes/<AAAA-MM-DD>-<slug>.md`: o que é a fonte, resumo de 5 a 15 linhas, os fatos e decisões que ela contém (com data quando for fato que muda), e links `[[...]]` para cada entidade e conceito relevante.
3. Para cada entidade e conceito mencionado: se a página existe, **atualize** (acrescente o que a fonte diz, com a data e o link para a página-fonte). Se não existe, **crie** com o que a fonte permite afirmar. Não invente para preencher.
4. Conflito com o que a wiki já dizia: anote na página em uma seção "Conflitos", com as duas versões, fontes e datas. Não resolva em silêncio. Se uma fonte for claramente mais recente, diga que ela parece prevalecer, e por quê.
5. Atualize `index.md` (uma linha por página nova ou alterada) e `log.md` (uma entrada por fonte: data, fonte, páginas criadas, páginas atualizadas, conflitos).

Depois do lote, releia `index.md`: nomes duplicados, páginas sem nenhum link de entrada, links `[[...]]` sem página. Corrija o que der; liste o resto no log.

Regra de ouro: **fatos com fonte**. Cada afirmação em uma página aponta para a página-fonte que a sustenta. Se não tem fonte, é hipótese, e fica rotulada.

## Operação 2: consultar

Entrada: uma pergunta.

1. Leia `wiki/index.md` e escolha as páginas relevantes. Leia-as. Siga `[[links]]` quando fizer diferença.
2. Responda com base na wiki, citando as páginas e as fontes brutas de origem. Fato datado leva a data.
3. Se a wiki não cobre, diga. Ofereça olhar em `fontes/` direto ou fazer uma `/entrevista`.
4. Se a consulta produziu uma síntese útil que não existia (uma comparação, uma linha do tempo), pergunte se o usuário quer salvá-la como página de conceito. Se sim, salve e registre no log.

## Operação 3: revisar

Sem entrada. Higiene periódica.

1. Páginas órfãs (sem link de entrada) → ligue de onde faz sentido ou marque no log.
2. Links quebrados → crie a página faltante (se há material) ou corrija o link.
3. Páginas com `atualizado` há mais de 90 dias que tratam de fato que muda (números, prazos, status) → liste como "possivelmente desatualizadas" no log e pergunte ao usuário se quer atualizar.
4. Conflitos abertos → liste e pergunte ao usuário qual versão vale. Registre a decisão na página e em `decisoes/registro.md` se for relevante.
5. Fontes em `fontes/` que nunca foram ingeridas → liste e ofereça ingerir.
6. Escreva o resultado da revisão no log.

## Limites

- Nunca edite nada em `fontes/`.
- Não copie fontes inteiras para a wiki. Resuma, extraia, ligue. A fonte continua sendo a fonte.
- Não crie página para cada nome que aparece. Entidade merece página quando aparece em duas fontes ou tem papel no trabalho do usuário.
- Sem segredos na wiki (chaves, senhas, dados sensíveis de terceiros). Se a fonte tiver, registre que existe e onde, sem reproduzir.
- Uma wiki por cérebro. Se o usuário quiser separar por assunto (ex.: vídeos, reuniões, negócio), use subpastas dentro de `wiki/` com o próprio `index.md`, e o `index.md` da raiz aponta para elas.
- Depois de uma ingestão grande, sugira `/cerebro-3d` para ver as relações.
