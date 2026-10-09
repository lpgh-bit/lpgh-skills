# Project language

Every repo has one **project language**, chosen in `/init` and recorded in `docs/agents/project.md` (`## Language`) and in the `## Agent skills` block of AGENTS.md/CLAUDE.md. **Default: English** — when nothing is recorded, use English.

## Written in the project language

- Conversation with the user: questions, gates, progress notes, reports, summaries.
- Specs, tickets, `milestones.md`, `ideas.md`, wayfinder maps, triage notes and agent briefs.
- Review and milestone-review reports, failure reports, ticket comments.
- `DESIGN.md`, `CONTEXT.md`, ADRs, research notes, handoff documents.
- Commit messages (the `+`/`-`/`~` prefixes stay the same).

## Not affected

- **Code** — identifiers and code comments follow the repo's existing convention (usually English).
- **UI copy** — follows the product's language as decided in the spec / `DESIGN.md`, which may differ from the project language.
- **Fixed tokens** — ticket field names and values (`Status: ready`, `Type: fix`, `Risk: high`), file names, skill names, labels and template headings stay English so tools and skills can parse them. Only free text is translated.
- The skill files themselves (always English).
