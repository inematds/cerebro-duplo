# Roteamento: qual agente, qual modelo, quanto esforço

A skill `qual-agente` aplica esta tabela. Aqui está a versão completa, com as justificativas, para você ajustar ao seu plano e ao seu cérebro.

## Princípios

1. **O contexto é o mesmo.** Os dois agentes leem os mesmos arquivos. O que muda é capacidade (modelo), profundidade (esforço) e ferramentas (MCP configurado). Escolher agente é escolher essas três coisas, não "quem é mais inteligente".
2. **Restrições vêm antes de preferências.** MCP configurado e repo aberto são restrições duras; "prefiro conversar com X" é preferência. A tabela está em ordem: a primeira linha que encaixa vence.
3. **O caro erra caro, o barato erra barato.** Modelo caro em tarefa de leitura curta desperdiça cota; modelo barato em auditoria produz nota inflada que você vai acreditar por um mês. O custo do erro decide o degrau, não o tamanho da tarefa.
4. **Cota é orçamento semanal.** O registro de uso existe para você saber, na quinta-feira, se ainda dá para rodar a auditoria com `raciocinio`.
5. **Sempre registrar.** Sem registro não há resumo; sem resumo a regra de cota é chute.

## Tabela completa (ordem de prioridade)

| # | Tarefa | Agente | Perfil | Modelo / esforço (perfis de fábrica) | Justificativa |
|---|---|---|---|---|---|
| 1 | Precisa de um **MCP específico**: calendário, e-mail, banco de dados, navegador, ferramenta interna | o que **tem o MCP configurado** | `padrao` | Claude `sonnet/medium` · Codex `gpt-6-astra/medium` | MCP é configurado por agente (`.mcp.json` / `~/.claude.json` no Claude Code; `[mcp_servers.*]` em `~/.codex/config.toml` no Codex). O agente sem o MCP não tem como fazer a tarefa, por mais capaz que seja. `conexoes.md` diz qual agente tem o quê. |
| 2 | **Código longo, refatoração, script de conexão** (`scripts/*.sh`, integrações) | o agente onde o **repo já está aberto** | `codigo` | Claude `fable/high` + `acceptEdits` · Codex `gpt-6-astra/high` + `workspace-write` | O contexto da sessão (arquivos lidos, decisões, testes rodados) não migra entre agentes. Trocar no meio custa mais do que qualquer diferença entre modelos. Sem sessão aberta: escolha pela cota. |
| 3 | **`/auditar`** | qualquer um | `raciocinio` | Claude `fable/high` · Codex `gpt-6-astra/high` | Auditoria dá nota com evidência em 4 pilares e o resultado orienta o `/evoluir` seguinte. Nota errada propaga por um ciclo inteiro. Nunca cai degrau: se não dá, adia. |
| 4 | **`/evoluir`**, arquitetura de skill nova, decisão difícil registrada em `decisoes/` | qualquer um | `raciocinio` | idem | Produz artefato que fica (skill, rotina, decisão). Vale o esforço alto uma vez para não refazer três. |
| 5 | **`/wiki` com fonte grande** (dezenas de páginas, transcrição de horas) | qualquer um | `raciocinio` | idem | Ingestão grande exige manter muitos vínculos na cabeça; modelo barato gera páginas órfãs e links quebrados que o `/auditar` vai apontar depois. |
| 6 | **`/wiki` incremental** (1–2 fontes novas) | qualquer um | `padrao` | Claude `sonnet/medium` · Codex `gpt-6-astra/medium` | Precisa ler bem, mas o volume é pequeno e a estrutura já existe. |
| 7 | **Achar um documento, responder "onde está X"** | qualquer um | `rotina` | Claude `sonnet/low` · Codex `gpt-6-astra/low` | É busca + citação. O mapa de rotas do manual faz o trabalho pesado. |
| 8 | **Resumir reunião, transcrição curta** | qualquer um | `rotina` | idem | Leitura de uma fonte, escrita curta. Erro é barato de corrigir. |
| 9 | **Redigir e-mail, mensagem, post** na sua voz (`referencias/voz.md`) | qualquer um | `rotina` | idem | A qualidade vem do arquivo de voz, não da capacidade. Você revisa antes de enviar de qualquer jeito. |
| 10 | **`/vincular`, `/rotina` (registrar execução), pequenas edições no manual** | qualquer um | `rotina` | idem | Edições de uma linha em arquivos conhecidos. Depois: `duplo.sh sync`. |
| 11 | **`/iniciar`, `/entrevista`, conversa longa de descoberta** | o que você **prefere conversar** | `padrao` | Claude `sonnet/medium` · Codex `gpt-6-astra/medium` | É diálogo; o valor está nas suas respostas. Conforto com o estilo do agente pesa mais que capacidade. |
| 12 | **Rotina agendada / sem supervisão** (cron, `/schedule`, hook) | o que **já tem o agendamento** montado | `rotina` | Claude `sonnet/low` · Codex `gpt-6-astra/low` | Sem humano olhando, erro barato é o único aceitável. A execução vai para `rotinas/registro.md`. |
| 13 | **Não sei classificar** | qualquer um | `padrao` | idem | Comece no meio. Se a resposta vier rasa, suba para `raciocinio` na mesma sessão (`/model` no Claude Code, `/model` no Codex) ou reabra com o perfil certo. |

"Qualquer um" = o agente com mais cota sobrando na semana (`duplo.sh uso resumo`); empatou, o que estiver aberto.

## Regras de cota (degraus)

Os perfis formam uma escada: `raciocinio` → `padrao` → `rotina`.

| Situação | Ação |
|---|---|
| Semana apertada em um agente (limite avisado, ou `uso resumo` muito desbalanceado) | Troque de agente se a tarefa não está presa a MCP ou repo aberto (linhas 1–2). Se está presa, caia um degrau. |
| Semana apertada nos dois | Caia um degrau em tudo, **menos** auditoria (adie). Rotinas agendadas continuam em `rotina`. |
| Tarefa longa em `raciocinio` | Divida: planejar em `raciocinio` (curto), executar em `padrao` (longo). O plano fica em `decisoes/` ou no README do projeto, então a segunda sessão não perde nada. |
| Fim de semana / início de ciclo | Cota renovada: é a hora da auditoria e da ingestão grande. |

## Como adaptar

- **Outro plano, outros modelos:** edite `perfis/*.env`. A tabela fala em perfis, não em nomes de modelo, de propósito.
- **Só um agente disponível:** a tabela continua valendo para o perfil; "qualquer um" vira "o que você tem".
- **Terceiro agente** que leia `AGENTS.md`: acrescente uma coluna na tabela da skill `qual-agente` e um bloco `DUPLO_<AGENTE>_*` nos perfis; o `duplo.sh` precisa de uma função `cmd_<agente>` nova (veja `docs/migracao.md`).
- **Tarefa recorrente que a tabela erra:** anote em `decisoes/registro.md` e ajuste a linha na sua cópia de `.claude/skills/qual-agente/SKILL.md`; depois `duplo.sh sync`.
