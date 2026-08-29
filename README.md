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

Per-project installs are linked into `.agents/skills/` (Codex, OpenCode), `.claude/skills/` (Claude Code, OpenCode) and `.opencode/skills/` (OpenCode). Global installs go to `~/.agents/skills/` (Codex), `~/.claude/skills/` (Claude Code) and `~/.config/opencode/skills/` (OpenCode). Restart the agent if the skill does not appear.

## Usage

- Implicit: the agent triggers the skill on architecture/design tasks ("design a payment service", "refactor this module", "add caching").
- Explicit: mention the skill in the prompt ("use the architecture-patterns skill"), or `$architecture-patterns` in Codex.
- The agent answers with a short reflection block, then writes code following the chosen pattern(s).

## Development

- Integrity checks: `bash scripts/validate.sh skills/architecture-patterns [--links]`.
- Adding a pattern: create `patterns/<level>/<kebab-name>.md` (template in AGENTS.md), add a line to the SKILL.md index, a symptom line to the SKILL.md decision tree and a section to `references/decision-tree.md`.
- Constraints: SKILL.md < 500 lines; pattern files 40-80 lines, no fenced code; content in English.

## License

MIT
