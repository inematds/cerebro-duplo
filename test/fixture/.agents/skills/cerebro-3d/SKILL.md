---
name: cerebro-3d
description: Gera um globo 3D interativo e local com o conhecimento salvo no segundo cérebro (contexto, wiki, projetos, reuniões, memória do agente), com busca, leitura de notas, sinalização de páginas velhas ou órfãs, modo cinema e animação de crescimento. Use quando o usuário disser "cérebro 3D", "cerebro 3d", "3d brain", "visualizar meu cérebro", "ver o grafo do conhecimento", ou rodar /cerebro-3d.
disable-model-invocation: true
argument-hint: "[nome do cérebro] [categorias ou pasta do app existente]"
---

# Cérebro 3D

Transforme os arquivos reais do cérebro do usuário em um globo 3D local e personalizado. Use o aplicativo pronto que acompanha esta skill; não reinvente a aparência. Preserve a composição esférica, as categorias coloridas, o orbe central, as partículas discretas, o modo cinema e a animação de crescimento.

Comando: `/cerebro-3d` no Claude Code, `$cerebro-3d` no Codex. A frase "cérebro 3D" em linguagem natural significa a mesma coisa. Entrada: `$ARGUMENTS` e a conversa. Tudo roda no assistente atual, sem subagentes, serviços externos, chaves de API ou publicação.

## 1. Localizar o cérebro e o pacote

Leia `AGENTS.md` / `CLAUDE.md` e o índice de projetos. Estabeleça a raiz real do cérebro; não varra uma pasta acima nem a home inteira do usuário. Resolva a pasta desta skill a partir do `SKILL.md` carregado; os caminhos abaixo são relativos a ela, esteja em `.claude/skills`, `.agents/skills` ou outro lugar.

Leia a [especificação](references/especificacao.md) e o [guia de configuração](references/configuracao.md). Confira Node.js 22 ou superior (`node --version`). Se não houver Node, explique que é necessário e siga a política do host para instalação.

Rode a descoberta de caminhos (lista pastas, não lê conteúdo):

```text
node <pasta-da-skill>/scripts/discover.mjs --root <raiz-do-cerebro>
```

Use também as rotas do manual para achar pastas personalizadas (wiki, reuniões, vídeos, projetos). Não assuma que existe pasta com nome de outra pessoa nesta máquina.

## 2. Perguntar nome e categorias

Use a ferramenta de pergunta do host se existir; senão pergunte em texto. Reaproveite o que já foi dito; não repita pergunta respondida.

1. **Nome:** "Como você quer chamar o seu cérebro 3D?" Aceite o nome exato, como "Cérebro da Maria", "Atlas" ou "Mente do Estúdio". Não escolha um nome por conta própria. Um argumento passado já responde.
2. **Categorias:** "Quais categorias principais você quer ver?" Ofereça as que foram realmente encontradas, cada uma ao lado do caminho proposto. Exemplos: Contexto, Wiki, Projetos, Reuniões, Entrevistas, Memória do Claude, Memória do Codex, Skills. O usuário pode renomear, tirar ou adicionar. Sugira de três a sete para clareza visual; aceite de uma a doze.

A resposta de categorias aprova os caminhos listados. Para categoria personalizada sem caminho conhecido, pergunte onde vivem os arquivos. Não chute raízes de memória externa. A memória do Codex pode cobrir vários projetos; diga isso ao oferecer. A memória do Claude deve apontar para a pasta de memória deste cérebro, não para todos os projetos.

Mostre o mapeamento compacto nome / categoria / caminho e siga construindo sem pedir outra confirmação genérica. Pergunte só sobre caminho não resolvido, substituição de app existente, ou outra ambiguidade material.

## 3. Montar o app

Saída padrão: `<raiz>/apps/cerebro-3d/`. Se já existir, leia o `brain.config.json` e reaproveite. Não sobrescreva às cegas. Para substituição pedida, mova a versão anterior para `arquivo/` dentro do próprio cérebro. Se a pasta tiver arquivos não relacionados, escolha outra ou pergunte.

Crie um JSON de configuração em uma pasta de rascunho ignorada dentro do cérebro, com o esquema do [guia de configuração](references/configuracao.md). Sem corpo de notas. Caminhos relativos para fontes dentro do cérebro; caminhos explícitos aprovados para fontes externas. Cada categoria com ID único, rótulo, cor, adaptador e um ou mais caminhos reais.

```text
node <pasta-da-skill>/scripts/scaffold.mjs --root <raiz> --config <config.json> --out apps/cerebro-3d
```

Isso copia uma lista explícita de arquivos do app e escreve a configuração local. Recusa destino existente. O renderizador vem pré-compilado: `node serve.mjs` funciona sem `npm install`. Não copie `node_modules`, configuração de outro usuário, grafo gerado, capturas de tela, arquivos de memória ou logs de sessão.

Na pasta gerada:

```text
node build.mjs
node serve.mjs
```

Inicie o servidor pelo mecanismo normal de execução em segundo plano do host. No Windows, janela oculta. Porta padrão 4640; se ocupada, escolha uma livre, atualize a configuração deste app e inicie nela. Nunca pare um serviço que não é seu. Mantenha o endereço em `127.0.0.1`.

Leia as contagens e avisos reais do build. Pasta ausente é problema de configuração para resolver, não motivo para inventar nós. Categoria vazia é permitida e mostrada com honestidade. Cérebro totalmente vazio: explique que precisa de notas salvas; não infle com conteúdo sintético, a menos que o usuário peça um exemplo rotulado.

## 4. Preservar o comportamento e a honestidade das conexões

O renderizador fornecido é o contrato visual. Mantenha:

- Layout esférico estável, cores por fonte, fundo escuro, orbe central brilhante, acentos orbitais discretos.
- Links Markdown e wikilinks reais, com menções por título exato distinguidas de relações explícitas. Links ambíguos ficam sem resolver.
- Busca, solo e alternância de fontes, inventário, sinalizações de saúde, leitura de nota, e revelação do arquivo local.
- **Ver crescimento:** uma ideia central, a primeira conexão real, ramos brotando dos nós-pai, crescimento acelerando, e o cérebro completo em cerca de 29 segundos. Notas desconectadas entram sem arestas inventadas. É uma reprodução de conectividade, não uma cronologia.
- Orbe central visível desde o primeiro quadro. Arrastar, dar zoom ou clicar não interrompe o crescimento. A câmera do usuário assume o lugar do recuo automático. Repetir reinicia limpo.
- **Cinema:** apresentação limpa com o contador ao lado da cena. Pausa de movimento, respeito a "reduzir movimento", controles responsivos, sem rótulos velhos depois da reprodução.

Toda interface que carrega nome vem do `brain.config.json`. Não regenere visuais com modelo de imagem nem troque a cena por um grafo de força genérico. Se precisar mudar código: `npm ci`, edite `src/`, rode `npm run build:js`. Mantenha os avisos de licença junto do bundle.

Os adaptadores padrão leem Markdown/texto e a memória curada do Codex. Para Google Drive, Notion, JSON bruto de reunião, bancos de dados, PDFs ou outra fonte não suportada: explique a lacuna e use uma exportação local aprovada, ou construa e teste um adaptador. Não afirme que esses sistemas estão conectados só porque o nome aparece em uma categoria.

## 5. Verificar e entregar

Siga a [lista de aceite](references/aceite.md). Confira o app gerado, não só o template:

1. A API do grafo tem o nome e as categorias pedidas, IDs únicos, arestas válidas e contagens iguais à varredura.
2. Leia pelo menos uma nota real de cada categoria não vazia, inclusive seções exatas da memória do Codex. Os originais permanecem intactos.
3. Confirme o nome na página e teste busca, solo de fonte, restauração e inventário.
4. Assista ao início, meio e fim do crescimento. Arraste e dê zoom com o contador subindo. Confira orbe inicial, rótulos limpos, contagem final completa e reinício.  Teste cinema e pausa.
5. Inspecione área de trabalho e viewport estreito. Não manipule o mouse físico do usuário; o app desabilita pointer lock. Automação de navegador deve ser virtual.
6. Confira erros no console. Se a verificação em navegador não for possível, diga exatamente quais checagens ficaram sem verificar em vez de afirmar aprovação visual.

Adicione uma rota curta para o README do app no índice de projetos ou no manual, seguindo as convenções do cérebro. Mantenha `AGENTS.md` e `CLAUDE.md` iguais. Não guarde configuração privada, dados do grafo ou conteúdo de notas em repositório público. Não publique nem faça push sem autorização.

Termine com: nome do cérebro, link local, pasta do app, contagens reais de notas e categorias, e as instruções mais curtas úteis: **Ver crescimento**, **Cinema**, arraste para orbitar, role para dar zoom. Mencione lacunas de fonte, se houver.
