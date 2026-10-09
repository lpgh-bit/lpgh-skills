# Notice — sources and licenses

lpgh-skills is a one-time fork (snapshot of October 2026) that merges three skill collections (plus two skills from anthropics/skills). Skills were renamed, merged and adapted (shared ticket protocol, risk levels, milestones, `/work`, `/init`).

| Source | Version | License | Used for |
|---|---|---|---|
| [mattpocock/skills](https://github.com/mattpocock/skills) | 1.2.0 | MIT — `licenses/mattpocock-skills.LICENSE` | engineering + productivity skills, ticket system, grilling, wayfinder, triage, codebase-design, prototype, research, handoff, wizard, setup-* |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 0.6.12 | MIT — `licenses/addyosmani-agent-skills.LICENSE` | 25 lifecycle skills, `agents/`, `hooks/`, `references/` checklists, operating behaviours |
| [anthropics/skills — frontend-design](https://github.com/anthropics/skills/tree/main/skills/frontend-design) | main @ 2026-10 | Apache-2.0 — `skills/frontend-design/LICENSE.txt` | `frontend-design` (modified, see below) |
| [anthropics/skills — webapp-testing](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) | main @ 2026-10 (9d63080) | Apache-2.0 — `skills/webapp-testing/LICENSE.txt` | `webapp-testing` (modified, see below) |

## Merged skills

| lpgh-skills | from |
|---|---|
| `grill` | mattpocock grilling, grill-me, grill-with-docs · addy interview-me, idea-refine |
| `to-spec` | mattpocock to-spec · addy spec-driven-development |
| `to-tickets` | mattpocock to-tickets · addy planning-and-task-breakdown |
| `implement` | mattpocock implement · addy incremental-implementation |
| `review` | mattpocock code-review · addy code-review-and-quality |
| `tdd` | mattpocock tdd · addy test-driven-development |
| `debugging` | mattpocock diagnosing-bugs · addy debugging-and-error-recovery |
| `domain-docs` | mattpocock domain-modeling · addy documentation-and-adrs |
| `init` | mattpocock setup-matt-pocock-skills (+ project profile, hooks) |
| `work` | new; replaces mattpocock ask-matt and addy using-agent-skills |
| `milestone-review` | new |
| `ship` | addy shipping-and-launch (renamed) |
| `resolve-conflicts` | mattpocock resolving-merge-conflicts (renamed) |
| `batch-grill` | mattpocock batch-grill-me (renamed) |

## Changes to Apache-2.0 files

Each modified file carries a "Modified for lpgh-skills" notice (Apache-2.0 §4(b)).

- `skills/frontend-design/SKILL.md` — description extended, a modification notice and an "In lpgh-skills" section added at the top; the original guidance below it is unchanged. `skills/frontend-design/DESIGN-PHASE.md` is new.
- `skills/webapp-testing/SKILL.md` — one sentence appended to the description, a modification notice and an "In lpgh-skills" preface added, the original text placed under "Original guidance" unchanged. `scripts/`, `examples/` and `LICENSE.txt` are unchanged.
