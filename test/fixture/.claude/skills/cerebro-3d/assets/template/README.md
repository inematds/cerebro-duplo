# Seu cérebro 3D

Uma visão local e somente leitura das fontes de conhecimento selecionadas em `brain.config.json`.

Rode `node serve.mjs` nesta pasta e abra o link `localhost` impresso. Requer Node.js 22 ou superior. O renderizador pré-compilado vem incluído, então não é preciso instalar nada para rodar. Para editar o renderizador: `npm ci`, edite `src/` e rode `npm run build:js`.

Nome, categorias, cores, caminhos das fontes e porta vêm de `brain.config.json`. "Reconstruir do disco" atualiza notas e conexões. Reinicie o servidor depois de mudar código ou porta. Fontes ausentes ou inacessíveis aparecem como avisos no inventário, não como notas inventadas.

- Arraste para orbitar, role para dar zoom, clique em um nó para ler. `/` foca a busca.
- Os botões de fonte alternam categorias. Shift + clique deixa uma sozinha; clicar na última ativa restaura todas.
- Ver crescimento (`D`) faz o grafo crescer pelas conexões reais em cerca de 29 segundos. Orbitar e dar zoom continuam funcionando. O orbe central aparece de imediato. Repetir recomeça depois do fim.
- Cinema (`C`) esconde a interface ao redor. Esc sai.
- Pausar movimento congela a rotação e os acentos animados. A preferência de "reduzir movimento" é respeitada.
- Só as vizinhanças selecionadas ganham caminhos brilhantes; os links da visão geral são amostrados para continuar legíveis. O inventário mantém as contagens completas.

A reprodução mostra conectividade, não datas de criação. Relações desconhecidas ficam desconectadas. Menções por título exato são rotuladas como `mention`; links Markdown explícitos e wikilinks têm precedência. Nomes de arquivo duplicados com links ambíguos são relatados, não atribuídos em silêncio.

Arquivos Markdown e de texto são suportados diretamente: notas de reunião locais, páginas de wiki, notas de projeto, skills e memória do Claude. O adaptador do Codex lê resumos curados de memória, grupos de tópicos, recapitulações e notas de fluxo. Exclui logs brutos de sessão e exportações duplicadas. Sistemas remotos, PDFs, bancos de dados e JSON bruto de reunião precisam de exportação local explícita ou de um adaptador adicional; este app não afirma ingeri-los automaticamente.

O servidor escuta em `127.0.0.1`. Expõe só IDs de nota indexados e ativos estáticos aprovados, rejeita requisições de API de outra origem e sanitiza o Markdown renderizado. Pointer lock e captura de cursor estão desabilitados. Os arquivos-fonte nunca são modificados. A configuração local e o grafo gerado são ignorados pelo git. O cinema esconde os controles, não informação privada; revise as notas visíveis antes de gravar ou compartilhar a tela.

Licenças das dependências de terceiros em `THIRD-PARTY-NOTICES.txt`.
