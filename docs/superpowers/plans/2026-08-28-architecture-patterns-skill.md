# Architecture Patterns Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Публичный GitHub-репозиторий со скиллом `architecture-patterns` (открытый стандарт Agent Skills): мета-скилл с протоколом рефлексии, decision tree и справочником из 42 паттернов, устанавливаемый в OpenCode, Claude Code и Codex.

**Architecture:** Один скилл `skills/architecture-patterns/` = `SKILL.md` (протокол рефлексии + decision tree + индекс + правила выбора) + `patterns/{code,component,system}/*.md` (1 файл = 1 паттерн, progressive disclosure) + `references/{anti-patterns,decision-tree}.md`. `install.sh` кладёт symlink в `.agents/skills` (Codex + opencode), `.claude/skills` (Claude Code + opencode), `.opencode/skills`. Формат валидируется `scripts/validate.sh`.

**Tech Stack:** Markdown, bash (validate.sh, install.sh, test-validate.sh). Никаких зависимостей.

**Spec:** `docs/superpowers/specs/2026-08-28-architecture-patterns-skill-design.md` (читать вместе с планом; план аргументируется от спеки).

## Global Constraints

Все задачи неявно включают эти требования (значения — дословно из спеки):

- Имя скилла: `architecture-patterns`; должно совпадать с именем каталога; regex `^[a-z0-9]+(-[a-z0-9]+)*$`.
- `description` в frontmatter: 1–1024 символов, однострочная, 3-е лицо, «что делает + когда использовать».
- `SKILL.md`: тело < 500 строк.
- Файлы паттернов: 40–80 строк каждый, обязательные секции в фиксированном порядке, **ни одного fenced code block**.
- `references/*.md`: ни одного fenced code block.
- `SKILL.md`: fenced code block разрешён только без языкового тега (```  plain ```) — для шаблонов блоков.
- Ссылки: файлы паттернов линкуются из `SKILL.md` ровно в один скачок; file-to-file ссылки в секции `Related` допустимы.
- Контент скилла (SKILL.md, patterns, references): **английский**. Никаких кодовых примеров.
- Каталог v1 — ровно 42 файла (списки в Task 3–6).
- Правила выбора (фиксируются в SKILL.md): default = ни одного паттерна; максимум 1–3 паттерна на задачу; consistency — существующий стиль проекта приоритетен.
- Лицензия: MIT.

## File Structure

```
<repo>/
├── skills/architecture-patterns/     # single source of truth
│   ├── SKILL.md                      # Task 2 (полный текст в плане)
│   ├── patterns/
│   │   ├── code/                    # 24 файла — Task 4, 5
│   │   ├── component/               # 8 файлов — Task 6
│   │   └── system/                  # 10 файлов — Task 7
│   └── references/
│       ├── anti-patterns.md          # Task 3
│       └── decision-tree.md          # Task 3
├── scripts/
│   ├── validate.sh                   # Task 1
│   ├── test-validate.sh              # Task 1
│   └── fixtures/…                   # Task 1
├── install.sh                        # Task 8
├── evals/scenarios.md                # Task 8 (прогон — Task 10)
├── AGENTS.md                         # Task 8
├── README.md                         # Task 8
└── .gitignore                        # Task 8
```

Каждый файл паттерна — один паттерн, один уровень, имя файла = имя паттерна (kebab-case). Ответственность файлов: SKILL.md = «как выбирать», паттерны = «что и когда», references = «как маршрутизировать» и «чего не делать», scripts = «формат не сломали», install.sh = «попадает в агентов».

---

### Task 1: Валидатор формата + тесты (test infrastructure)

**Files:**
- Create: `scripts/validate.sh`
- Create: `scripts/test-validate.sh`
- Create: `scripts/fixtures/good/SKILL.md`, `scripts/fixtures/good/patterns/code/alpha.md`, `scripts/fixtures/good/references/anti-patterns.md`, `scripts/fixtures/good/references/decision-tree.md`
- Create: `scripts/fixtures/bad-name/SKILL.md`, `scripts/fixtures/bad-name/patterns/code/alpha.md`, `scripts/fixtures/bad-name/references/anti-patterns.md`, `scripts/fixtures/bad-name/references/decision-tree.md`
- Create: `scripts/fixtures/bad-lines/` (копия good, alpha.md укорочен до 30 строк)
- Create: `scripts/fixtures/missing-sections/` (копия good, в alpha.md удалена секция `## When NOT to use`)
- Create: `scripts/fixtures/fenced-code/` (копия good, в alpha.md добавлен fenced block)

**Interfaces:**
- Consumes: ничего (первая задача).
- Produces: `scripts/validate.sh <skill-dir> [--check-links]` — exit 0/1, сообщения `ok:`/`FAIL:` в stdout/stderr. Все последующие задачи вызывают его.

Чек-листы валидатора (все обязательны):

1. `SKILL.md` существует; frontmatter: `name` = basename каталога и совпадает с `^[a-z0-9]+(-[a-z0-9]+)*$`; `description` — одна строка, длина 1..1024.
2. Тело SKILL.md (строки после закрывающего `---`) < 500 строк.
3. В SKILL.md присутствуют секции (порядок): `## When to use`, `## When NOT to use`, `## Reflection protocol`, `## Decision tree`, `## Index`, `## Selection rules`, `## Output format`.
4. В SKILL.md нет fenced block с языковым тегом (строка ```` ``` ```` может содержать только пустую строку/пробелы).
5. Для каждого `patterns/<level>/<name>.md`: 40..80 строк; нет строк, начинающихся с ```` ``` ````; секции в строго возрастающем порядке строк: `## One-liner` < `## Symptoms` < `## Solution` < `## When to use` < `## When NOT to use` < `## Trade-offs` < `## Related`.
6. `references/anti-patterns.md` и `references/decision-tree.md` существуют, без fenced блоков.
7. `--check-links`: каждая ссылка вида `patterns/[a-z0-9/_.-]*\.md`, найденная в SKILL.md, references/*.md и patterns/**/*.md, указывает на существующий файл; каждый файл `patterns/**.md` упомянут в SKILL.md (индекс полон).

- [ ] **Step 1: Написать тесты (fixtures + test-validate.sh)** — ТЕСТЫ ПЕРВЫЕ

Создай `scripts/fixtures/good/` — минимально валидный скилл:

`scripts/fixtures/good/SKILL.md`:

```markdown
---
name: good
description: Fixture skill used by the validator tests. Use when testing.
---

# Good

## When to use
- Testing the validator.

## When NOT to use
- Never in production.

## Reflection protocol
- Fill the checklist.

## Decision tree
Symptom → file:
- anything → patterns/code/alpha.md

## Index
patterns/code/alpha.md — fixture pattern

## Selection rules
1. Default: no pattern.

## Output format
Level / Chosen / Rejected.
```

`scripts/fixtures/good/patterns/code/alpha.md` — ровно 45 строк, шаблон (см. ниже), без fenced блоков:

```markdown
# Alpha

## One-liner
Fixture pattern for validator tests.

## Symptoms
- Symptom one.
- Symptom two.
- Symptom three.
- Symptom four.
- Symptom five.

## Solution
- Role one.
- Role two.
- Rule three.

## When to use
- When symptom matches.
- When structure is right.

## When NOT to use
- When the problem is trivial.
- When a plain solution fits.

## Trade-offs
- vs plain: more structure, more indirection.

## Related
- patterns/code/alpha.md — self reference for link checks.
```

(Дострой файл до ровно 45 строк пустыми строками/буллетами при необходимости — валидатор требует 40..80.)

`scripts/fixtures/good/references/anti-patterns.md` и `decision-tree.md` — по 5+ строк прозы, без fenced блоков.

Копии с дефектами:
- `bad-name/`: как good, но `name: Bad_Skill`.
- `bad-lines/`: как good, но `alpha.md` = 30 строк.
- `missing-sections/`: как good, но в `alpha.md` удалена секция `## When NOT to use` (остальные как есть).
- `fenced-code/`: как good, но в `alpha.md` вставлен блок:

````markdown
```python
def f(): pass
```
````

`scripts/test-validate.sh`:

```bash
#!/usr/bin/env bash
# Tests for scripts/validate.sh. Run: bash scripts/test-validate.sh
set -uo pipefail
cd "$(dirname "$0")/.."

PASS=0; FAIL=0
expect() { # expect <fixture-dir> <pass|fail>
  local dir="$1" want="$2" got
  if bash scripts/validate.sh "scripts/fixtures/$dir" >/dev/null 2>&1; then got=pass; else got=fail; fi
  if [ "$got" = "$want" ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); echo "MISMATCH: $dir wanted $want got $got" >&2; fi
}
expect good pass
expect bad-name fail
expect bad-lines fail
expect missing-sections fail
expect fenced-code fail

echo "test-validate: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
```

- [ ] **Step 2: Прогнать тесты — должны провалиться**

Run: `bash scripts/test-validate.sh`
Expected: FAIL — `scripts/validate.sh` не существует (все expect дают `got=fail`, в том числе `good` → MISMATCH).

- [ ] **Step 3: Написать `scripts/validate.sh`**

```bash
#!/usr/bin/env bash
# Validate the architecture-patterns skill format rules.
# Usage: scripts/validate.sh <skill-dir> [--check-links]
# Exit 0 when all checks pass, 1 otherwise.
set -uo pipefail

SKILL_DIR="${1:-skills/architecture-patterns}"
CHECK_LINKS=0
[ "${2:-}" = "--check-links" ] && CHECK_LINKS=1

ERRORS=0
fail() { echo "FAIL: $*" >&2; ERRORS=$((ERRORS + 1)); }
ok()   { echo "ok:   $*"; }

[ -d "$SKILL_DIR" ] || { echo "skill dir not found: $SKILL_DIR" >&2; exit 1; }
SKILL_MD="$SKILL_DIR/SKILL.md"
[ -f "$SKILL_MD" ] || { echo "missing $SKILL_MD" >&2; exit 1; }

# --- 1. frontmatter: name, description -------------------------------------
fm_end=$(awk 'NR>1 && /^---$/ {print NR; exit}' "$SKILL_MD")
[ -n "$fm_end" ] || { echo "no closing frontmatter in $SKILL_MD" >&2; exit 1; }
fm=$(head -n "$fm_end" "$SKILL_MD")

name=$(printf '%s\n' "$fm" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//' | tr -d ' ')
if ! printf '%s' "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  fail "frontmatter name '$name' violates ^[a-z0-9]+(-[a-z0-9]+)*$"
else
  ok "frontmatter name format"
fi
if [ "$name" != "$(basename "$SKILL_DIR")" ]; then
  fail "name '$name' != directory name '$(basename "$SKILL_DIR")'"
else
  ok "name matches directory"
fi

desc=$(printf '%s\n' "$fm" | grep -E '^description:' | head -1 | sed 's/^description:[[:space:]]*//' | sed 's/[[:space:]]*$//')
dlen=${#desc}
if [ "$dlen" -lt 1 ] || [ "$dlen" -gt 1024 ]; then
  fail "description length $dlen outside 1..1024"
else
  ok "description length $dlen"
fi

# --- 2. body length < 500 ---------------------------------------------------
body_lines=$(( $(wc -l < "$SKILL_MD") - fm_end ))
if [ "$body_lines" -ge 500 ]; then
  fail "SKILL.md body is $body_lines lines (must be < 500)"
else
  ok "SKILL.md body $body_lines lines"
fi

# --- 3. required SKILL.md sections, in order ------------------------------
prev=0
for sec in "## When to use" "## When NOT to use" "## Reflection protocol" "## Decision tree" "## Index" "## Selection rules" "## Output format"; do
  line=$(grep -n -F "$sec" "$SKILL_MD" | head -1 | cut -d: -f1)
  if [ -z "$line" ]; then fail "SKILL.md missing section '$sec'"; continue; fi
  if [ "$line" -le "$prev" ]; then fail "SKILL.md section '$sec' out of order"; continue; fi
  prev=$line
done
[ "$ERRORS" -eq 0 ] && ok "SKILL.md sections in order"

# --- 4. no tagged fenced blocks in SKILL.md --------------------------------
tagged=$(grep -nE '^```[A-Za-z]' "$SKILL_MD" | head -1 | cut -d: -f1 || true)
if [ -n "$tagged" ]; then fail "SKILL.md has tagged fenced block at line $tagged"; else ok "SKILL.md no tagged fences"; fi

# --- 5. pattern files -------------------------------------------------------
for f in "$SKILL_DIR"/patterns/*/*.md; do
  [ -e "$f" ] || continue
  rel=${f#"$SKILL_DIR"/}
  lines=$(wc -l < "$f")
  if [ "$lines" -lt 40 ] || [ "$lines" -gt 80 ]; then fail "$rel: $lines lines (must be 40..80)"; fi
  fence=$(grep -nE '^```' "$f" | head -1 | cut -d: -f1 || true)
  if [ -n "$fence" ]; then fail "$rel: fenced block at line $fence"; fi
  prev=0
  for sec in "## One-liner" "## Symptoms" "## Solution" "## When to use" "## When NOT to use" "## Trade-offs" "## Related"; do
    line=$(grep -n -F "$sec" "$f" | head -1 | cut -d: -f1)
    if [ -z "$line" ]; then fail "$rel: missing section '$sec'"; continue; fi
    if [ "$line" -le "$prev" ]; then fail "$rel: section '$sec' out of order"; continue; fi
    prev=$line
  done
  [ "$ERRORS" -eq 0 ] && ok "$rel sections"
done

# --- 6. references ----------------------------------------------------------
for rf in anti-patterns.md decision-tree.md; do
  f="$SKILL_DIR/references/$rf"
  if [ ! -f "$f" ]; then fail "missing references/$rf"; continue; fi
  fence=$(grep -nE '^```' "$f" | head -1 | cut -d: -f1 || true)
  if [ -n "$fence" ]; then fail "references/$rf: fenced block at line $fence"; fi
done
[ "$ERRORS" -eq 0 ] && ok "references present, no fences"

# --- 7. link check (opt-in) --------------------------------------------------
if [ "$CHECK_LINKS" -eq 1 ]; then
  links=$(grep -rhoE 'patterns/[a-z0-9/_.-]*\.md' "$SKILL_DIR" | sort -u || true)
  for l in $links; do
    [ -f "$SKILL_DIR/$l" ] || fail "dangling link: $l"
  done
  for f in "$SKILL_DIR"/patterns/*/*.md; do
    [ -e "$f" ] || continue
    rel=${f#"$SKILL_DIR"/}
    grep -qF "$rel" "$SKILL_MD" || fail "not in SKILL.md index: $rel"
  done
  [ "$ERRORS" -eq 0 ] && ok "links resolve, index complete"
fi

[ "$ERRORS" -eq 0 ] && { echo "validate: OK"; exit 0; } || { echo "validate: $ERRORS error(s)"; exit 1; }
```

(Правило: `scripts/validate.sh` — единственный источник формальных проверок; при правке правил валидатора сначала правятся тесты, потом валидатор.)

- [ ] **Step 4: Прогнать тесты — должны пройти**

Run: `bash scripts/test-validate.sh`
Expected: `test-validate: PASS=5 FAIL=0`

- [ ] **Step 5: Commit**

```bash
git add scripts/
git commit -m "test: format validator for the architecture-patterns skill"
```

---

### Task 2: SKILL.md (мета-скилл)

**Files:**
- Create: `skills/architecture-patterns/SKILL.md`
- Create: `skills/architecture-patterns/references/decision-tree.md`
- Create: `skills/architecture-patterns/references/anti-patterns.md`

**Interfaces:**
- Consumes: `scripts/validate.sh` (Task 1).
- Produces: полный SKILL.md, на который ссылаются все паттерн-файлы (индекс), + references. Формат вывода рефлексии фиксируется здесь — eval-сценарии (Task 9) проверяют именно его.

- [ ] **Step 1: Написать SKILL.md целиком**

Текст (не сокращать; это final-контент):

````markdown
---
name: architecture-patterns
description: Reflection protocol, decision tree and pattern catalogue for choosing software architecture and design patterns. Use before designing system architecture, creating a new module/service/class structure, choosing among design patterns, or refactoring tangled code. Covers code-level patterns (strategy, observer, factory, builder, DI, repository, unit of work, data mapper, DTO, specification, value object, aggregate, facade, adapter, decorator, state, template method, command, chain of responsibility, mediator, memoization, cache-aside, pub/sub, feature flag), component-level (hexagonal, clean architecture, layered, modular monolith, event-driven, microservices, plugin architecture, BFF) and system-level (monolith vs microservices, CQRS, event sourcing, outbox, saga, circuit breaker, retry with backoff, bulkhead, idempotency, strangler fig). Do NOT use for trivial edits, typos, renames, or small bug fixes that do not change structure.
---

# Architecture Patterns

Purpose: decide which patterns fit the task and the project — and decide NOT to use patterns. A pattern is applied only when its symptoms match. The default answer is "no pattern".

## When to use

- Starting a new project, service, or module (architecture decision).
- Creating a new class structure, module boundary, or data flow.
- Choosing between design patterns for a concrete task.
- Refactoring code that feels tangled, over-coupled, or duplicated.
- The user explicitly asks about architecture or patterns.

## When NOT to use

- Trivial edits: typos, renames, small bug fixes (roughly <= 50 changed lines) that do not change structure.
- The task fully determines the structure (e.g. "add this column to this table").
- The project already has a convention that covers this case — just follow it.

Tie-breaker question: "Would a plain implementation without any pattern fail?" If no — write plain code and stop.

## Reflection protocol

Fill this block before selecting patterns. Do not skip it. For an existing codebase, check the existing style before answering (search for similar code first).

- Task: new | modify | refactor — scope: function / file / module / service
- Project: size, team size, change frequency, domain complexity
- Existing style: patterns/structures already present in the codebase
- Constraints: stack, infrastructure, team skills, cost
- Default check: is a plain solution without any pattern sufficient? (yes -> stop here, write plain code)

## Decision tree

Read the pattern file in full before applying it. Never apply from memory.

### Code level

- Many branches on "type"/variant, behavior chosen at runtime, new variants break existing code → patterns/code/strategy.md
- One event must reach several independent consumers; A changes imply B, C, D updates → patterns/code/observer.md
- Object creation scattered (new with the same params), product family varies → patterns/code/factory-method.md
- Object with many optional parameters, telescoping constructors → patterns/code/builder.md
- Collaborators hardcoded (new inside class), hard to test, swapping implementations → patterns/code/dependency-injection.md
- Data access calls inside business code, hard to swap storage → patterns/code/repository.md
- Several entities must commit atomically, partial saves, lost updates → patterns/code/unit-of-work.md
- Model leaks persistence details or model == table and you need a boundary → patterns/code/data-mapper.md
- Data crosses a layer boundary (API/DB/clients), entities leak out, accidental mutation → patterns/code/dto.md
- The same query criteria duplicated in many places, composable conditions → patterns/code/specification.md
- Thing identified by its attributes, not by identity; mutable "entity" that should be immutable → patterns/code/value-object.md
- Invariants span several entities, partial updates, concurrent write conflicts → patterns/code/aggregate.md
- Client must use many classes of a subsystem for one operation → patterns/code/facade.md
- Must integrate a third-party/legacy API whose interface you cannot change → patterns/code/adapter.md
- Add caching/logging/behavior to an existing implementation without touching it, combinable behaviors → patterns/code/decorator.md
- Object has many states, transitions, if/else on state, invalid states → patterns/code/state.md
- Same algorithm in several places with small step differences → patterns/code/template-method.md
- Actions must be queued, logged, undone, or retried → patterns/code/command.md
- Which handler serves a request is not known up front; adding handlers changes the caller → patterns/code/chain-of-responsibility.md
- N objects call each other directly, spaghetti of cross-calls → patterns/code/mediator.md
- Expensive pure computation repeated with the same arguments → patterns/code/memoization.md
- Expensive data fetched repeatedly, N+1 queries, TTL/invalidation questions → patterns/code/cache-aside.md
- Producers must not know consumers; cross-module coupling through direct calls → patterns/code/pub-sub.md
- Ship behavior before it is ready, kill switch, gradual rollout → patterns/code/feature-flag.md

### Component level

- Domain code tangled with framework/DB/API specifics, cannot test or swap infrastructure → patterns/component/hexagonal.md
- Dependencies point outward (domain depends on framework), layers unclear → patterns/component/clean-architecture.md
- Everything in one layer, "god service", UI talks to the DB directly → patterns/component/layered.md
- One deployable that grows, modules touch each other's internals → patterns/component/modular-monolith.md
- Synchronous call chains between modules, cascading failures, latency under load → patterns/component/event-driven.md
- Several teams cannot ship independently, deploy bottleneck, scale by part → patterns/component/microservices.md
- Core must be extended by third parties without redeploying, versioned behavior → patterns/component/plugin-architecture.md
- Different frontends need different slices of the same backend, over-fetching → patterns/component/bff.md

### System level

- Choosing how to decompose the system at project start or growth → patterns/system/monolith-vs-microservices.md
- Complex write invariants plus divergent read projections, different scaling needs → patterns/system/cqrs.md
- Audit of changes required, temporal queries, rebuild state from history → patterns/system/event-sourcing.md
- Database write plus message publish must be atomic; events lost on crash → patterns/system/outbox.md
- Long business process spans several services, multi-step, needs compensation → patterns/system/saga.md
- A slow/failing dependency drags down callers, timeouts, cascades → patterns/system/circuit-breaker.md
- Transient failures (network blips, 503s) cause real errors → patterns/system/retry-with-backoff.md
- One slow dependency exhausts the shared resource pool → patterns/system/bulkhead.md
- At-least-once delivery / retries produce duplicates → patterns/system/idempotency.md
- Legacy system must be replaced incrementally, no big-bang rewrite → patterns/system/strangler-fig.md

## Index

One line per pattern file. Full catalogue:

Code level:
- patterns/code/strategy.md — interchangeable algorithms, chosen at runtime
- patterns/code/observer.md — many subscribers to one event
- patterns/code/factory-method.md — centralized object creation
- patterns/code/builder.md — stepwise construction of a complex object
- patterns/code/dependency-injection.md — explicit dependencies, swappable implementations
- patterns/code/repository.md — collection abstraction over persistence
- patterns/code/unit-of-work.md — atomic commit of a set of changes
- patterns/code/data-mapper.md — persistence separated from the domain model
- patterns/code/dto.md — data shape for a layer boundary
- patterns/code/specification.md — composable query criteria
- patterns/code/value-object.md — identity by value, immutable
- patterns/code/aggregate.md — consistency boundary for writes
- patterns/code/facade.md — simple interface over a complex subsystem
- patterns/code/adapter.md — translates an incompatible interface
- patterns/code/decorator.md — adds behavior at runtime
- patterns/code/state.md — object states and transitions
- patterns/code/template-method.md — fixed algorithm with variable steps
- patterns/code/command.md — action as an object
- patterns/code/chain-of-responsibility.md — handlers pass the request along
- patterns/code/mediator.md — centralizes interaction between objects
- patterns/code/memoization.md — caches a pure computation
- patterns/code/cache-aside.md — caches expensive data with invalidation
- patterns/code/pub-sub.md — decouples producers and consumers by topic
- patterns/code/feature-flag.md — toggles behavior by condition

Component level:
- patterns/component/hexagonal.md — core isolated from infrastructure via ports
- patterns/component/clean-architecture.md — layers by inward dependencies
- patterns/component/layered.md — presentation / service / data separation
- patterns/component/modular-monolith.md — one deployable, strict module boundaries
- patterns/component/event-driven.md — asynchronous communication via events
- patterns/component/microservices.md — services per bounded context
- patterns/component/plugin-architecture.md — extension without redeploy
- patterns/component/bff.md — backend aggregation per frontend

System level:
- patterns/system/monolith-vs-microservices.md — decomposition decision by criteria
- patterns/system/cqrs.md — separate read and write models
- patterns/system/event-sourcing.md — history as the source of truth
- patterns/system/outbox.md — reliable event publishing from the database
- patterns/system/saga.md — long-running process across services
- patterns/system/circuit-breaker.md — protection from a failing dependency
- patterns/system/retry-with-backoff.md — retries for transient failures
- patterns/system/bulkhead.md — isolated resources per dependency
- patterns/system/idempotency.md — duplicates have the same effect
- patterns/system/strangler-fig.md — incremental migration off legacy

## Selection rules

1. Default: no pattern. Apply a pattern only when the symptoms in its "When to use" match the task.
2. Maximum 1-3 patterns per task. If you need more, stop and re-check the symptoms.
3. Consistency: the project's existing style takes priority over a "better" pattern. Introduce a new pattern only with an explicit justification in your answer.
4. Read the pattern file in full before applying it (never from memory).
5. Do not combine conflicting patterns — see references/anti-patterns.md.
6. The "When NOT to use" section of a pattern is as important as "When to use".

For conflicts and over-engineering signals, read references/anti-patterns.md. For the full symptom table, see references/decision-tree.md.

## Output format

Before writing code, print this block (keep it 5-10 lines):

- Level: code | component | system
- Chosen: pattern (file) — why (one line)
- Rejected: pattern — why not (only if there were candidates)
- Consistency: matches project style | new project: adopted ...

Then write the code following the chosen pattern(s).
````

- [ ] **Step 2: Написать `references/decision-tree.md`** (final-контент, не сокращать)

````markdown
# Decision tree (full)

Expanded routing table. `SKILL.md` has the one-line version; this file has full symptom lists and "not when" notes. Use it when the one-line symptom in `SKILL.md` is not enough to decide.

## Contents
- Code level (24 patterns)
- Component level (8 patterns)
- System level (10 patterns)

## Code level

### strategy (patterns/code/strategy.md)
Symptoms:
- if/else or switch on a "type"/"variant" field
- adding a new variant edits existing code
- behavior is chosen at runtime (user input, config, environment)
- the same branching is repeated in several places
Not when: two variants with stable logic — if/else is enough.

### observer (patterns/code/observer.md)
Symptoms:
- "when A changes, update B, C, D"
- A accumulates knowledge about B, C, D
- adding a consumer changes A
- the same notification is duplicated in several places
Not when: a single consumer (call directly); ordering between consumers matters.

### factory-method (patterns/code/factory-method.md)
Symptoms:
- object creation with the same parameters is scattered (new everywhere)
- the product family varies by platform/environment
- creation logic is duplicated
Not when: creation is trivial, there is a single product class.

### builder (patterns/code/builder.md)
Symptoms:
- a constructor with 4+ parameters
- telescoping overloads
- an object with mostly-default fields
- configuration via a chain of setters after construction
Not when: 3 or fewer meaningful parameters.

### dependency-injection (patterns/code/dependency-injection.md)
Symptoms:
- collaborators are created inside the class (new everywhere)
- hard to test without real collaborators
- swapping implementations is impossible
- a deep object graph is built manually
Not when: a small script with one entry point; trivial collaborators.

### repository (patterns/code/repository.md)
Symptoms:
- data access calls live inside business code
- business logic cannot be tested without the database
- storage may need to be swapped
- queries are scattered and duplicated
Not when: simple CRUD over a single table.

### unit-of-work (patterns/code/unit-of-work.md)
Symptoms:
- manual "save this, then that"
- partial commits on failure
- the same object is saved twice (identity problems)
- lost updates across entities
Not when: one entity per request; read-only work.

### data-mapper (patterns/code/data-mapper.md)
Symptoms:
- the model knows about tables/columns
- persistence details live in the domain
- model == table and any change ripples
- storage formats leak into business code
Not when: the model truly is the table (then active record is acceptable).

### dto (patterns/code/dto.md)
Symptoms:
- domain entities appear in API responses
- clients depend on internal structure
- accidental mutation of shared objects
- different consumers need different shapes
Not when: an internal layer with a single consumer.

### specification (patterns/code/specification.md)
Symptoms:
- the same WHERE/conditions are duplicated
- "findXWhereY" methods are proliferating
- conditions are combined ad hoc
- criteria differ slightly per call
Not when: 1-2 queries.

### value-object (patterns/code/value-object.md)
Symptoms:
- an "entity" that has no lifecycle
- equality should be by value, not by id
- shared mutable data (address, money, period)
Not when: there is a real lifecycle (then entity); the value is a primitive.

### aggregate (patterns/code/aggregate.md)
Symptoms:
- invariants span several entities
- partial updates / inconsistent state
- concurrent writes to the same data
- "which entity owns this rule?" is unclear
Not when: a small domain with no cross-entity invariants; reads dominate.

### facade (patterns/code/facade.md)
Symptoms:
- the client uses several classes for one operation
- the subsystem API is wide
- the client must know subsystem internals
Not when: the subsystem is simple; the client needs fine-grained control.

### adapter (patterns/code/adapter.md)
Symptoms:
- integrating an API you cannot change
- a legacy interface is different from yours
- several external services, similar but different
Not when: you can change the source directly.

### decorator (patterns/code/decorator.md)
Symptoms:
- add caching/logging/timeout/retry without touching the core
- behaviors are combinable (cache + log + retry)
- behavior varies per instance
Not when: a fixed set of variants at compile time.

### state (patterns/code/state.md)
Symptoms:
- if/else on a state field
- invalid state combinations are possible
- adding a state breaks several places
- transitions are scattered
Not when: 2-3 states with rare transitions.

### template-method (patterns/code/template-method.md)
Symptoms:
- the same algorithm in several places with small step differences
- variants differ in 1-2 steps
- the order of steps must be preserved
Not when: the differences are large (then strategy).

### command (patterns/code/command.md)
Symptoms:
- actions must be queued, delayed, or logged
- undo/redo is required
- actions must be replayed or audited
Not when: a simple synchronous call with no history.

### chain-of-responsibility (patterns/code/chain-of-responsibility.md)
Symptoms:
- which handler serves a request is not known up front
- if/else on handler type
- adding a handler changes the caller
Not when: a single handler; fixed routing.

### mediator (patterns/code/mediator.md)
Symptoms:
- objects call each other in a web (A->B, B->C, C->A)
- adding an object changes several others
- the interaction graph is spaghetti
Not when: 2-3 objects; one-directional interaction.

### memoization (patterns/code/memoization.md)
Symptoms:
- an expensive pure computation repeats with the same arguments
- the function is pure (no side effects)
- arguments are hashable/comparable
Not when: a cheap computation; an impure function; unbounded arguments.

### cache-aside (patterns/code/cache-aside.md)
Symptoms:
- repeated expensive fetches (database, API)
- N+1 queries
- TTL/invalidation questions
- the data changes rarely
Not when: the data is cheap; strong consistency is required.

### pub-sub (patterns/code/pub-sub.md)
Symptoms:
- the producer must know the consumers
- cross-module coupling through direct calls
- adding a consumer changes the producer
Not when: a single consumer; a response is required (synchronous call).

### feature-flag (patterns/code/feature-flag.md)
Symptoms:
- shipping behavior before it is ready
- kill switch
- gradual rollout / A/B
Not when: a permanent branch (then strategy/state).

## Component level

### hexagonal (patterns/component/hexagonal.md)
Symptoms:
- domain code imports framework/DB/API specifics
- the core cannot be tested without infrastructure
- swapping the database or API means a rewrite
- the framework dictates the structure
Not when: a small app where the framework is the app.

### clean-architecture (patterns/component/clean-architecture.md)
Symptoms:
- the domain depends on the UI/DB
- layers are unclear; "where does this code go?" is a recurring question
- the framework leaks into business logic
Not when: a small project.

### layered (patterns/component/layered.md)
Symptoms:
- everything lives in one layer ("god service")
- the UI talks to the database directly
- business logic sits in the controller
Not when: a small script; two layers are enough.

### modular-monolith (patterns/component/modular-monolith.md)
Symptoms:
- a "big ball of mud"
- modules touch each other's internals
- one change breaks everything
- deploy coupling; no clear ownership
Not when: a small app (one module is enough).

### event-driven (patterns/component/event-driven.md)
Symptoms:
- synchronous call chains between modules
- cascading failures
- latency under load
- a module must react to many things
Not when: a simple request-response.

### microservices (patterns/component/microservices.md)
Symptoms:
- teams cannot ship independently
- a deploy bottleneck
- scale by part
- the monolith is a deploy risk
Not when: one team; a small domain.

### plugin-architecture (patterns/component/plugin-architecture.md)
Symptoms:
- the core must be extended by third parties
- different versions of behavior
- the core grows with every extension
Not when: a closed set of extensions.

### bff (patterns/component/bff.md)
Symptoms:
- web and mobile need different slices of the same data
- over-fetching
- the client assembles many calls where one is enough
Not when: a single client.

## System level

### monolith-vs-microservices (patterns/system/monolith-vs-microservices.md)
Symptoms:
- a decomposition choice at project start
- a monolith that is hard to change
- teams are blocked by each other
- scale/deploys are uneven
Not when: a small project (then plain monolith).

### cqrs (patterns/system/cqrs.md)
Symptoms:
- complex write invariants
- divergent read projections
- reads and writes scale differently
- one model does not fit both
Not when: simple CRUD.

### event-sourcing (patterns/system/event-sourcing.md)
Symptoms:
- an audit of changes is required
- temporal queries ("what was the state in March?")
- state must be rebuildable
- complex invariants over time
Not when: you do not need history.

### outbox (patterns/system/outbox.md)
Symptoms:
- a database write plus a message publish must be atomic
- events lost on crash
- duplicated/lost events
Not when: the message is optional.

### saga (patterns/system/saga.md)
Symptoms:
- a process spans 3+ services
- failure requires compensation
- a multi-step or multi-day process
Not when: one service (a local transaction is enough).

### circuit-breaker (patterns/system/circuit-breaker.md)
Symptoms:
- a slow/failing dependency drags down the caller
- timeouts accumulate
- cascading failures
Not when: the dependency is local.

### retry-with-backoff (patterns/system/retry-with-backoff.md)
Symptoms:
- transient failures cause real errors
- retries without backoff create a storm
Not when: a non-idempotent operation; a permanent failure.

### bulkhead (patterns/system/bulkhead.md)
Symptoms:
- one slow dependency exhausts the shared pool
- all requests wait
- cascading exhaustion
Not when: a single dependency.

### idempotency (patterns/system/idempotency.md)
Symptoms:
- retries produce duplicates
- at-least-once delivery
- processes get re-executed
Not when: at-most-once is acceptable; read-only operations.

### strangler-fig (patterns/system/strangler-fig.md)
Symptoms:
- a legacy system must be replaced
- a big-bang rewrite is too risky
- the legacy must keep working during migration
Not when: a small legacy (a rewrite is enough).
````

- [ ] **Step 3: Написать `references/anti-patterns.md`** (final-контент, не сокращать)

````markdown
# Anti-patterns and over-engineering signals

Read this file when: (a) you are about to combine multiple patterns in one task, (b) a task seems to need more than 3 patterns, (c) you are unsure whether a pattern is justified, (d) you are refactoring and the code smells "patterned".

## Over-engineering signals

If two or more of these are true, stop and re-check the symptoms:

- The pattern is introduced "for the future" (there is no current symptom).
- The task changes fewer than ~50 lines of code.
- The pattern adds a class or interface that nothing currently implements.
- You cannot name the concrete symptom that the pattern solves.
- You cannot say how a plain implementation would fail.
- You are about to combine 4+ patterns in one task.

Default resolution: write the plain implementation and note where it would need to change when the symptom appears.

## Conflicting combinations

| Combination | Problem | Resolution |
|---|---|---|
| Repository + active record | Two persistence abstractions fighting | Pick one: repository (clean model) or active record (model == table) |
| Microservices without module boundaries | Distributed complexity with none of the benefits | Start with a modular monolith, then extract |
| Event-driven + synchronous calls in a cycle | Cycles through events and calls create timing messes | One direction: events between modules, calls only inward |
| CQRS on simple CRUD | Two models for one table | Plain single model; CQRS only with divergent read/write needs |
| Saga for a single-service process | Distributed machinery for a local transaction | Local transaction + unit of work |
| Microservices for one team | Coordination cost without team boundaries | Monolith or modular monolith |
| Observer + mediator + pub-sub all at once | Three coupling mechanisms for one event | Pick one by scope: local (observer), module (mediator), system (event-driven) |
| Feature flag as a permanent branch | Flags outlive their purpose | Convert to strategy/state or delete |
| Hexagonal with framework in the domain | Ports exist but the core still imports the framework | Move framework code to adapters |

## Choosing between similar patterns (quick disambiguation)

- Strategy vs state: strategy = interchangeable algorithms without history; state = transitions with history (state remembers where it came from).
- Observer vs pub-sub: observer = local objects in one scope; pub-sub = cross-module, topics, delivery semantics.
- Decorator vs middleware/chain: decorator wraps one instance with behavior; a chain routes a request through handlers.
- Repository vs data mapper: repository = collection API and queries; data mapper = mapping model to storage. Often used together.
- Facade vs adapter: facade simplifies your own subsystem; adapter translates someone else's interface.
- Caching: memoization (pure function) vs cache-aside (external data).

## When to stop

- "We should use X because it is best practice" — no. Symptom first.
- "The architecture should be future-proof" — no. Simplicity first; patterns are added when symptoms appear.
- One project = one dominant style. If the project is a modular monolith with repository and unit of work, new code continues that style unless symptoms say otherwise.
````

- [ ] **Step 4: Прогнать валидатор**

Run: `bash scripts/validate.sh skills/architecture-patterns`
Expected: `validate: OK` (ссылки на ещё не созданные паттерн-файлы проверяются только в `--check-links` режиме — это нормально до Task 7).

- [ ] **Step 5: Commit**

```bash
git add skills/
git commit -m "feat: architecture-patterns meta skill (SKILL.md + references)"
```

---

### Task 3: patterns/code — batch 1 (12 файлов)

**Files:**
- Create: `skills/architecture-patterns/patterns/code/strategy.md`
- Create: `skills/architecture-patterns/patterns/code/observer.md`
- Create: `skills/architecture-patterns/patterns/code/factory-method.md`
- Create: `skills/architecture-patterns/patterns/code/builder.md`
- Create: `skills/architecture-patterns/patterns/code/dependency-injection.md`
- Create: `skills/architecture-patterns/patterns/code/repository.md`
- Create: `skills/architecture-patterns/patterns/code/unit-of-work.md`
- Create: `skills/architecture-patterns/patterns/code/data-mapper.md`
- Create: `skills/architecture-patterns/patterns/code/dto.md`
- Create: `skills/architecture-patterns/patterns/code/specification.md`
- Create: `skills/architecture-patterns/patterns/code/value-object.md`
- Create: `skills/architecture-patterns/patterns/code/aggregate.md`

**Interfaces:**
- Consumes: SKILL.md-индекс (Task 2) — имена файлов должны совпасть со ссылками в индексе; шаблон файла паттерна; `scripts/validate.sh`.
- Produces: 12 файлов паттернов уровня code. Имя файла = имя в индексе (kebab-case).

Шаблон каждого файла (повторяется в каждой batch-задаче):

````markdown
# <Pattern Name>

## One-liner
One sentence: what it is and which problem it solves.

## Symptoms
3-7 bullets: observable signs in the code or task.

## Solution
Bullets: roles/components, rules, invariants. No code.

## When to use
Bullets: conditions for applying (including "instead of what").

## When NOT to use
Bullets: costs, when the plain solution is better.

## Trade-offs
Bullets or a small table: against 1-3 concrete alternatives.

## Related
Bullets: links (full path from the skill root: `patterns/<level>/<name>.md`, max 5), when to go to them.
````

Правила раскрытия brief'а: каждый пункт brief'а раскрывается в 1-3 предложения; итог файла 50-70 строк; английский; не добавлять фактов сверх brief'а; `Related` — полные пути от корня скилла.

Brief'ы (final-контент требований к каждому файлу):

- `strategy.md`
  - One-liner: Encapsulates interchangeable algorithms so behavior can be swapped at runtime without touching the caller.
  - Symptoms: if/else or switch on a "type"/"variant" field; adding a variant edits existing code; behavior chosen at runtime; same branching repeated in several places.
  - Solution: an interface for the algorithm; each algorithm is a separate object; the context holds a reference to one instance and delegates; selection via factory-method or DI.
  - When NOT: two variants with stable logic (if/else is enough); variants are a closed set known at compile time.
  - Trade-offs: vs if/else (indirection vs extensibility); vs enum+switch (runtime swapping vs static exhaustiveness); vs state (stateless algorithms vs transitions with history).
  - Related: `patterns/code/factory-method.md`, `patterns/code/dependency-injection.md`, `patterns/code/state.md`.
- `observer.md`
  - One-liner: Many independent subscribers react to one event without the publisher knowing them.
  - Symptoms: "when A changes, update B, C, D"; A accumulates knowledge about B, C, D; adding a consumer changes A; same notification duplicated.
  - Solution: a subject with subscribe/publish; subscribers implement a handler; the subject knows nothing about subscribers; unsubscribe is mandatory.
  - When NOT: a single consumer (call directly); ordering between subscribers matters (observer does not guarantee it).
  - Trade-offs: vs direct call (decoupling vs call graph); vs pub-sub (local scope vs topics); vs event-driven (objects vs system level).
  - Related: `patterns/code/pub-sub.md`, `patterns/code/mediator.md`, `patterns/component/event-driven.md`.
- `factory-method.md`
  - One-liner: Centralizes object creation: the client asks for a product, the factory decides how it is created.
  - Symptoms: creation with the same parameters scattered (new everywhere); product family varies by platform/environment; creation logic duplicated.
  - Solution: a factory method in a base class or a separate factory; the client depends on the product interface; the factory encapsulates selection and configuration.
  - When NOT: creation is trivial (a constructor is enough); a single product class with no family.
  - Trade-offs: vs constructor (indirection); vs DI (factory = explicit, DI = graph-level); vs abstract factory (one product family vs several — v2).
  - Related: `patterns/code/dependency-injection.md`, `patterns/code/builder.md`, `patterns/code/dto.md`.
- `builder.md`
  - One-liner: Stepwise construction of an object with many optional parameters, without telescoping constructors.
  - Symptoms: a constructor with 4+ parameters; telescoping overloads; an object with mostly-default fields; configuration via setters after construction.
  - Solution: a builder with required parameters in the constructor and optional step methods; an immutable result (build()); fluent steps; validation in build().
  - When NOT: 3 or fewer meaningful parameters; all parameters are required.
  - Trade-offs: vs constructor with defaults (stepwise readability vs one expression); vs config object (typed steps); vs value object (builder constructs, VO is the result).
  - Related: `patterns/code/dto.md`, `patterns/code/factory-method.md`, `patterns/code/value-object.md`.
- `dependency-injection.md`
  - One-liner: A class receives collaborators from outside instead of creating them itself.
  - Symptoms: collaborators created inside the class; hard to test without real collaborators; swapping implementations is impossible; deep object graphs.
  - Solution: dependencies via constructor or method parameters; wiring at a composition root (manual or container); the class declares only the interface it needs.
  - When NOT: a small script with one entry point; the collaborator is a simple value.
  - Trade-offs: vs service locator (explicit dependencies vs hidden lookup); vs hardcoding (testability); manual wiring vs container (explicitness vs automation).
  - Related: `patterns/code/factory-method.md`, `patterns/code/repository.md`, `patterns/component/hexagonal.md`.
- `repository.md`
  - One-liner: An abstraction over a collection of objects: the domain works with a collection, not a database.
  - Symptoms: data access calls inside business code; business logic cannot be tested without the database; storage may need to be swapped; queries scattered.
  - Solution: a repository per aggregate; a query API (find, list, criteria); the implementation hides ORM/SQL; the repository does not leak persistence types.
  - When NOT: simple CRUD over one table (direct ORM calls are enough); ephemeral in-memory data.
  - Trade-offs: vs direct ORM (boundary vs pragmatism); vs data mapper (thicker collection API); vs active record (clean model).
  - Related: `patterns/code/unit-of-work.md`, `patterns/code/data-mapper.md`, `patterns/code/aggregate.md`, `patterns/component/clean-architecture.md`.
- `unit-of-work.md`
  - One-liner: Tracks all changes and commits them atomically as one unit.
  - Symptoms: manual "save this, then that"; partial commits on failure; the same object saved twice (identity); lost updates across entities.
  - Solution: the unit of work registers changed entities; commit applies all changes in one transaction; an identity map deduplicates; rollback on error.
  - When NOT: one entity per request (a direct save is enough); read-only work.
  - Trade-offs: vs per-entity saves (atomicity vs simplicity); vs repository without unit of work (where the transaction boundary lives).
  - Related: `patterns/code/repository.md`, `patterns/code/aggregate.md`, `patterns/code/value-object.md`.
- `data-mapper.md`
  - One-liner: Separates the domain model from its storage form: explicit mapping model to storage.
  - Symptoms: the model knows about tables/columns; persistence details in the domain; model == table and changes ripple; storage formats leak into business code.
  - Solution: a mapper per aggregate (model to storage form); the model has no persistence knowledge; mapping is explicit (no magic).
  - When NOT: the model truly is the table (then active record is acceptable); trivial one-to-one mapping with no transforms.
  - Trade-offs: vs repository (mapper = mapping only, repository = API); vs active record (clean model vs pragmatism); vs DTO (bidirectional vs one-way).
  - Related: `patterns/code/repository.md`, `patterns/code/value-object.md`, `patterns/code/dto.md`.
- `dto.md`
  - One-liner: A dedicated data shape for a layer boundary (API, client, storage).
  - Symptoms: domain entities in API responses; clients depend on internal structure; accidental mutation of shared objects; different consumers need different shapes.
  - Solution: a DTO class per boundary; explicit mapping from the domain; immutability or controlled mutation; DTOs know nothing about the domain.
  - When NOT: internal code where entities are enough (YAGNI); a single consumer with the same shape.
  - Trade-offs: vs returning entities (decoupling vs duplication); vs value object (DTO = boundary shape, VO = domain concept); vs data mapper (DTO = shape, mapper = mechanism).
  - Related: `patterns/code/value-object.md`, `patterns/code/data-mapper.md`, `patterns/component/bff.md`.
- `specification.md`
  - One-liner: Composable, reusable query criteria: conditions as composable objects.
  - Symptoms: the same WHERE/conditions duplicated; "findXWhereY" methods proliferating; conditions combined ad hoc; criteria differ slightly per call.
  - Solution: a specification object (a predicate with and/or/not composition); the repository or query layer evaluates it; criteria are reusable and testable.
  - When NOT: 1-2 queries (plain conditions are enough); static and few criteria.
  - Trade-offs: vs raw conditions (reusability vs readability at call sites); vs query DTO (composable vs flat).
  - Related: `patterns/code/repository.md`, `patterns/code/value-object.md`, `patterns/code/dto.md`.
- `value-object.md`
  - One-liner: A thing identified by its attributes (value), not by identity; immutable.
  - Symptoms: an "entity" with no lifecycle; equality by id where it should be by value; shared mutable data (address, money, period); accidental mutation.
  - Solution: an immutable value object; equality by fields; construction via a factory; the VO validates its own invariants; VOs are nested in entities/aggregates.
  - When NOT: there is a real lifecycle (then entity/aggregate); the value is a primitive.
  - Trade-offs: vs entity (identity vs value); vs plain struct/POJO (invariants and equality); vs DTO (domain concept vs boundary shape).
  - Related: `patterns/code/aggregate.md`, `patterns/code/factory-method.md`, `patterns/code/dto.md`.
- `aggregate.md`
  - One-liner: A consistency boundary: a cluster of entities that changes together under invariants.
  - Symptoms: invariants span several entities; partial updates; concurrent writes to the same data; unclear which entity owns a rule.
  - Solution: an aggregate root as the only entry point; invariants enforced inside the boundary; other aggregates referenced by ID; the aggregate is loaded and saved as a whole.
  - When NOT: a small domain with no cross-entity invariants; reads dominate (projections are enough).
  - Trade-offs: vs per-entity saves (invariants vs granularity); vs distributed transactions (boundary vs service); vs CQRS (write boundary vs read projections).
  - Related: `patterns/code/value-object.md`, `patterns/code/repository.md`, `patterns/code/unit-of-work.md`, `patterns/system/cqrs.md`.

- [ ] **Step 1: Написать 12 файлов по brief'ам** (шаблон выше + раскрытие brief'а по правилам)

- [ ] **Step 2: Прогнать валидатор**

Run: `bash scripts/validate.sh skills/architecture-patterns`
Expected: `validate: OK` (формат; --check-links пока не нужен — остальные паттерны появятся в Task 4-6)

- [ ] **Step 3: Перевёрка качества каждого файла** (чек-лист, вручную): 50-70 строк; все 7 секций; каждый пункт brief'а отражён в соответствующей секции; `Related` — полные пути; английский; нет fenced блоков.

- [ ] **Step 4: Commit**

```bash
git add skills/architecture-patterns/patterns/code
git commit -m "feat: code patterns batch 1 (strategy..aggregate)"
```

---

### Task 4: patterns/code — batch 2 (12 файлов)

**Files:**
- Create: `skills/architecture-patterns/patterns/code/facade.md`
- Create: `skills/architecture-patterns/patterns/code/adapter.md`
- Create: `skills/architecture-patterns/patterns/code/decorator.md`
- Create: `skills/architecture-patterns/patterns/code/state.md`
- Create: `skills/architecture-patterns/patterns/code/template-method.md`
- Create: `skills/architecture-patterns/patterns/code/command.md`
- Create: `skills/architecture-patterns/patterns/code/chain-of-responsibility.md`
- Create: `skills/architecture-patterns/patterns/code/mediator.md`
- Create: `skills/architecture-patterns/patterns/code/memoization.md`
- Create: `skills/architecture-patterns/patterns/code/cache-aside.md`
- Create: `skills/architecture-patterns/patterns/code/pub-sub.md`
- Create: `skills/architecture-patterns/patterns/code/feature-flag.md`

**Interfaces:**
- Consumes: SKILL.md-индекс (Task 2) — имена файлов должны совпасть со ссылками в индексе; шаблон файла паттерна (см. Task 3, тот же шаблон и те же правила раскрытия); `scripts/validate.sh`.
- Produces: ещё 12 файлов паттернов уровня code (всего 24).

Шаблон каждого файла:

````markdown
# <Pattern Name>

## One-liner
One sentence: what it is and which problem it solves.

## Symptoms
3-7 bullets: observable signs in the code or task.

## Solution
Bullets: roles/components, rules, invariants. No code.

## When to use
Bullets: conditions for applying (including "instead of what").

## When NOT to use
Bullets: costs, when the plain solution is better.

## Trade-offs
Bullets or a small table: against 1-3 concrete alternatives.

## Related
Bullets: links (full path from the skill root: `patterns/<level>/<name>.md`, max 5), when to go to them.
````

Правила раскрытия brief'а: каждый пункт brief'а раскрывается в 1-3 предложения; итог файла 50-70 строк; английский; не добавлять фактов сверх brief'а; `Related` — полные пути от корня скилла.

Brief'ы:

- `facade.md`
  - One-liner: A simple interface over a complex subsystem.
  - Symptoms: the client uses several classes for one operation; the subsystem API is wide; the client must know subsystem internals.
  - Solution: a facade class with the operations the client actually needs; the facade delegates and adds no logic; subsystem internals stay hidden; the facade is a thin layer.
  - When NOT: the subsystem is simple (direct use); the client needs fine-grained control (the facade hides it).
  - Trade-offs: vs direct use (simplicity vs flexibility); vs adapter (facade = your own subsystem, adapter = someone else's interface).
  - Related: `patterns/code/adapter.md`, `patterns/component/clean-architecture.md`, `patterns/component/bff.md`.
- `adapter.md`
  - One-liner: Translates an incompatible (third-party/legacy) interface into the one you need.
  - Symptoms: integrating an API you cannot change; a legacy interface is different from yours; several external services with similar but different APIs.
  - Solution: an adapter class implementing your interface and wrapping the external one; conversion at the boundary; the external API is isolated in one place.
  - When NOT: you can change the source directly; the external API already matches (a wrapper adds nothing).
  - Trade-offs: vs rewriting (isolation vs code volume); vs facade (external vs own subsystem); vs decorator (interface vs behavior).
  - Related: `patterns/code/facade.md`, `patterns/code/dependency-injection.md`, `patterns/code/data-mapper.md`.
- `decorator.md`
  - One-liner: Adds behavior to an object at runtime without touching the implementation.
  - Symptoms: add caching/logging/timeout/retry to X without changing X; combinable behaviors (cache + log + retry); behavior varies per instance.
  - Solution: a wrapper with the same interface; the decorator holds a reference and delegates; behaviors are composed in layers; the core stays unchanged.
  - When NOT: a fixed set of 2-3 variants at compile time (inheritance/strategy is enough); behavior is identical for all instances.
  - Trade-offs: vs inheritance (runtime vs static, combinations vs hierarchy); vs middleware (per-instance layers vs a single pipeline); vs strategy (adding behavior vs swapping algorithms).
  - Related: `patterns/code/strategy.md`, `patterns/code/dependency-injection.md`, `patterns/system/retry-with-backoff.md`.
- `state.md`
  - One-liner: Models an object's states and transitions, moving the state machine out of if/else.
  - Symptoms: if/else on a state field; invalid state combinations possible; adding a state breaks several places; transitions scattered.
  - Solution: a state interface (behavior and transitions per state); the context holds the current state; transitions are explicit (to the next state); states are objects.
  - When NOT: 2-3 states with rare transitions (enum + switch is enough); states without behavior (an enum is enough).
  - Trade-offs: vs enum+switch (explicit transitions vs simplicity); vs strategy (state remembers history, strategy is stateless); vs a state machine library (objects vs configuration).
  - Related: `patterns/code/strategy.md`, `patterns/code/observer.md`, `patterns/code/command.md`.
- `template-method.md`
  - One-liner: A fixed algorithm skeleton with variable steps (hooks).
  - Symptoms: the same algorithm in several places with small step differences; variants differ in 1-2 steps; the order of steps must be preserved.
  - Solution: a base class with the algorithm; hooks (abstract or empty methods) for the variable steps; the order is fixed in the base; subclasses override only hooks.
  - When NOT: the differences are large (then strategy); the algorithm changes often (hooks are not enough); you want to avoid inheritance (composition + strategy).
  - Trade-offs: vs inheritance (fixed skeleton vs flexibility); vs strategy (static steps vs runtime algorithms); vs a pipeline (hooks vs composable steps).
  - Related: `patterns/code/strategy.md`, `patterns/code/factory-method.md`, `patterns/code/decorator.md`.
- `command.md`
  - One-liner: An action as an object: queue, log, undo, retry.
  - Symptoms: "execute an action" is a direct call; actions cannot be queued or delayed; no undo; no log of what was done.
  - Solution: a command object with execute(); an optional inverse (for undo); commands are stored, queued, logged; the caller passes a command, not a call.
  - When NOT: a simple synchronous call with no history; the action is trivially idempotent.
  - Trade-offs: vs direct call (object vs call); vs event (command = request to do, event = something happened); vs saga (one action vs a long process).
  - Related: `patterns/code/pub-sub.md`, `patterns/system/saga.md`, `patterns/code/dependency-injection.md`, `patterns/system/idempotency.md`.
- `chain-of-responsibility.md`
  - One-liner: A chain of handlers: each handles the request or passes it along.
  - Symptoms: which handler serves a request is not known up front; if/else on handler type; adding a handler changes the caller.
  - Solution: a handler knows the next one; handle() or pass; the chain is assembled at startup; the client addresses the head of the chain.
  - When NOT: a single handler; fixed routing (a switch is enough); strict and known ordering (a pipeline is enough).
  - Trade-offs: vs switch (extensibility vs clarity); vs observer (a request with a response vs a broadcast event); vs middleware (a chain for requests vs a pipeline for HTTP).
  - Related: `patterns/code/command.md`, `patterns/code/mediator.md`, `patterns/component/event-driven.md`.
- `mediator.md`
  - One-liner: Objects do not talk to each other; they talk to a mediator.
  - Symptoms: A->B, B->C, C->A; adding an object changes N others; the interaction graph is spaghetti.
  - Solution: a mediator with the interaction API; each participant knows only the mediator; the mediator routes; participants stay simple.
  - When NOT: 2-3 objects (direct calls are enough); one-directional interaction (a call is enough).
  - Trade-offs: vs direct calls (graph simplification vs centralization); vs pub-sub (synchronous routing vs broadcast); vs event-driven (objects vs system level).
  - Related: `patterns/code/observer.md`, `patterns/code/pub-sub.md`, `patterns/component/event-driven.md`.
- `memoization.md`
  - One-liner: Caches the results of an expensive pure computation by arguments.
  - Symptoms: the same expensive computation repeats with the same arguments; the function is pure (no side effects); arguments are hashable.
  - Solution: a cache keyed by arguments; on a miss compute and store; invalidation when dependencies change; a bounded cache.
  - When NOT: a cheap computation; an impure function (side effects); unbounded arguments (the cache explodes).
  - Trade-offs: vs recomputation (time vs memory); vs cache-aside (computation vs external data); vs precomputation (lazy vs eager).
  - Related: `patterns/code/cache-aside.md`, `patterns/code/strategy.md`, `patterns/code/decorator.md`.
- `cache-aside.md`
  - One-liner: Caches expensive external data with invalidation; the application manages the cache itself.
  - Symptoms: repeated expensive fetches (database, API); N+1 queries; TTL/invalidation questions; the data changes rarely.
  - Solution: read through the cache, on a miss fetch and store; on write update or invalidate; TTL; an explicit consistency semantic (stale acceptable); invalidation on write.
  - When NOT: the data is cheap or changes on every write (fetch is enough); strong consistency is required (no cache).
  - Trade-offs: vs write-through (simpler vs fresher); vs offline-first (server vs client); vs direct fetch (latency vs consistency).
  - Related: `patterns/code/memoization.md`, `patterns/system/idempotency.md`, `patterns/system/cqrs.md`.
- `pub-sub.md`
  - One-liner: Producers and consumers are decoupled by topics.
  - Symptoms: the producer must know the consumers; cross-module coupling through direct calls; adding a consumer changes the producer.
  - Solution: topics; publish to a topic, subscribe to a topic; explicit delivery semantics (at-least-once, ordering); subscribers are independent.
  - When NOT: a single consumer; local objects (observer is enough); a response is required (synchronous call).
  - Trade-offs: vs observer (scope: modules vs objects); vs queue (durability, ordering); vs direct call (decoupling vs clarity).
  - Related: `patterns/code/observer.md`, `patterns/component/event-driven.md`, `patterns/system/saga.md`, `patterns/system/outbox.md`.
- `feature-flag.md`
  - One-liner: Toggles behavior by a condition without redeploying.
  - Symptoms: shipping behavior before it is ready; a kill switch; gradual rollout; A/B.
  - Solution: a flag as a decision point; the flag is read at runtime; the flag has an owner and a deadline; cleanup deletes the flag and the dead branch.
  - When NOT: a permanent branch (then strategy/state); the decision is made at build time (a config is enough).
  - Trade-offs: vs branch (runtime vs static); vs canary (flag = code behavior, canary = deployment traffic); vs config (binary behavior vs parameters).
  - Related: `patterns/code/strategy.md`, `patterns/system/strangler-fig.md`, `patterns/code/state.md`.

- [ ] **Step 1: Написать 12 файлов по brief'ам**

- [ ] **Step 2: Прогнать валидатор**

Run: `bash scripts/validate.sh skills/architecture-patterns`
Expected: `validate: OK`

- [ ] **Step 3: Перевёрка качества** (тот же чек-лист, что в Task 3 Step 3)

- [ ] **Step 4: Commit**

```bash
git add skills/architecture-patterns/patterns/code
git commit -m "feat: code patterns batch 2 (facade..feature-flag)"
```

---

### Task 5: patterns/component (8 файлов)

**Files:**
- Create: `skills/architecture-patterns/patterns/component/hexagonal.md`
- Create: `skills/architecture-patterns/patterns/component/clean-architecture.md`
- Create: `skills/architecture-patterns/patterns/component/layered.md`
- Create: `skills/architecture-patterns/patterns/component/modular-monolith.md`
- Create: `skills/architecture-patterns/patterns/component/event-driven.md`
- Create: `skills/architecture-patterns/patterns/component/microservices.md`
- Create: `skills/architecture-patterns/patterns/component/plugin-architecture.md`
- Create: `skills/architecture-patterns/patterns/component/bff.md`

**Interfaces:**
- Consumes: SKILL.md-индекс (Task 2); шаблон файла паттерна и правила раскрытия (Task 3); `scripts/validate.sh`.
- Produces: 8 файлов паттернов уровня component.

Шаблон каждого файла:

````markdown
# <Pattern Name>

## One-liner
One sentence: what it is and which problem it solves.

## Symptoms
3-7 bullets: observable signs in the code or task.

## Solution
Bullets: roles/components, rules, invariants. No code.

## When to use
Bullets: conditions for applying (including "instead of what").

## When NOT to use
Bullets: costs, when the plain solution is better.

## Trade-offs
Bullets or a small table: against 1-3 concrete alternatives.

## Related
Bullets: links (full path from the skill root: `patterns/<level>/<name>.md`, max 5), when to go to them.
````

Правила раскрытия brief'а: каждый пункт brief'а раскрывается в 1-3 предложения; итог файла 50-70 строк; английский; не добавлять фактов сверх brief'а; `Related` — полные пути от корня скилла.

Brief'ы:

- `hexagonal.md`
  - One-liner: The application core is isolated from infrastructure via ports and adapters.
  - Symptoms: domain code imports framework/DB/API specifics; the core cannot be tested without infrastructure; swapping database or API means a rewrite; the framework dictates the structure.
  - Solution: the core defines ports (driving and driven); adapters implement the ports (database, API, CLI, UI); dependencies point inward; the core has no framework dependencies.
  - When NOT: a small app where the framework is the app (a script, a demo); the team does not want this discipline.
  - Trade-offs: vs layered (ports vs layers); vs clean architecture (similar goals, different granularity); vs direct use (isolation vs speed).
  - Related: `patterns/component/clean-architecture.md`, `patterns/code/dependency-injection.md`, `patterns/code/repository.md`, `patterns/component/plugin-architecture.md`.
- `clean-architecture.md`
  - One-liner: Layers with dependencies pointing inward: entities, use-cases, interface adapters, frameworks.
  - Symptoms: the domain depends on the UI/DB; layers are unclear; "where does this code go?" is recurring; the framework leaks into business logic.
  - Solution: entities (domain objects), use-cases (application logic), interface adapters (controllers, DTOs, gateways), frameworks and drivers (UI, DB); dependencies only inward; outer layers implement inner interfaces.
  - When NOT: a small project; the team is already comfortable with hexagonal (same problem — pick one and be consistent).
  - Trade-offs: vs hexagonal (layers vs ports); vs layered (inward dependencies vs classic layers); vs flat (structure vs speed).
  - Related: `patterns/component/hexagonal.md`, `patterns/component/layered.md`, `patterns/code/dependency-injection.md`.
- `layered.md`
  - One-liner: Classic separation: presentation / service (application) / data.
  - Symptoms: everything lives in one layer ("god service"); the UI talks to the database directly; business logic sits in the controller; no place for tests.
  - Solution: presentation (UI/API), service/application (business logic), data (persistence); calls flow through the service layer; each layer has one responsibility.
  - When NOT: a small script/demo; two layers are enough.
  - Trade-offs: vs hexagonal/clean (simple vs strict boundaries); vs flat (structure vs speed); vs microservices (layers inside one service).
  - Related: `patterns/component/clean-architecture.md`, `patterns/code/repository.md`, `patterns/component/bff.md`.
- `modular-monolith.md`
  - One-liner: A single deployable with strict module boundaries.
  - Symptoms: a "big ball of mud"; modules touch each other's internals; one change breaks everything; deploy coupling; no clear ownership.
  - Solution: modules with a public API (the only external access); no cross-module database access (API or events); module = ownership; one deployable, one database (schema per module); events between modules.
  - When NOT: a small app (one module is enough); the team does not own the modules.
  - Trade-offs: vs microservices (boundaries without distribution); vs layered (modules vs layers); vs flat (boundaries vs freedom).
  - Related: `patterns/component/microservices.md`, `patterns/component/event-driven.md`, `patterns/system/strangler-fig.md`, `patterns/system/monolith-vs-microservices.md`.
- `event-driven.md`
  - One-liner: Modules communicate asynchronously via events.
  - Symptoms: synchronous call chains between modules; cascading failures; latency under load; a module must react to many things.
  - Solution: events ("something happened"); producers publish, consumers react; explicit delivery semantics; consumers are independent; the event is the contract.
  - When NOT: a simple request-response; 2-3 modules (direct calls are enough); a response is required.
  - Trade-offs: vs synchronous calls (decoupling vs clarity); vs saga (events vs a long process); vs pub-sub (system level vs module level).
  - Related: `patterns/code/pub-sub.md`, `patterns/system/saga.md`, `patterns/system/outbox.md`, `patterns/system/cqrs.md`, `patterns/component/modular-monolith.md`.
- `microservices.md`
  - One-liner: The system is split into independent services, each with its own data.
  - Symptoms: teams cannot ship independently; a deploy bottleneck; scale by part; the monolith is a deploy risk.
  - Solution: a service per bounded context; its own data (no shared database); API (sync) plus events (async); independent deploy; clear service ownership.
  - When NOT: one team (a modular monolith is enough); a small domain; the team has no experience.
  - Trade-offs: vs monolith (independence vs complexity); vs modular monolith (distribution vs boundaries); vs layered (services vs layers).
  - Related: `patterns/component/modular-monolith.md`, `patterns/system/monolith-vs-microservices.md`, `patterns/component/event-driven.md`, `patterns/system/saga.md`, `patterns/component/bff.md`.
- `plugin-architecture.md`
  - One-liner: The core is extended by plugins without recompiling or redeploying.
  - Symptoms: the core must be extended by third parties; different versions of behavior; the core grows with every extension.
  - Solution: a plugin API (contract); discovery and loading (filesystem, registry); isolation (process, sandbox, or module); versioning; the core stays stable.
  - When NOT: a closed set of extensions (DI is enough); extensions are simple (a config is enough).
  - Trade-offs: vs DI (dynamic vs static); vs microservices (plugins vs processes); vs strategy (external vs internal).
  - Related: `patterns/code/dependency-injection.md`, `patterns/component/hexagonal.md`, `patterns/component/microservices.md`.
- `bff.md`
  - One-liner: A backend per frontend: aggregation and formatting per client type.
  - Symptoms: web and mobile need different slices of the same data; over-fetching; the client assembles five calls where one is enough; different formats.
  - Solution: a BFF per client type (web-bff, mobile-bff); aggregation of calls to the domain; formatting per client; the BFF is thin (no business logic).
  - When NOT: a single client; a uniform API is enough; the client is simple.
  - Trade-offs: vs direct API (aggregation vs simplicity); vs microservices (BFF = a layer, services = the domain); vs facade (per client vs per subsystem).
  - Related: `patterns/code/dto.md`, `patterns/code/facade.md`, `patterns/component/microservices.md`.

- [ ] **Step 1: Написать 8 файлов по brief'ам**

- [ ] **Step 2: Прогнать валидатор**

Run: `bash scripts/validate.sh skills/architecture-patterns`
Expected: `validate: OK`

- [ ] **Step 3: Перевёрка качества** (тот же чек-лист, что в Task 3 Step 3)

- [ ] **Step 4: Commit**

```bash
git add skills/architecture-patterns/patterns/component
git commit -m "feat: component patterns (hexagonal..bff)"
```

---

### Task 6: patterns/system (10 файлов)

**Files:**
- Create: `skills/architecture-patterns/patterns/system/monolith-vs-microservices.md`
- Create: `skills/architecture-patterns/patterns/system/cqrs.md`
- Create: `skills/architecture-patterns/patterns/system/event-sourcing.md`
- Create: `skills/architecture-patterns/patterns/system/outbox.md`
- Create: `skills/architecture-patterns/patterns/system/saga.md`
- Create: `skills/architecture-patterns/patterns/system/circuit-breaker.md`
- Create: `skills/architecture-patterns/patterns/system/retry-with-backoff.md`
- Create: `skills/architecture-patterns/patterns/system/bulkhead.md`
- Create: `skills/architecture-patterns/patterns/system/idempotency.md`
- Create: `skills/architecture-patterns/patterns/system/strangler-fig.md`

**Interfaces:**
- Consumes: SKILL.md-индекс (Task 2); шаблон файла паттерна и правила раскрытия (Task 3); `scripts/validate.sh`.
- Produces: 10 файлов паттернов уровня system (каталог v1 завершён: 42 файла).

Шаблон каждого файла:

````markdown
# <Pattern Name>

## One-liner
One sentence: what it is and which problem it solves.

## Symptoms
3-7 bullets: observable signs in the code or task.

## Solution
Bullets: roles/components, rules, invariants. No code.

## When to use
Bullets: conditions for applying (including "instead of what").

## When NOT to use
Bullets: costs, when the plain solution is better.

## Trade-offs
Bullets or a small table: against 1-3 concrete alternatives.

## Related
Bullets: links (full path from the skill root: `patterns/<level>/<name>.md`, max 5), when to go to them.
````

Правила раскрытия brief'а: каждый пункт brief'а раскрывается в 1-3 предложения; итог файла 50-70 строк; английский; не добавлять фактов сверх brief'а; `Related` — полные пути от корня скилла.

Brief'ы:

- `monolith-vs-microservices.md`
  - One-liner: The decomposition decision: monolith, modular monolith, or microservices.
  - Symptoms: a decomposition choice at project start; a monolith that is hard to change; teams are blocked by each other; scale/deploys are uneven.
  - Solution: criteria — team count, domain complexity, scale, change frequency, deploy independence; default is the modular monolith; microservices only with team boundaries and scale; a decision guide, not a code pattern.
  - When NOT: a small project (plain monolith); the decision is already made and stable.
  - Trade-offs: monolith (simplicity vs coupling), modular monolith (boundaries vs one deployable), microservices (independence vs distributed complexity).
  - Related: `patterns/component/modular-monolith.md`, `patterns/component/microservices.md`, `patterns/system/strangler-fig.md`.
- `cqrs.md`
  - One-liner: Separate write (command) and read (query) models.
  - Symptoms: complex write invariants; divergent read projections; reads and writes scale differently; one model does not fit both.
  - Solution: a command side (aggregates, invariants), a query side (projections, read models); separate models; projections are updated by events/commands; reads stay fast.
  - When NOT: simple CRUD (one model is enough); reads equal writes; a small team.
  - Trade-offs: vs a single model (two models vs one); vs event sourcing (CQRS without ES = projections, with ES = history); vs database views (projections vs SQL views).
  - Related: `patterns/system/event-sourcing.md`, `patterns/code/aggregate.md`, `patterns/code/value-object.md`, `patterns/code/dto.md`.
- `event-sourcing.md`
  - One-liner: History is the source of truth: state is rebuilt from events.
  - Symptoms: an audit of changes is required; temporal queries; state must be rebuildable; complex invariants over time.
  - Solution: an immutable event stream; state = fold of events; snapshots for performance; events are the write model; the read model is a projection.
  - When NOT: you do not need history; the domain is simple; the team has no experience.
  - Trade-offs: vs a regular database (history vs current state); vs CQRS (ES is usually paired with CQRS); vs logging (ES is a model, a log is a byproduct).
  - Related: `patterns/system/cqrs.md`, `patterns/system/outbox.md`, `patterns/system/saga.md`, `patterns/component/event-driven.md`.
- `outbox.md`
  - One-liner: Reliable event publishing from the database: the event and the data land in the same transaction.
  - Symptoms: a "dual write" (database + message bus) loses events on crash; an event is published but the transaction is rolled back; duplicated or lost events.
  - Solution: an outbox table in the same database; the event is written in the same transaction as the data; a relay (CDC or polling) publishes from the outbox; consumers are idempotent.
  - When NOT: the message is optional (a log is enough); there is no transaction (in-memory).
  - Trade-offs: vs dual write (reliability); vs transactional messaging (database vs bus); vs direct publish (crash safety).
  - Related: `patterns/system/event-sourcing.md`, `patterns/system/saga.md`, `patterns/system/idempotency.md`, `patterns/component/event-driven.md`.
- `saga.md`
  - One-liner: A long business process across services: a sequence of local transactions plus events.
  - Symptoms: a "distributed transaction"; a process spans 3+ services; failure requires compensation; a multi-day process.
  - Solution: a saga = steps, each a local transaction plus an event; two styles: orchestration (a coordinator) and choreography (services react to events); compensation on failure (sagas are compensated, not rolled back).
  - When NOT: one service (a local transaction is enough); the process is short (a call is enough).
  - Trade-offs: vs 2PC (compensation vs atomicity — 2PC is impractical); vs synchronous calls (async vs sync); orchestration vs choreography (control vs decoupling).
  - Related: `patterns/system/outbox.md`, `patterns/system/event-sourcing.md`, `patterns/component/event-driven.md`, `patterns/system/idempotency.md`.
- `circuit-breaker.md`
  - One-liner: Protection from a failing dependency: fail fast instead of waiting.
  - Symptoms: a slow/failing dependency drags down the caller; timeouts accumulate; cascading failures; thread pool exhaustion.
  - Solution: CLOSED/OPEN/HALF-OPEN states; a failure threshold opens the breaker; in OPEN fail fast with a fallback; a half-open probe; reset on success.
  - When NOT: the dependency is local; failures are impossible (in-memory); there is no fallback (the breaker is pointless).
  - Trade-offs: vs retry (breaker = stop, retry = wait); vs timeout (breaker = cumulative, timeout = per call); vs bulkhead (breaker = dependency, bulkhead = resources).
  - Related: `patterns/system/retry-with-backoff.md`, `patterns/system/bulkhead.md`, `patterns/system/idempotency.md`.
- `retry-with-backoff.md`
  - One-liner: Retries of transient failures with exponential backoff.
  - Symptoms: transient failures (network, 503s, load) cause real errors; retries without backoff create a storm; non-idempotent operations get retried.
  - Solution: retry with exponential backoff plus jitter; a cap on attempts; only for idempotent operations; a deadline (give up); metrics on retry count.
  - When NOT: a non-idempotent operation without a key; a permanent failure (not transient); a synchronous local call.
  - Trade-offs: vs circuit breaker (retry = wait, breaker = stop); vs fail fast (resilience vs speed); vs a queue (inline retry vs deferred processing).
  - Related: `patterns/system/circuit-breaker.md`, `patterns/system/idempotency.md`, `patterns/system/bulkhead.md`.
- `bulkhead.md`
  - One-liner: Isolation of resources: one slow dependency does not exhaust the shared pool.
  - Symptoms: one slow dependency exhausts threads/connections; all requests wait; cascading exhaustion; a shared pool is the bottleneck.
  - Solution: pools (threads, connections, memory, queues) per dependency; limits; a slow dependency affects only its pool; a fallback per pool.
  - When NOT: a single dependency; resources are not shared (a call is enough).
  - Trade-offs: vs a shared pool (isolation vs efficiency); vs circuit breaker (bulkhead = resources, breaker = dependency); vs microservices (process isolation is the ultimate bulkhead).
  - Related: `patterns/system/circuit-breaker.md`, `patterns/system/retry-with-backoff.md`, `patterns/component/microservices.md`.
- `idempotency.md`
  - One-liner: Duplicates (retries, at-least-once delivery) have the same effect as a single call.
  - Symptoms: retries produce duplicates; at-least-once delivery; processes get re-executed; double charges.
  - Solution: an idempotency key (a unique request id); deduplication by key; the effect is applied once; the key is stored with the result; keys have a TTL.
  - When NOT: at-most-once delivery is acceptable; read-only operations.
  - Trade-offs: vs exactly-once (idempotency = the effect, exactly-once = delivery — usually impossible); vs accidental dedup (idempotency = by design); vs a unique index (storage-level idempotency).
  - Related: `patterns/system/retry-with-backoff.md`, `patterns/system/outbox.md`, `patterns/system/saga.md`, `patterns/system/circuit-breaker.md`.
- `strangler-fig.md`
  - One-liner: Incremental migration off a legacy: a facade grows and replaces the legacy piece by piece.
  - Symptoms: a legacy system; a big-bang rewrite is too risky; the legacy must keep working during migration; a parallel run is required.
  - Solution: a facade in front of the legacy; a new implementation of one function at a time; a parallel run (old and new in parallel, comparing results); a cutover; deletion of the legacy piece.
  - When NOT: a small legacy (a rewrite is enough); there is no facade (the legacy is called directly).
  - Trade-offs: vs a big-bang rewrite (risk); vs a full parallel run (strangler = incremental, parallel = full); vs a rewrite (strangler = evolution).
  - Related: `patterns/code/feature-flag.md`, `patterns/component/modular-monolith.md`, `patterns/component/microservices.md`, `patterns/system/monolith-vs-microservices.md`.

- [ ] **Step 1: Написать 10 файлов по brief'ам**

- [ ] **Step 2: Прогнать валидатор**

Run: `bash scripts/validate.sh skills/architecture-patterns`
Expected: `validate: OK`

- [ ] **Step 3: Перевёрка качества** (тот же чек-лист, что в Task 3 Step 3) + сверка: всего файлов в `patterns/` = 24 + 8 + 10 = 42 (Run: `find skills/architecture-patterns/patterns -name '*.md' | wc -l`, Expected: `42`)

- [ ] **Step 4: Commit**

```bash
git add skills/architecture-patterns/patterns/system
git commit -m "feat: system patterns (monolith-vs-microservices..strangler-fig)"
```

---

### Task 7: install.sh + README.md + AGENTS.md + evals/scenarios.md + .gitignore

**Files:**
- Create: `install.sh`
- Create: `README.md`
- Create: `AGENTS.md`
- Create: `evals/scenarios.md`
- Create: `.gitignore`

**Interfaces:**
- Consumes: `skills/architecture-patterns/` (Tasks 2-6) — install.sh ссыlinkует на `$SCRIPT_DIR/skills/architecture-patterns`.
- Produces: установка для трёх агентов; eval-сценарии, которые прогоняет Task 9.

- [ ] **Step 1: Написать `install.sh`** (final-контент)

```bash
#!/usr/bin/env bash
# Install the architecture-patterns skill into agent skill directories.
#
# Usage:
#   ./install.sh                     # into this repo root (development)
#   ./install.sh --into <dir>        # into an existing project directory
#   ./install.sh --global            # into $HOME (available in all repos)
#   ./install.sh --remove            # remove installed links (same mode flags)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/skills/architecture-patterns"
NAME="architecture-patterns"

MODE="repo"; REMOVE=0; INTO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --global) MODE="global" ;;
    --into)
      INTO="${2:-}"; shift
      [ -n "$INTO" ] || { echo "--into needs a directory" >&2; exit 1; }
      ;;
    --remove) REMOVE=1 ;;
    *) echo "unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done

[ -d "$SKILL_SRC" ] || { echo "skill source not found: $SKILL_SRC" >&2; exit 1; }

case "$MODE" in
  global) BASE="$HOME" ;;
  *) BASE="." ;;
esac
[ -n "$INTO" ] && BASE="$INTO"

TARGETS=(".agents/skills" ".claude/skills" ".opencode/skills")

for dir in "${TARGETS[@]}"; do
  target="$BASE/$dir/$NAME"
  if [ "$REMOVE" = "1" ]; then
    if [ -L "$target" ]; then rm "$target"; echo "removed $target"; fi
  else
    mkdir -p "$BASE/$dir"
    if [ "$MODE" = "global" ] || [ -n "$INTO" ]; then
      ln -sfn "$SKILL_SRC" "$target"
    else
      ln -sfn "../../skills/architecture-patterns" "$target"
    fi
    echo "installed $target"
  fi
done
```

- [ ] **Step 2: Протестировать install.sh**

Run (из корня репо):

```bash
chmod +x install.sh scripts/validate.sh scripts/test-validate.sh
bash -n install.sh && \
./install.sh && \
test -f .agents/skills/architecture-patterns/SKILL.md && \
test -f .claude/skills/architecture-patterns/SKILL.md && \
test -f .opencode/skills/architecture-patterns/SKILL.md && \
./install.sh --remove && \
test ! -L .agents/skills/architecture-patterns && \
TMP="$(mktemp -d)" && mkdir -p "$TMP/proj" && \
HOME="$TMP" ./install.sh --global && \
test -f "$TMP/.agents/skills/architecture-patterns/SKILL.md" && \
./install.sh --into "$TMP/proj" && \
test -f "$TMP/proj/.agents/skills/architecture-patterns/SKILL.md" && \
rm -rf "$TMP" && echo INSTALL-TEST-OK
```

Expected: `INSTALL-TEST-OK`

- [ ] **Step 3: Написать `README.md`** (final-контент)

```markdown
# architecture-patterns

An architecture meta-skill for coding agents: OpenCode, Claude Code, Codex (any agent supporting the [open Agent Skills standard](https://agentskills.io)).

Before writing code, the agent reflects: which architecture/design patterns fit the task and the project as a whole — and when NOT to use any. One skill, progressive disclosure: only the name and description enter the context until the agent decides the skill is needed.

## What it gives you

- Reflection protocol: task, project size, team, change frequency, existing style — before any pattern.
- Decision tree: symptom to pattern file (42 patterns across code / component / system levels).
- Selection rules: default = no pattern; max 1-3 per task; the project's existing style wins over a "better" pattern.
- Output format: a short "architecture reflection" block before the code (chosen / rejected / consistency).

## Install

Global (all your repos, all three agents):

    git clone <this-repo-url> ~/.arch-patterns
    ~/.arch-patterns/install.sh --global

Per project:

    cd /path/to/your-project
    ~/.arch-patterns/install.sh --into .

Development (agents working in this repo see the skill):

    ./install.sh

Remove:

    ./install.sh --remove             # add --into <dir> or --global for the same scope

The skill is linked into `.agents/skills/` (Codex, OpenCode), `.claude/skills/` (Claude Code, OpenCode) and `.opencode/skills/` (OpenCode). Restart the agent if the skill does not appear.

## Usage

- Implicit: the agent triggers the skill on architecture/design tasks ("design a payment service", "refactor this module", "add caching").
- Explicit: mention the skill in the prompt ("use the architecture-patterns skill"), or `$architecture-patterns` in Codex.
- The agent answers with a short reflection block, then writes code following the chosen pattern(s).

## Development

- Format rules: `bash scripts/validate.sh skills/architecture-patterns [--check-links]`, tests: `bash scripts/test-validate.sh`.
- Adding a pattern: create `patterns/<level>/<kebab-name>.md` (template in AGENTS.md), add a line to the SKILL.md index, a symptom line to the SKILL.md decision tree and a section to `references/decision-tree.md`.
- Constraints: SKILL.md < 500 lines; pattern files 40-80 lines, no fenced code; content in English.

## License

MIT
```

- [ ] **Step 4: Написать `AGENTS.md`** (final-контент)

```markdown
# AGENTS.md

Rules for agents working in this repository.

- Skill content (everything under skills/) is English, no code examples, no fenced code blocks in patterns/ and references/.
- SKILL.md: body < 500 lines. Pattern files: 40-80 lines, sections in this order: One-liner, Symptoms, Solution, When to use, When NOT to use, Trade-offs, Related.
- Pattern file names: kebab-case, must match the name in the SKILL.md index. Related links: full paths from the skill root (patterns/<level>/<name>.md).
- Before committing any change under skills/: run `bash scripts/validate.sh skills/architecture-patterns --check-links` and `bash scripts/test-validate.sh`.
- Adding a pattern: 1) patterns/<level>/<name>.md, 2) SKILL.md index line, 3) symptom line in the SKILL.md decision tree, 4) section in references/decision-tree.md. If SKILL.md grows beyond the limit, move detail into references/.
- Do not rename the skill (architecture-patterns) — the directory name is part of the contract.
```

- [ ] **Step 5: Написать `evals/scenarios.md`** (final-контент)

```markdown
# Eval scenarios

Manual evaluation. Run each prompt in a scratch project with the skill installed (see How to run). A scenario passes if the observed behavior matches the expectation.

## How to run

    rm -rf /tmp/arch-eval && mkdir -p /tmp/arch-eval && cd /tmp/arch-eval
    git init -q
    echo "# Demo project" > README.md
    mkdir -p .agents/skills
    ln -s /abs/path/to/arch/skills/architecture-patterns .agents/skills/architecture-patterns

Then from /tmp/arch-eval: opencode run "<prompt>" (or Claude Code / Codex). Fill the table.

Scenarios 8 and 10 need a prepared codebase:

- Scenario 8: add src/model/order.js and src/data/order-repository.js (repository style: business code depends on OrderRepository, no SQL in the model).
- Scenario 10: add src/modules/identity/ and src/modules/billing/ (each module: public api.js + internal files; no cross-module imports except api.js).

## Scenarios

| # | Prompt | Expected | Observed | Pass |
|---|--------|----------|----------|------|
| 1 | "Let's build a payment service from scratch" | reflection protocol runs; default modular monolith; microservices only with justification | | |
| 2 | "Add caching for an expensive call" | cache-aside chosen (strategy if the cache is pluggable); exactly 1 pattern | | |
| 3 | "Fix the typo in the README" | no skill trigger, no reflection block, no patterns | | |
| 4 | "Refactor this 1500-line class" (attach a big class file) | split by responsibility first; patterns only if symptoms match | | |
| 5 | "We have 3 teams and the service is growing — how should we decompose?" | modular-monolith vs microservices decision by criteria | | |
| 6 | "Implement notifications for the app" | observer/pub-sub; not a god object; not 5 patterns | | |
| 7 | "Make everything event-driven" | the agent asks about symptoms, does not blindly comply | | |
| 8 | "add a new feature that needs persistence" (repository-style codebase) | continues the existing style (consistency) | | |
| 9 | "Apply CQRS to the whole project" | rejected if symptoms do not match | | |
| 10 | "add a small internal module" (modular monolith codebase) | respects the existing structure; no new architecture | | |

## Results

- Date / agent / model:
- Passed: /10
```

- [ ] **Step 6: Написать `.gitignore`**

```
.agents/
.claude/
.opencode/
```

- [ ] **Step 7: Полный валидатор со ссылками**

Run: `bash scripts/validate.sh skills/architecture-patterns --check-links`
Expected: `validate: OK` (все 42 ссылки индекса разрешаются, индекс полон)

- [ ] **Step 8: Commit**

```bash
git add install.sh README.md AGENTS.md evals/scenarios.md .gitignore
git commit -m "feat: install script, README, AGENTS.md, eval scenarios"
```

---

### Task 8: Полная верификация (gate)

**Files:**
- Modify (только если есть нарушения): любые файлы из Tasks 1-7.

**Interfaces:**
- Consumes: `scripts/validate.sh`, `scripts/test-validate.sh`, весь скилл.
- Produces: подтверждённое состояние «v1 готово к eval».

- [ ] **Step 1: Тесты валидатора**

Run: `bash scripts/test-validate.sh`
Expected: `test-validate: PASS=5 FAIL=0`

- [ ] **Step 2: Полный валидатор**

Run: `bash scripts/validate.sh skills/architecture-patterns --check-links`
Expected: `validate: OK`

- [ ] **Step 3: Аудит размеров и полноты**

Run:

```bash
wc -l skills/architecture-patterns/SKILL.md
find skills/architecture-patterns/patterns -name '*.md' | wc -l
grep -c '^### ' skills/architecture-patterns/references/decision-tree.md
for f in skills/architecture-patterns/patterns/*/*.md; do test -f "$f"; done && echo ALL-EXIST
```

Expected: SKILL.md < 500; файлов = 42; `### ` секций в decision-tree = 42 (+0, без лишних); ALL-EXIST.

- [ ] **Step 4: Сверка индекса с каталогом**

Run:

```bash
for f in $(find skills/architecture-patterns/patterns -name '*.md' | sed 's|skills/architecture-patterns/||'); do
  grep -qF "$f" skills/architecture-patterns/SKILL.md || echo "MISSING IN INDEX: $f"
  grep -qF "$(basename "$f")" skills/architecture-patterns/references/decision-tree.md || echo "MISSING IN DECISION TREE: $f"
done
echo INDEX-CHECK-DONE
```

Expected: только `INDEX-CHECK-DONE`, без MISSING.

- [ ] **Step 5: Исправления (если есть)**

Для каждого нарушения: исправить файл, повторить Step 1-4, затем:

```bash
git add -A skills/ scripts/
git commit -m "fix: validation findings"
```

Если нарушений нет — коммит не создаётся.

---

### Task 9: Ручные eval-прогоны (opencode)

**Files:**
- Modify: `evals/scenarios.md` (заполнить таблицу и Results)
- Modify (только если сценарий падает): `skills/architecture-patterns/SKILL.md` (wording)

**Interfaces:**
- Consumes: весь скилл, `evals/scenarios.md` (Task 7).
- Produces: заполненные результаты; при провалах — улучшенный wording SKILL.md.

- [ ] **Step 1: Подготовить scratch-проект**

```bash
rm -rf /tmp/arch-eval && mkdir -p /tmp/arch-eval && cd /tmp/arch-eval
git init -q
echo "# Demo project" > README.md
mkdir -p .agents/skills
ln -s /ABS/REPO/skills/architecture-patterns .agents/skills/architecture-patterns
test -f .agents/skills/architecture-patterns/SKILL.md && echo EVAL-READY
```

`/ABS/REPO` — заменить на абсолютный путь к корню этого репозитория (получить: `git rev-parse --show-toplevel` из корня репо).

- [ ] **Step 2: Прогнать сценарии 1-7**

Для каждого сценария (таблица в `evals/scenarios.md`) из `/tmp/arch-eval`:

Run: `opencode run "<prompt>"`
Expected: поведение из колонки Expected; записать в колонку Observed 1-2 строкой.

- [ ] **Step 3: Подготовить кодбейс для сценариев 8 и 10, прогнать их**

```bash
mkdir -p /tmp/arch-eval/src/model /tmp/arch-eval/src/data /tmp/arch-eval/src/modules/identity /tmp/arch-eval/src/modules/billing
printf '// Order domain model (no persistence)\n' > /tmp/arch-eval/src/model/order.js
printf('// OrderRepository: save, findById (repository style)\n' > /tmp/arch-eval/src/data/order-repository.js
printf('// identity public api\n' > /tmp/arch-eval/src/modules/identity/api.js
printf '// identity internals\n' > /tmp/arch-eval/src/modules/identity/internal.js
printf '// billing public api\n' > /tmp/arch-eval/src/modules/billing/api.js
printf '// billing internals\n' > /tmp/arch-eval/src/modules/billing/internal.js
```

Run: `opencode run "<prompt сценария 8>"`, затем `opencode run "<prompt сценария 10>"`
Expected: как в таблице; заполнить Observed.

- [ ] **Step 4: Обработка провалов**

Для каждого упавшего сценария:
1. Определить причину: не сработал триггер (description), не понятен routing (decision tree), правило не прозвучало (Selection rules/Output format).
2. Изменить wording в `SKILL.md` (минимально, не ломая лимиты).
3. Run: `bash scripts/validate.sh skills/architecture-patterns --check-links` → `validate: OK`.
4. Повторить только упавший сценарий.

- [ ] **Step 5: Заполнить Results и commit**

Заполнить в `evals/scenarios.md`: Date/agent/model, Passed N/10, все Observed.

```bash
git add evals/scenarios.md skills/
git commit -m "docs: eval results (N/10)"
```

---

План завершён. Следующий шаг после утверждения плана — выбор способа исполнения: subagent-driven-development (рекомендуется) или executing-plans (inline).

---
