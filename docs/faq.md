# Perguntas frequentes

**Preciso dos dois agentes instalados?**
Não. `verificar`, `sync` e `uso` funcionam sem nenhum. `duplo.sh claude` e `duplo.sh codex` precisam do respectivo binário no PATH só na hora de abrir (com `--so-mostrar` nem isso). A tabela de roteamento continua útil com um agente só: "qualquer um" vira "o que você tem".

**Por que `AGENTS.md` é o canônico e não `CLAUDE.md`?**
Porque `AGENTS.md` é o padrão que mais agentes leem; um terceiro agente entra sem conversão. `sync --fonte claude` inverte quando a edição boa está no `CLAUDE.md`. Para as skills, o canônico é `.claude/skills` porque é de onde o kit astra-2cerebro já sincroniza.

**Posso editar o espelho diretamente?**
Pode, mas o próximo `sync` sobrescreve. Edite o canônico e sincronize. Se editou o espelho sem querer, o `verificar` mostra o diff: copie a mudança para o canônico antes do `sync`.

**O `verificar` acusa rotas quebradas num cérebro recém-criado. Está errado?**
Não. O template do kit aponta para arquivos que o `/iniciar` cria depois (`contexto/prioridades.md`, `referencias/voz.md`, `wiki/index.md`, `auditorias/historico.md`). Por isso rota quebrada é AVISO (código 0), não PROBLEMA. Rode `/iniciar` e os avisos somem.

**O `sync` apagou uma skill minha?**
Não apaga nunca. Ele só substitui, em `.agents/skills`, pastas que têm origem em `.claude/skills`. Skill que existe só no espelho fica lá, com aviso.

**O Codex não mostra minha skill no `$`.**
Confira `agents/openai.yaml` dentro da pasta da skill (o `verificar` acusa se faltar) e se a pasta está em `.agents/skills` (rode `sync`). Depois reabra o Codex; ele lê as skills ao iniciar.

**O nome do modelo no perfil não existe no meu plano.**
Edite `perfis/*.env` (ou `scripts/perfis/*.env` no cérebro). Os nomes que vêm no repo são os desta máquina. Fontes confiáveis: `claude --help` para aliases (`fable`, `opus`, `sonnet`) e níveis de `--effort`; o seu `~/.codex/config.toml` para o modelo do Codex.

**Qual a diferença entre `--effort` e `model_reasoning_effort`?**
São a mesma ideia em runtimes diferentes: quanto o modelo "pensa" antes de responder. No Claude Code é uma flag de sessão (`--effort low|medium|high|xhigh|max`); no Codex é uma chave de configuração, passada com `-c 'model_reasoning_effort="high"'` ou gravada no `config.toml`. O `duplo.sh` traduz o perfil para as duas formas.

**Quanto custa em dinheiro?**
O cerebro-duplo não sabe e não estima. Registra sessões e minutos; o custo vem da tabela de preços do provedor e do painel da sua conta. Veja `docs/custo-e-cota.md`.

**Posso usar com um cérebro em inglês?**
Sim. O `duplo.sh` só olha caminhos (`AGENTS.md`, `CLAUDE.md`, `.claude/skills`, `.agents/skills`), não o idioma. As duas skills do cerebro-duplo estão em português; traduza o `SKILL.md` se quiser.

**Funciona no Windows?**
Com Git Bash ou WSL, sim. Em PowerShell puro, não (é bash). As skills funcionam em qualquer sistema: são texto.

**Posso rodar o `verificar` num cérebro que não é do astra-2cerebro?**
Pode. Qualquer pasta com `AGENTS.md`/`CLAUDE.md` e/ou `.claude/skills`/`.agents/skills` serve. Se faltar um dos pares, ele acusa.

**Como incluo as skills novas no manual do cérebro?**
Duas linhas na seção "Suas skills" do `AGENTS.md` (veja INSTALAR.md) e `sync`. Não é obrigatório: as skills aparecem em `/` e `$` mesmo sem estar no manual.

**Posso trocar de agente no meio de uma tarefa?**
Pode, desde que `verificar` esteja em `0 problema(s)`. O que não migra é o contexto da sessão (arquivos lidos, raciocínio feito). Para tarefas longas, deixe um resumo em `decisoes/registro.md` ou no README do projeto antes de trocar.

**O que fazer quando os dois agentes estão sem cota?**
Desça um degrau em tudo (`docs/custo-e-cota.md`), adie a auditoria, e use a semana para escrever contexto: é trabalho que não gasta modelo e melhora todas as sessões seguintes.

**Onde ficam os testes?**
`bash test/testes.sh`. Roda contra `test/fixture` (um cérebro pequeno, sem `apps/`) e cópias temporárias quebradas de propósito. Nunca altera a fixture.
