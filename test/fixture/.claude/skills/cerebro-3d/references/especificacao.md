# Especificação do cérebro 3D portátil

Este pacote preserva um aplicativo funcionando em vez de depender de uma recriação por prosa. O runtime portátil tem uma camada de ingestão configurável e o mesmo renderizador esférico, planejador de crescimento, cena orbital e comportamento de interação da implementação de referência.

## Arquivos e contratos

- `assets/template/config.mjs`: valida nome, IDs de categoria, caminhos, cores e limites.
- `assets/template/build.mjs`: lê só as fontes locais selecionadas; cria nós, arestas baseadas em evidência, sinalizações de saúde, inventário e um registro interno de arquivos.
- `assets/template/serve.mjs`: servidor Node sem dependências. Só loopback; ativos estáticos em lista de permissão. IDs de nota resolvem pelo registro de arquivos, nunca por caminho arbitrário na URL.
- `assets/template/codex-memory.mjs`: importador somente leitura da memória curada do Codex, com limites exatos de seção.
- `assets/template/src/app.js`: busca, interações do grafo, controles de fonte, painéis, renderização sanitizada de notas, cinema e reprodução do crescimento.
- `assets/template/src/constellation.js`: posicionamento esférico determinístico, orbe central e acentos orbitais discretos.
- `assets/template/src/growth.js`: floresta geradora usando só arestas existentes, ramificação limitada por passo, movimento de mola e posições finais exatas.
- `assets/template/dist/app.js`: renderizador pré-compilado. Não é preciso instalar pacotes para rodar o app gerado.
- `scripts/discover.mjs`: lista caminhos candidatos sem ler o conteúdo.
- `scripts/scaffold.mjs`: copia uma lista explícita de arquivos para uma pasta nova, recusa substituição e escreve a configuração local.

## Contrato visual e de interação

Espaço quase preto, uma cor por categoria, silhueta esférica de qualquer ângulo, orbe central de arame e duas trilhas orbitais discretas. Partículas brancas acentuam caminhos selecionados; links de fundo são amostrados. Rótulos têm detecção de colisão e limpeza explícita quando nós são removidos ou reconstruídos.

O crescimento começa com um nó no orbe e a primeira aresta real. Nós novos brotam dos seus nós-pai reais; uma fila de ramificação limitada cria crescimento para fora, não uma explosão a partir de um único centro. O crescimento acelera, termina em cerca de 29 segundos, devolve cada nó à sua posição determinística no globo e oferece repetição. Componentes desconectados têm raízes independentes.

Órbita e zoom da câmera continuam funcionando durante o crescimento. A entrada do usuário assume o lugar do recuo automático sem parar a linha do tempo. O orbe está presente desde o primeiro quadro; os anéis surgem e se expandem depois. O cinema coloca o contador ao lado do globo. Preferência por movimento reduzido produz um estado final estático em vez de movimento forçado.

A visão geral desenha caminhos amostrados. A seleção mostra até 72 caminhos e 24 caminhos com partículas; as contagens completas ficam no inventário. Rótulos padrão limitados a um centro por categoria e uma vizinhança selecionada pequena. Layouts móveis mantêm os filtros pelo botão Fontes.

## Integridade dos dados e limites

IDs incluem categoria e identidade do arquivo, então nomes de arquivo duplicados não colidem. Wikilinks só resolvem quando inequívocos. Links explícitos de arquivo têm precedência sobre inferência por menção. Menções por título completo são rotuladas à parte e não são afirmação de certeza semântica. A reprodução representa conectividade, nunca datas de criação inventadas.

Sem conteúdo de usuário, grafo, credenciais, chaves de API, exportações reais de memória ou caminhos absolutos da máquina de alguém dentro do pacote. Configurações de usuário e dados gerados ficam locais e ignorados pelo git. A skill não promete publicação, formato universal, histórico exato ou viralidade.
