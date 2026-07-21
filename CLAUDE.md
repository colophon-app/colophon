# CLAUDE.md

See [AGENTS.md](AGENTS.md) for the shared build/test/style/commit rules and red lines — they apply to Claude too.

Claude-specific notes:

- The full project context is in `planning/` (PRD, ROADMAP, standards, `M0/plan.md`) and `docs/` (research). Read the relevant milestone's `plan.md` before coding, and record decisions in that milestone's `decisions.md`.
- Detailed, enforceable rules are in `.claude/rules/`.
- When unsure about a design or technical call, research it (the `docs/` survey + external sources) and decide — don't bounce it back as a question. Ground distinctive choices in the survey, not imagination.
