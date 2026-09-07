# Personalização e configuração das fontes

Depois que o usuário escolher nome e categorias, crie um JSON assim:

```json
{
  "name": "Cérebro da Maria",
  "port": 4640,
  "sources": [
    {"id":"contexto","label":"Contexto","paths":["contexto","referencias"],"color":"#38BDF8","staleDays":90},
    {"id":"wiki","label":"Wiki","paths":["wiki"],"color":"#A78BFA","staleDays":120},
    {"id":"projetos","label":"Projetos","paths":["projetos"],"color":"#34D399"},
    {"id":"entrevistas","label":"Entrevistas","paths":["entrevistas"],"color":"#FB923C","staleDays":null}
  ]
}
```

É um exemplo de esquema, não permissão para assumir que essas pastas existem. Inclua só caminhos verificados e escolhidos. O scaffold calcula `root` relativo ao app gerado, então o cérebro pode mudar de pasta ou de máquina sem quebrar os caminhos internos. O `brain.config.json` local é ignorado pelo git.

Campos:

| Campo | Significado |
|---|---|
| `name` | Nome exibido exato, 1 a 64 caracteres. Toda a marca pessoal deriva dele |
| `root` | Raiz do cérebro relativa à configuração do app. O scaffold define automaticamente |
| `port` | Porta local, 1024 a 65535, padrão 4640. Verifique conflitos |
| `maxNodes` | Limite de varredura, padrão 3000, máximo 10000. Atingir o limite gera aviso no inventário |
| `sources` | 1 a 12 categorias |
| `sources[].id` | ID único em minúsculas começando com letra; letras, dígitos e hífens |
| `sources[].label` | Nome da categoria para o usuário |
| `sources[].paths` | Arquivos ou pastas aprovados, relativos à raiz do cérebro ou caminhos explícitos absolutos ou `~/`. Sem glob |
| `sources[].type` | `markdown` (padrão) ou `codex-memory` |
| `sources[].color` | Cor hexadecimal de seis dígitos, opcional; senão a paleta atribui uma cor distinta |
| `sources[].exclude` | Prefixos de caminho relativos, opcionais, a ignorar dentro de cada pasta selecionada |
| `sources[].staleDays` | Número positivo, padrão 90. `null` desliga a sinalização de "desatualizada" para registros históricos |
| `sources[].obsidianVault` | Nome de um cofre Obsidian existente, opcional. Só quando os caminhos dos nós são válidos relativos ao cofre |

## Fontes suportadas

**Markdown:** varre `.md` e `.txt` recursivamente, lê frontmatter escalar simples (`title`, `name`, `description`, `type`, `updated`, `created`, `tags`, e os equivalentes em português `titulo`, `descricao`, `tipo`, `atualizado`, `criado`), e resolve links Markdown para arquivos e wikilinks. A estrutura de pastas da fonte determina o que entra. Entradas de índice de projetos continuam sendo texto de nota; as pastas reais dos projetos precisam ser selecionadas para incluir as notas delas.

Pastas ocultas, git, dependências, `arquivo/`, `auditorias/`, rascunhos, dados gerados e o próprio app gerado são excluídos. Links simbólicos são pulados. Arquivos acima de 1 MB geram aviso. Notas de navegação (`index`, `README` de índice, `log`) são listadas no inventário em vez de desenhadas. Escolher o mesmo arquivo duas vezes não duplica o nó.

**Memória do Claude:** use `markdown` apontando para a pasta de memória do projeto deste cérebro, aprovada pelo usuário. Não invente o nome codificado da pasta; verifique na máquina atual. A descoberta oferece a correspondência exata quando existe.

**Memória do Codex:** use `codex-memory` com uma raiz de memória escolhida explicitamente. A descoberta honra `CODEX_HOME`, senão verifica `~/.codex/memories`. O adaptador lê `memory_summary.md`, seções de `MEMORY.md`, resumos em `rollout_summaries/`, `skills/` de memória e `extensions/ad_hoc/notes/`. Não varre logs brutos de chat, `.env`, credenciais, arquivos ocultos nem `raw_memories.md`. O armazém pode conter memórias de vários projetos, então o usuário precisa saber desse escopo ao escolher.

**Outros formatos:** não suportados por padrão. Peça ou crie uma exportação local em Markdown autorizada, ou implemente um adaptador documentado. Não sintetize conteúdo faltante nem afirme cobertura de API remota.
