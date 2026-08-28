# AGENTS.md

Rules for agents working in this repository.

- Skill content (everything under skills/) is English, no code examples, no fenced code blocks in patterns/ and references/.
- SKILL.md: body < 500 lines. Pattern files: 40-80 lines, sections in this order: One-liner, Symptoms, Solution, When to use, When NOT to use, Trade-offs, Related.
- Pattern file names: kebab-case, must match the name in the SKILL.md index. Related links: full paths from the skill root (patterns/<level>/<name>.md).
- Before committing any change under skills/: run `bash scripts/validate.sh skills/architecture-patterns --links`.
- Adding a pattern: 1) patterns/<level>/<name>.md, 2) SKILL.md index line, 3) symptom line in the SKILL.md decision tree, 4) section in references/decision-tree.md. If SKILL.md grows beyond the limit, move detail into references/.
- Do not rename the skill (architecture-patterns) — the directory name is part of the contract.
