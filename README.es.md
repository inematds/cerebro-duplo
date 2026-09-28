# cerebro-duplo — un cerebro, dos agentes

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

Playbook + herramientas para usar **el mismo segundo cerebro** (la carpeta de Markdown creada por el kit [astra-2cerebro](https://github.com/inematds/astra-2cerebro)) con **Claude Code** (modelos Claude) y con **Codex CLI** (modelos de OpenAI), eligiendo el agente, el modelo y el nivel de esfuerzo adecuados para cada tarea, manteniendo los manuales y las skills sincronizados, y registrando el uso por sesión.

Bash puro. Sin dependencias. Versión 1.0.0.

## 📖 Guía de uso

Guía completa (landing + paso a paso): **https://inematds.github.io/cerebro-duplo/guia/es/**

## El problema

Tienes un segundo cerebro: contexto, decisiones, proyectos, wiki, rutinas. Dos agentes pueden leerlo, pero cada uno lo hace por una puerta diferente:

| | Claude Code | Codex CLI |
|---|---|---|
| Manual que lee el agente al abrir | `CLAUDE.md` | `AGENTS.md` |
| Carpeta de skills del proyecto | `.claude/skills/<nome>/SKILL.md` | `.agents/skills/<nome>/SKILL.md` (+ `agents/openai.yaml`) |
| Cómo invocar una skill | `/nome` | `$nome` |

Sin cuidado, esto se convierte en **dos cerebros**: una ruta editada solo en `AGENTS.md`, una skill corregida solo en `.claude/skills`, y cada agente empieza a vivir en una realidad distinta. Y, sin un criterio, terminas gastando el modelo más caro en «encuentra ese correo» y el más barato en una auditoría.

cerebro-duplo resuelve las tres cosas:

1. **Paridad** — `duplo.sh verificar` mide; `duplo.sh sync` corrige; la skill `duplo-verificar` informa y propone.
2. **Enrutamiento** — la skill `qual-agente` decide el agente + modelo + esfuerzo y devuelve el comando. Los perfiles de ejecución (`perfis/*.env`) guardan el modelo y el esfuerzo según el tipo de tarea.
3. **Uso y cuota** — `duplo.sh uso registrar` anota cada sesión; `uso resumo` muestra en qué se está usando la cuota. Sin precios inventados: el registro se lleva en minutos y sesiones; el costo en dinero se consulta en la tabla del proveedor.

## Cómo funciona

```
meu-cerebro/
├── AGENTS.md  ══ idênticos ══  CLAUDE.md          ← duplo.sh verificar / sync
├── .claude/skills/  ══ idênticas ══  .agents/skills/
│     ├── qual-agente/        ← decide agente, modelo, esforço
│     ├── duplo-verificar/    ← relatório de paridade
│     └── (as 8 skills do astra-2cerebro)
├── scripts/duplo.sh          ← CLI
├── scripts/perfis/*.env      ← modelo + esforço por perfil (padrao, rotina, raciocinio, codigo)
└── registro-uso.md           ← uma linha por sessão
```

El contenido canónico está en `AGENTS.md` (lo lee cualquier agente que siga el estándar AGENTS.md) y `.claude/skills` (desde ahí el kit astra-2cerebro sincroniza). El espejo se vuelve a generar; nunca se edita a mano.

## Comandos

Todos aceptan `--dir <cerebro>` (predeterminado: carpeta actual).

| Comando | Qué hace | Sale con 1 si... |
|---|---|---|
| `duplo.sh verificar` | ¿`AGENTS.md` = `CLAUDE.md`? ¿Cada skill está espejada e idéntica? ¿Cada skill tiene `SKILL.md` y `agents/openai.yaml`? ¿Existen las rutas del manual? | hay un PROBLEMA (una ruta rota solo es una ADVERTENCIA) |
| `duplo.sh sync [--fonte agents\|claude]` | Vuelve a escribir el manual del otro lado a partir de la fuente (predeterminado `agents`); copia `.claude/skills` → `.agents/skills`. Nunca elimina una skill que solo existe en el espejo; lo advierte. | hay un error de ejecución |
| `duplo.sh claude [perfil] [--so-mostrar]` | Abre Claude Code en el cerebro con `--model` y `--effort` del perfil. Imprime el comando antes. | el perfil no existe |
| `duplo.sh codex [perfil] [--so-mostrar]` | Abre Codex en el cerebro con `-C`, `-m` y `-c model_reasoning_effort` del perfil. Imprime el comando antes. | el perfil no existe |
| `duplo.sh uso registrar <agente> <perfil> <minutos> "<tarefa>"` | Añade una línea en `<cerebro>/registro-uso.md` (lo crea a partir de la plantilla). | agente ≠ claude/codex, los minutos no son numéricos |
| `duplo.sh uso resumo` | Sesiones y minutos por agente y por agente+perfil. | no hay registro |
| `duplo.sh perfis` | Lista los perfiles y sus modelos. | |
| `duplo.sh ajuda` | Ayuda. | |

Comandos generados (salida real de `--so-mostrar` en esta máquina, Claude Code 2.1.263 y Codex 0.153.3):

```
$ duplo.sh --dir test/fixture claude raciocinio --so-mostrar
perfil: raciocinio (perfis/raciocinio.env)
comando: cd /…/test/fixture && claude --model claude-opus-5-5 --effort high --name duplo:raciocinio

$ duplo.sh --dir test/fixture codex rotina --so-mostrar
perfil: rotina (perfis/rotina.env)
comando: codex -C /…/test/fixture -m gpt-6-astra -c model_reasoning_effort=\"low\"
```

## Perfiles

| Perfil | Claude Code | Codex | Para qué |
|---|---|---|---|
| `raciocinio` | tope (`claude-opus-5-5`) / `high` | `gpt-6-astra` / `high` | `/auditar`, `/evoluir`, arquitectura, wiki grande |
| `padrao` | `sonnet` / `medium` | `gpt-6-astra` / `medium` | día a día |
| `rotina` | `sonnet` / `low` | `gpt-6-astra` / `low` | encontrar documentos, resumir reuniones, correo |
| `codigo` | tope (`claude-opus-5-5`) / `high` + `--permission-mode acceptEdits` | `gpt-6-astra` / `high` + `-s workspace-write` | código extenso, refactorización |

Los nombres de los modelos corresponden al plan de esta máquina; edita `perfis/*.env` para usar los tuyos. Los alias de Claude Code (`fable`, `opus`, `sonnet`) y los niveles de esfuerzo (`low`…`max`) se consultaron en `claude --help`; en Codex, el esfuerzo se configura mediante la clave `model_reasoning_effort` (consulta [docs/comparativo-runtimes.md](docs/comparativo-runtimes.md)).

## Enrutamiento (resumen)

La tabla completa, con justificaciones, está en [docs/roteamento.md](docs/roteamento.md). Lo esencial:

| Tarea | Agente | Perfil |
|---|---|---|
| Usa un MCP específico (calendario, correo, navegador) | el que **tiene el MCP** configurado | `padrao` |
| Código extenso, refactorización | el agente donde el **repo ya está abierto** | `codigo` |
| Auditoría, arquitectura, decisión difícil, wiki grande | cualquiera | `raciocinio` |
| Encontrar documentos, resumir reuniones, redactar correos | cualquiera | `rotina` |
| Entrevista, conversación de descubrimiento | el que prefieras para conversar | `padrao` |
| Rutina programada, sin supervisión | el que ya tiene la programación | `rotina` |

Reglas de cuota: semana ajustada → baja un nivel (`raciocinio` → `padrao` → `rotina`) o cambia de agente; las auditorías nunca bajan de nivel (se posponen); registra siempre el uso al terminar.

## Instalación en 1 minuto

```bash
git clone https://github.com/inematds/cerebro-duplo.git
cd cerebro-duplo
bash instalar.sh ~/meu-cerebro      # a pasta criada pelo astra-2cerebro
```

Esto copia las dos skills a `.claude/skills` y `.agents/skills` del cerebro, `duplo.sh` (con `perfis/` y `modelos/`) a `scripts/`, y ejecuta `verificar`. Detalles e «instrucciones para el agente» en [INSTALAR.md](INSTALAR.md).

## Un día de uso

```bash
cd ~/meu-cerebro

# 08:30 — resumir la reunión de ayer (fontes/reuniao-2026-09-06.md)
bash scripts/duplo.sh claude rotina           # abre Claude Code con sonnet/low
#   > /wiki  (ingiere solo la fuente nueva)
bash scripts/duplo.sh uso registrar claude rotina 8 "resumo reunião 06/09"

# 10:00 — refactorizar el script de conexión del calendario; el repo ya está abierto en Codex
bash scripts/duplo.sh codex codigo            # gpt-6-astra/high, sandbox workspace-write
bash scripts/duplo.sh uso registrar codex codigo 40 "refatorar scripts/calendario.sh"

# 15:00 — "¿qué agente uso para la auditoría?"  → dentro de cualquier sesión: /qual-agente o $qual-agente
#   respuesta: raciocinio, en el agente con más cuota disponible (consulta el resumen)
bash scripts/duplo.sh uso resumo
bash scripts/duplo.sh codex raciocinio        # $auditar
bash scripts/duplo.sh uso registrar codex raciocinio 25 "auditoria mensual"

# 18:00 — edité una skill en Claude Code; Codex necesita ver la misma
bash scripts/duplo.sh verificar               # señala la diferencia
bash scripts/duplo.sh sync                    # crea el espejo
```

## Pruebas

`bash test/testes.sh` ejecuta `duplo.sh` contra `test/fixture` (un cerebro pequeño de astra-2cerebro, sin `apps/`) y contra copias temporales alteradas a propósito. Nunca modifica la fixture.

Resultado real de esta versión (Linux, bash 5.2):

```
== resultado: 38 passaram, 0 falharam
```

Qué cubren las pruebas:

- `verificar` pasa en la fixture íntegra (0 problemas; las 6 rutas que crea `/iniciar` después aparecen como ADVERTENCIA).
- Manual divergente → código 1 con el diff; `sync` lo corrige (en ambas direcciones, `--fonte agents` y `--fonte claude`) y `verificar` vuelve a pasar.
- Skill alterada en el espejo, `openai.yaml` eliminado, skill sin copia → código 1 con cada elemento identificado; `sync` lo corrige y `verificar` vuelve a pasar con «8 skills idénticas».
- Skill solo en el espejo → PROBLEMA en `verificar`, ADVERTENCIA en `sync`, y `sync` no la elimina.
- Si falta `openai.yaml` en el contenido canónico, sigue habiendo un problema después de `sync` (sync no inventa archivos).
- Ruta rota en el manual → ADVERTENCIA, código 0.
- `uso registrar` crea `registro-uso.md` a partir de la plantilla, copia el modelo y el esfuerzo del perfil, escapa `|` en la tarea, rechaza agentes desconocidos y minutos no numéricos; `uso resumo` suma correctamente (2 sesiones/45 min, 1/10, total 3/55).
- `claude --so-mostrar` y `codex --so-mostrar` imprimen los comandos con los flags reales; el perfil `codigo` añade los flags extra; sin perfil usa `padrao`; si el perfil no existe, falla e indica los disponibles.
- `ajuda`, `perfis`, `versao` (coincide con `VERSION`), comando desconocido y `--dir` no válido.
- `instalar.sh` instala en un cerebro copiado y `duplo.sh` funciona de forma independiente una vez instalado (10 skills idénticas, encuentra los perfiles a su lado).

## Documentación

- [INSTALAR.md](INSTALAR.md) — instalación, actualización, instrucciones para el agente.
- [docs/comparativo-runtimes.md](docs/comparativo-runtimes.md) — Claude Code × Codex: manual, skills, invocación, MCP, memoria, programación, flags reales, limitaciones.
- [docs/roteamento.md](docs/roteamento.md) — la tabla completa de enrutamiento con justificaciones.
- [docs/paridade.md](docs/paridade.md) — por qué los manuales deben ser idénticos, qué falla, lista de verificación.
- [docs/custo-e-cota.md](docs/custo-e-cota.md) — registro de uso, cómo leerlo, cómo decidir niveles.
- [docs/migracao.md](docs/migracao.md) — pasar un cerebro de un agente a otro, y a un tercero que lea `AGENTS.md`.
- [docs/faq.md](docs/faq.md) — preguntas frecuentes.
- [CHANGELOG.md](CHANGELOG.md).

## Créditos y licencia

Construido sobre el kit [astra-2cerebro](https://github.com/inematds/astra-2cerebro), que define la estructura del cerebro, las 8 skills y la convención `AGENTS.md` = `CLAUDE.md` / `.claude/skills` = `.agents/skills`. `duplo.sh sync` hace lo mismo que `scripts/sincronizar-skills.sh` del kit, además del manual y la verificación.

MIT — Copyright (c) 2026 inematds. Consulta [LICENSE](LICENSE).
