# Skill cerebro-3d

Constrói um globo 3D interativo e nomeado a partir do conhecimento salvo no segundo cérebro. A skill pergunta o nome do cérebro e as categorias principais, mapeia cada uma para pastas locais escolhidas, e cria o app pronto em `apps/cerebro-3d/`.

- Claude Code: `/cerebro-3d`
- Codex: selecione **Cérebro 3D** ou digite `$cerebro-3d`
- Linguagem natural: "monta um cérebro 3D com o meu cérebro"

Requer Node.js 22 ou superior. O renderizador vem incluído, então o app gerado roda com `node serve.mjs` sem `npm install`. Para modificar o renderizador: `npm ci` e `npm run build:js` na pasta gerada.

O app tem layout esférico, orbe central, categorias coloridas, busca, leitor de notas, filtros por fonte, inventário, modo cinema e animação de crescimento interativa. Arrastar e dar zoom continuam funcionando durante o crescimento. As conexões vêm das notas selecionadas; a animação ilustra conectividade, não datas de criação.

Markdown/texto e a memória curada do Codex são suportados diretamente. A memória do Claude usa a pasta Markdown selecionada. Reuniões e vídeos podem vir de exportações Markdown salvas. Outros formatos e serviços online precisam de exportação ou de um adaptador testado.

Para instalar separadamente, copie esta pasta inteira (`assets`, `scripts`, `references`, `agents`) para `.claude/skills/cerebro-3d/` do cérebro de destino, e rode `bash scripts/sincronizar-skills.sh cerebro-3d` para gerar a cópia do Codex. Não copie só o `SKILL.md` nem inclua a configuração ou os dados de um usuário.

Validação do pacote: `node scripts/test-package.mjs`. Para um conjunto fictício maior: `--keep --demo --out <pasta-de-rascunho>`.

Veja [SKILL.md](SKILL.md) para o fluxo, [a especificação](references/especificacao.md) para o contrato de implementação e [o guia de configuração](references/configuracao.md) para adaptadores e limites.
