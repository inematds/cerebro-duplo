# Checagem de rotas e compatibilidade entre runtimes

Obrigatória em toda auditoria. Limitada e somente leitura. Inspecione os runtimes em uso (Claude Code, Codex, ou ambos). Cérebro de runtime único não precisa de cópia duplicada para passar. Nunca instale, sincronize, renomeie nem rode fluxos só para auditar.

## 1. Os dois manuais

- O kit promete `AGENTS.md` e `CLAUDE.md` idênticos. Compare. Diferença só de espaço ou fim de linha não é conflito. Diferença de regra, rota, permissão ou preferência é **defeito confirmado**, com arquivo e linha dos dois lados.
- Manual ausente é defeito se o runtime correspondente está em uso e fica sem orientação. Se só um runtime está em uso, a ausência do outro é oportunidade, não defeito.

## 2. Rotas nos dois sentidos

- **Rota → alvo:** resolva cada caminho do mapa de rotas a partir da raiz certa. Verifique existência e destino pretendido. Placeholder `{{...}}`, exemplo, glob e URL remota se distinguem de referência concreta. Caminho remoto indisponível localmente é "não verificado", não "quebrado".
- **Alvo importante → rota:** compare índices e manual com as pastas reais de projetos, conhecimento e skills. Siga cadeias de índice: projeto aninhado pode estar roteado sem link direto no manual. Identifique material ativo útil sem rota. Pasta não classificada é candidata a revisão, não órfã automaticamente.
- Procure: nomes de usuário obsoletos, pastas movidas, caminhos absolutos de outra máquina, grafia ou caixa errada, contagens velhas, material arquivado mostrado como ativo, link para destino válido mas errado.
- Não sinalize todo arquivo sem link. Rascunho, gerado, dependência, `arquivo/` e material deliberadamente privado podem estar corretamente fora.

## 3. Skills nos dois runtimes

Case skills por identidade declarada (`name` no frontmatter), não só pelo nome da pasta.

1. **Presença:** cada skill em `.claude/skills/` tem cópia em `.agents/skills/` (e vice-versa), ou a diferença é intencional e documentada.
2. **Conteúdo:** os passos, entradas, saídas e limites coincidem. A única transformação esperada é `.claude/skills/` → `.agents/skills/` dentro dos `.md`. Cópia no espelho sem origem é deriva.
3. **Recursos:** scripts, modelos, referências e assets exigidos resolvem a partir do runtime alvo. `SKILL.md` igual com modelo faltante é defeito de pacote.
4. **Descoberta:** distinga presente em disco, listado pelo runtime, desabilitado, não checado. Presença no menu não prova execução.
5. **Comportamento:** chamadas de ferramenta incompatíveis, comandos de outra plataforma, variáveis de ambiente não documentadas (nome, nunca valor).

## 4. Comunicar

Classes: **defeito confirmado**, **lacuna de verificação**, **diferença intencional**, **oportunidade**.

Matriz compacta, com caminhos reais:

| Item | Evidência Claude | Evidência Codex | Achado / ID | Consequência prática |
|---|---|---|---|---|

Depois, só os achados acionáveis:

| ID / classe / prioridade | Evidência e runtime afetado | Impacto no usuário | Mudança ou verificação proposta | Critério de conclusão |
|---|---|---|---|---|

Priorize resposta errada, instrução perdida, fluxo indisponível e deriva de permissão acima de diferença cosmética. Um ID por problema de fundo. Sem quinta nota, sem "percentual de migração", sem bônus por arquivo duplicado, sem conserto automático.

## Calibração

- Manuais com as mesmas regras e nomes de ferramenta diferentes por runtime: adaptação intencional.
- Só fim de linha difere: formatação, não bloqueio.
- Regra de permissão só em um manual: omissão confirmada.
- Runtime único com um manual e uma árvore de skills: sem penalidade de cópia faltante.
- Skill listada e habilitada mas não executada: descoberta verificada, execução não verificada.
