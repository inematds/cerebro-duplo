---
name: qual-agente
description: Decide qual agente (Claude Code ou Codex), qual modelo e qual nível de esforço usar para um pedido no segundo cérebro, explica em duas linhas e devolve o comando duplo.sh pronto. Use quando o usuário perguntar "qual agente", "qual modelo", "uso Claude ou Codex", "isso é pro Codex?", "quanto esforço", "estou sem cota", "which agent", "which model", "Claude or Codex", "route this", ou antes de abrir uma sessão para uma tarefa nova.
argument-hint: "<o pedido que você quer rotear>"
---

# Qual agente?

Um cérebro, dois agentes. O contexto é o mesmo (os arquivos do cérebro); o que muda é **quem executa, com que modelo e com que esforço**. Esta skill escolhe, justifica em duas linhas e entrega o comando.

## Entrada

O pedido do usuário em linguagem natural. Se vier vazio, pergunte em uma linha: "o que você vai fazer agora?".

## Passos

1. **Classifique a tarefa** em uma das linhas da tabela de roteamento abaixo. Se encaixar em duas, vale a primeira que aparecer (a tabela está em ordem de prioridade).
2. **Aplique as regras de cota** (seção abaixo). Elas podem derrubar um degrau.
3. **Responda em, no máximo, quatro linhas:**
   - linha 1: `agente · perfil · modelo/esforço`
   - linhas 2–3: por quê (o que na tarefa pede isso)
   - linha 4: o comando `bash scripts/duplo.sh <agente> <perfil>` (ou `--so-mostrar` se o usuário só quer ver)
4. **Lembre de registrar ao terminar**: termine sempre com `ao fechar: duplo.sh uso registrar <agente> <perfil> <min> "<tarefa>"`.

Não abra o agente por conta própria: quem abre é o usuário (é uma sessão nova, com cota).

## Tabela de roteamento (ordem de prioridade)

| # | Se a tarefa é... | Agente | Perfil | Por quê |
|---|---|---|---|---|
| 1 | Usa um **MCP específico** (calendário, e-mail, banco, navegador) | o agente que **tem esse MCP configurado** | `padrao` | MCP é configurado por agente (`.mcp.json` / `~/.claude.json` no Claude Code; `~/.codex/config.toml` no Codex). Sem o MCP, o agente nem enxerga a ferramenta. Confira em `conexoes.md`. |
| 2 | **Código longo, refatoração, script de conexão** | o agente onde o **repo já está aberto** | `codigo` | Trocar de agente no meio joga fora o contexto da sessão (arquivos lidos, decisões tomadas). Se nenhum está aberto: tanto faz; escolha o que tiver mais cota na semana. |
| 3 | **Raciocínio pesado:** `/auditar`, `/evoluir`, arquitetura, decisão difícil, `/wiki` com **fonte grande** (dezenas de páginas) | qualquer um | `raciocinio` | Modelo mais capaz e esforço alto. É onde um modelo barato erra caro (nota de auditoria inflada, wiki com links quebrados). |
| 4 | **Achar um documento, resumir reunião, redigir e-mail, `/rotina` do dia, `/vincular`** | qualquer um | `rotina` | Tarefa de leitura + escrita curta. Modelo barato e esforço baixo resolvem e preservam cota. |
| 5 | **`/entrevista`, `/iniciar`, conversa longa de descoberta** | o agente de que o usuário **mais gosta de conversar** | `padrao` | É diálogo; a qualidade vem do contexto, não da capacidade máxima. |
| 6 | **`/wiki` incremental** (uma ou duas fontes novas) | qualquer um | `padrao` | Meio-termo: precisa ler bem, mas o volume é pequeno. |
| 7 | **Tarefa agendada / sem supervisão** (cron, rotina automática) | o agente que já tem o **agendamento** montado | `rotina` | Sem humano olhando, o barato erra barato. Registre a execução em `rotinas/registro.md`. |
| 8 | Não sei classificar | qualquer um | `padrao` | Comece pelo padrão; suba para `raciocinio` se a resposta vier rasa. |

"Qualquer um" significa: escolha o agente com **mais cota sobrando na semana** (veja `registro-uso.md`); empatou, use o que estiver aberto.

## Regras de cota

- **Semana apertada** (o usuário disse "estou sem cota", "acabou o limite", ou `duplo.sh uso resumo` mostra um agente muito acima do outro): **caia um degrau** — `raciocinio` → `padrao`, `padrao` → `rotina` — **ou troque de agente**, se a tarefa não depende de MCP nem de repo aberto.
- **Nunca caia degrau em auditoria** (`/auditar`): se não dá para rodar com `raciocinio`, adie a auditoria; nota inflada é pior do que nota atrasada.
- **Um agente esgotado não é bloqueio**: o cérebro é o mesmo. Abra o outro com o mesmo perfil e continue; o manual e as skills estão em paridade (confira com `/duplo-verificar` ou `$duplo-verificar`).
- **Trabalho longo em modelo caro**: proponha quebrar em duas sessões (planejar com `raciocinio`, executar com `padrao`).

## Sempre registrar uso ao terminar

Toda resposta desta skill termina com a linha de registro:

```
ao fechar: bash scripts/duplo.sh uso registrar <agente> <perfil> <minutos> "<tarefa>"
```

Sem registro não há resumo, e sem resumo não há regra de cota. O registro fica em `registro-uso.md` na raiz do cérebro.

## Exemplo

Pedido: "preciso auditar o cérebro, faz um mês que não rodo"

```
codex · raciocinio · gpt-6-astra/high
Auditoria é raciocínio pesado (linha 3): dá nota com evidência, e um modelo barato infla a nota.
Codex porque, pelo registro, o Claude Code já gastou mais cota esta semana.
bash scripts/duplo.sh codex raciocinio        → depois, dentro da sessão: $auditar
ao fechar: bash scripts/duplo.sh uso registrar codex raciocinio 25 "auditoria mensal"
```

Pedido: "resume a reunião de ontem que está em fontes/"

```
claude · rotina · sonnet/low
Resumo de reunião é leitura + escrita curta (linha 4): modelo barato e esforço baixo resolvem.
Claude Code porque está aberto agora; no Codex seria igual.
bash scripts/duplo.sh claude rotina
ao fechar: bash scripts/duplo.sh uso registrar claude rotina 8 "resumo reunião de ontem"
```

## Limites

- A skill **não abre** o agente e **não registra** uso sozinha; ela sugere os dois comandos.
- Os nomes de modelo vêm de `scripts/perfis/*.env`. Se o usuário mudou de plano, edite os perfis; não invente nomes de modelo.
- Custo em dinheiro: não estime. Aponte para a tabela do provedor e para `docs/custo-e-cota.md` do cerebro-duplo.
