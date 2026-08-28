# Architecture Patterns Skill — дизайн (spec)

- Дата: 2026-08-28
- Статус: утверждена пользователем (brainstorming → spec)
- Продукт: публичный GitHub-репозиторий со скиллом `architecture-patterns` в формате открытого стандарта Agent Skills (agentskills.io), работающим в OpenCode, Claude Code и Codex.

## 1. Цель

Агент кодинг-агента (опенкод в первую очередь, Claude Code и Codex — тоже) **до написания кода рефлексировать**: какие архитектурные/дизайн-паттерны подходят текущей задаче и проекту целиком — и **не тащить в проект миллиард паттернов** (no over-engineering, no смешивание несочетаемых стилей).

Формат: один мета-скилл — протокол рефлексии + decision tree + справочник паттернов (по одному reference-файлу на паттерн), загружаемых по требованию (progressive disclosure).

### Non-goals (YAGNI)

- Не TS-плагин для opencode (скилл покрывает; плагинизация — возможное v2).
- Никаких кодовых примеров в паттернах — только текстовые описания, инварианты, trade-offs (решение пользователя).
- Никакого автоматического eval-харнеса в v1 — только ручные сценарии.
- Нет RAG/векторизации — прогрессивное раскрытие достаточно.
- Нет локализации контента скилла (английский, см. §9).

## 2. Research-основания (evidence ledger)

| Вопрос | Инструменты | Первичный источник | Вывод | Ограничение для реализации |
|---|---|---|---|---|
| Формат скиллов opencode | webfetch | opencode.ai/docs/skills/ (обновлено 2026-08-28) | SKILL.md + YAML frontmatter (`name`, `description`, опц. `license`, `compatibility`, `metadata`). Читает `.opencode/skills/`, `.claude/skills/`, `.agents/skills/` (проект) и `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/` (глобально). Загрузка on-demand через `skill` tool | `name`: 1–64 симв., `^[a-z0-9]+(-[a-z0-9]+)*$`, обязан совпадать с именем каталога; `description`: 1–1024 симв. |
| Формат/бест-практики Claude | webfetch | platform.claude.com/docs/…/agent-skills/best-practices | Тот же формат. Прогрессивное раскрытие: метаданные → SKILL.md → bundled files. SKILL.md < 500 строк. Референсы на 1 уровень вглубь (без цепочек). TOC для файлов > 100 строк. Description — 3-е лицо, «что + когда» | Структура нашего скилла: SKILL.md = overview/index, файлы паттернов = ссылки 1-го уровня |
| Поддержка Codex | webfetch | developers.openai.com/codex/skills (Build skills) | Codex поддерживает тот же открытый стандарт. Читает `.agents/skills/` (все dirs от CWD до корня репо + `$HOME/.agents/skills`). Начальный список скиллов ограничен **2% контекстного окна** (8000 симв. иначе); при превышении — укорачивает description, затем отбрасывает скиллы | Один скилл = одна запись в списке — экономит бюджет 2%. Description: ключевые триггеры в начале |
| Общий стандарт | webfetch | agentskills.io | Agent Skills — открытый стандарт (Anthropic, 2025), принят 40+ клиентами: OpenCode, Claude Code, ChatGPT/Codex, Cursor, Gemini CLI, Goose, Roo Code, Copilot, VS Code и др. | Один формат файлов покрывает opencode + claude + codex без адаптеров |
| Что хорошо ложится LLM-агентам | gemini deep research + webfetch (anthropic.com/engineering, official docs) | Синтез + первичные доки | Анти-паттерн: дамп всех знаний в контекст. Работает: progressive disclosure, meta-скилл/decision tree, доменно-организованные reference-файлы, чек-листы, feedback-лупы, eval-driven development, «concise is key» (не объяснять то, что LLM и так знает) | Дизайн: мета-скилл + 1 файл на паттерн; каждый файл 40–80 строк; никаких лекций «что такое паттерн» |

## 3. Архитектура продукта

Один скилл `architecture-patterns` (каталог = имя скилла). Single source of truth в репо: `skills/architecture-patterns/`.

```
<repo>/
├── skills/architecture-patterns/     # single source of truth
│   ├── SKILL.md                      # мета: протокол + decision tree + индекс + правила
│   ├── patterns/
│   │   ├── code/                    # кодовый уровень (1 файл = 1 паттерн)
│   │   ├── component/               # уровень «структура приложения/модулей»
│   │   └── system/                  # системный уровень + deployment/надёжность
│   └── references/
│       ├── anti-patterns.md          # when NOT to use, смешивания, over-engineering
│       └── decision-tree.md          # полная таблица «симптом → файл» (если не влезает в SKILL.md)
├── install.sh                        # symlink скилла в .agents/skills, .claude/skills, .opencode/skills
├── evals/scenarios.md                # ручные eval-сценарии (prompt → ожидаемое поведение)
├── AGENTS.md                         # инструкции maintainers (англ.)
├── README.md                         # публичный README (англ.): install, usage, принципы
└── docs/superpowers/specs/…         # этот файл
```

Правила ссылок: каждый файл ссылается на файлы паттернов **ровно в один скачок** (из SKILL.md напрямую; file-to-file ссылки в секции Related допустимы — оба файла на уровне 1 от SKILL.md). Файлы > 100 строк начинают с TOC.

## 4. SKILL.md — спецификация

Frontmatter:

- `name: architecture-patterns`
- `description` (≤1024 симв., 3-е лицо, триггеры вперёд): что делает (reflection protocol + decision tree + pattern catalogue на уровнях code/component/system) + когда использовать (before designing architecture, creating new modules/services/classes, choosing among design patterns, refactoring tangled code, user asks about architecture) + когда НЕ (trivial edits, small bug fixes).

Секции тела (порядок обязателен):

1. **When to use / When NOT to use.** Не для: fixes ≤ ~50 строк, опечатки, мелкие баги без изменения структуры, задачи «сделай то-то точно». Если задача тривиальная — не применять паттерны вообще.
2. **Reflection protocol** (чек-лист, агент копирует и заполняет):
   - Задача: new / modify / refactor? Размер изменения (файл/модуль/сервис)?
   - Проект: размер, размер команды, частота изменений, сложность домена, existing style (какие паттерны/структуры уже в коде — обязательно посмотреть), constraints (stack, infra, skills команды, cost).
   - Вопрос по умолчанию: «достаточно ли простого решения без паттерна?» — по умолчанию НЕТ паттерна.
3. **Decision tree.** Таблица «симптом/задача → файлы-кандидаты»:
   - код: «множество ветвлений по типу» → `patterns/code/strategy.md`; «дорогой вызов, нужен кэш» → `patterns/code/cache-aside.md`; и т.д.
   - структура: «монolith разрастается, несколько команд» → `patterns/system/modular-monolith.md`, `patterns/system/microservices.md`; …
   - система: «асинхронные команды между сервисами» → `patterns/system/outbox.md`, `patterns/system/saga.md`; …
4. **Index.** Список всех файлов паттернов: `file — one-liner (≤10 слов)`. Полный, синхронизирован с каталогом.
5. **Selection rules (жёстко):**
   - Default: ни одного паттерна. Паттерн — только при совпадении симптомов из его «When to use».
   - Максимум 1–3 паттерна на задачу. Если хочется больше — сначала остановиться и перепроверить симптомы.
   - Consistency: существующий стиль проекта приоритетен над «более правильным» паттерном. Новый паттерн в проект — только с явным обоснованием.
   - Каждый выбранный паттерн обязан иметь ссылку на свой файл; агент читает файл целиком перед применением (не по памяти).
   - Anti-mixing: не применять паттерны из разных уровней/семейств, если они конфликтуют (таблица конфликтов — в `references/anti-patterns.md`).
6. **Output format.** Перед кодом агент выводит короткий блок (5–10 строк):
   - Task level: code / component / system
   - Chosen: `pattern (file)` — why (1 строка)
   - Rejected: `pattern` — why not (1 строка, если были кандидаты)
   - Consistency note: соответствие стилю проекта (или «new project — adopted: …»)

Ограничения: SKILL.md < 500 строк; язык — английский; без кодовых примеров.

## 5. Шаблон файла паттерна

Путь: `patterns/<level>/<kebab-name>.md`. Размер: 40–80 строк. Без кода. Обязательные секции (порядок фиксированный):

```markdown
# <Pattern Name>

## One-liner
Одно предложение: что это и против какой проблемы.

## Symptoms
Буллеты: наблюдаемые признаки в коде/задаче, при которых паттерн актуален (3–7).

## Solution
Инварианты и структура: роли/компоненты, правила, ограничения. Без кода.

## When to use
Условия, когда применять (включая «вместо чего»).

## When NOT to use
Стоимость, когда хуже простого решения (обязательная секция — защита от over-engineering).

## Trade-offs
Таблица/буллеты против 1–3 конкретных альтернатив (включая «просто/naive»).

## Related
Ссылки на файлы-соседей: когда переходить к ним (≤5 ссылок).
```

Качество: «concise is key» — не объяснять очевидное LLM (что такое класс, что такое async); только то, чего модель не знает по умолчанию или что является нашим мнением (trade-offs, пороги).

## 6. Каталог

### v1 (ядро, ~40 файлов)

**code/** (24): `strategy`, `observer`, `factory-method`, `builder`, `dependency-injection`, `repository`, `unit-of-work`, `data-mapper`, `dto`, `specification`, `value-object`, `aggregate`, `facade`, `adapter`, `decorator`, `state`, `template-method`, `command`, `chain-of-responsibility`, `mediator`, `memoization`, `cache-aside`, `pub-sub`, `feature-flag`

**component/** (8): `hexagonal`, `clean-architecture`, `layered`, `modular-monolith`, `event-driven`, `microservices`, `plugin-architecture`, `bff`

**system/** (10): `monolith-vs-microservices`, `cqrs`, `event-sourcing`, `outbox`, `saga`, `circuit-breaker`, `retry-with-backoff`, `bulkhead`, `idempotency`, `strangler-fig`

Итого 42 файла. (Если при реализации окажется, что отдельные паттерны дублируются — решение фиксируется в diff-ревью, структура не ломается.)

### v2 (расширение, кандидат-лист)

GoF: `abstract-factory`, `prototype`, `singleton` (с усиленной секцией «when NOT»), `memento`, `visitor`, `flyweight`, `bridge`, `composite`.
Современное: `actor-model`, `crdt`, `offline-first`, `api-gateway`, `service-mesh`, `data-versioning`, `canary-deployment`, `micro-frontend`, `saga-choreography` (если вынесено из `saga`), `bounded-context` — точный список утверждается при старте v2 по метрике «реально меняет решения».

## 7. Кросс-агентная установка

- `install.sh` (bash, идемпотентный):
  - repo-режим: `mkdir -p .agents/skills .claude/skills .opencode/skills` + relative symlinks `skills/architecture-patterns` в каждый (в `.opencode/skills` — опционально, `.agents` уже читается opencode).
  - `--global`: те же каталоги в `$HOME` (`~/.agents/skills`, `~/.claude/skills`, `~/.config/opencode/skills`).
  - `--remove`: убирает ссылки.
- README: один инсталл-командный блок на агента + строка «verify» (как проверить, что скилл виден агенту).
- Опциональный include в AGENTS.md/CLAUDE.md пользовательских проектов (готовый сниппет в README):
  «Before creating a new module/service/class structure, invoke the `architecture-patterns` skill and follow its reflection protocol.»

## 8. Валидация

- `evals/scenarios.md`: 10 ручных сценариев «prompt → ожидаемое поведение»:
  1. «Сделай сервис платежей с нуля» → протокол рефлексии; дефолт modular monolith; microservices только с обоснованием.
  2. «Добавь кэш для дорогого вызова» → `cache-aside` (+ strategy если кэш расширяемый); ровно 1 паттерн.
  3. «Пофиксить опечатку в README» → скилл не грузится / без рефлексии.
  4. «Рефактор 1500-строчного класса» → сначала разбивка по ответственности; паттерны только по симптомам.
  5. «У нас 3 команды, сервис растёт» → решение по `modular-monolith` vs `microservices` по критериям.
  6. «Реализуй уведомления» → `observer`/`pub-sub`; не god object, не 5 паттернов.
  7. Пользователь: «сделай event-driven всё» → агент контрвопрос по симптомам, не подчиняется слепо.
  8. В проекте уже везде repository pattern → новый код продолжает стиль (consistency).
  9. «Сделай CQRS во всём проекте» → reject, если симптомы не совпадают.
  10. Новый маленький модуль в существующем modular monolith → уважает существующую структуру.
- Прогон: минимум opencode; при наличии — Claude Code, Codex CLI. Результаты — чек-лист в `evals/scenarios.md`.
- Критерии формата: SKILL.md < 500 строк; каждый паттерн 40–80 строк; ссылки 1 уровень; description ≤ 1024 симв.; name = имя каталога.

## 9. Языки и стиль

- Контент скилла (SKILL.md, patterns, references): **английский** (конвенция экосистемы Agent Skills; публичный репо).
- README, AGENTS.md: английский.
- Документация maintainers/спеки: русский допустим.

## 10. Репо и лицензия

- Публичный GitHub-репозиторий. Имя: `architecture-patterns-skill` (working name, уточнить при создании).
- Лицензия: MIT (frontmatter `license: MIT` в SKILL.md).
- Первый коммит: spec. Дальше — по implementation plan (writing-plans).

## 11. Критерии успеха (acceptance)

1. В opencode (и при наличии в claude/codex) сценарии 1–10 из §8 дают ожидаемое поведение: рефлексия перед кодом, ≤ 3 паттернов, соответствие стилю проекта, нет паттернов на тривиальных задачах.
2. Все формальные ограничения §2 соблюдены (name/description/500 строк/1 уровень).
3. Новый пользователь ставит скилл одной командой (README) в каждого из трёх агентов.

## 12. Открытые вопросы (не блокеры)

- Точное имя репо и GitHub-аккаунт/орг.
- Включать ли в v1 `bounded-context` (DDD) — склоняюсь: да, в component/, если не перегружает.
