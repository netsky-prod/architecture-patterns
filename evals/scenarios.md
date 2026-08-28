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
