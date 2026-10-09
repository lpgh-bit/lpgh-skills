# lpgh-skills

One engineering skill pack for **omp** and **Claude Code**. It merges [mattpocock/skills](https://github.com/mattpocock/skills), [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) and Anthropic's [frontend-design](https://github.com/anthropics/skills/tree/main/skills/frontend-design) into 41 skills with one vocabulary, adds a `/work` orchestrator, a markdown ticket system with milestones and risk-based escalation, and `/init`.

## Install

**omp**
```sh
omp plugin marketplace add lpgh-bit/lpgh-skills   # or a local path: ./path/to/lpgh-skills
omp plugin install lpgh-skills@lpgh-skills
```

**Claude Code**
```
/plugin marketplace add lpgh-bit/lpgh-skills
/plugin install lpgh-skills@lpgh-skills
```

If you had them installed, remove `mattpocock-skills` and `frontend-design` — lpgh-skills replaces both.

Commands: Claude Code `/lpgh-skills:<name>`, omp `/skill:<name>`.

## Quick start

```
/init                 # once per repo: tracker, .tickets/, domain docs, project profile, agent block
/work <idea>          # grill → spec [gate] → UI design [gate, if UI] → tickets [gate] → milestone loop → milestone review [gate] → ship
/work                 # resume where .tickets/ says you are
```

## How it works

```
idea ─► grill ─► to-spec ──[G1 spec]──► (UI? design phase ──[design gate]──►) to-tickets ──[G2 tickets·skills·risk·milestones]──►
   ┌─► per ticket: fresh subagent runs implement (tdd + the ticket's Skills)
   │      low: commits itself · medium+: fresh-context review → commit · critical: [your OK] → commit
   └── until milestone done ─► milestone-review ──[G3]──► next milestone … ─► ship
```

- **Tickets** live in `.tickets/<effort>/` (gitignored): `spec.md`, `milestones.md`, `ideas.md`, `issues/NN-slug.md`. GitHub/GitLab issues work too (`/init`). Protocol: [references/tickets.md](references/tickets.md).
- **UI is designed with you** — `frontend-design` reads `DESIGN.md` and the existing design system first. Anything not covered gets a design phase: direction proposal, real in-app variants to flip through, your pick, recorded in `DESIGN.md` (committed) and the spec. UI tickets then follow it without asking.
- **Every ticket names its `Skills:`** — the implementer loads exactly those. Catalog: [references/skill-catalog.md](references/skill-catalog.md).
- **Risk decides rigour** — `low` plain TDD + self-review · `medium` fresh-context review · `high` three-axis review + doubt-driven development · `critical` + security audit + your approval before commit. [references/risk.md](references/risk.md).
- **Milestone review** — spec & cross-ticket coherence, readability, full suite, test gaps, performance (measured), security, simplification, and a **user-level test through the real interface** (browser, CLI, game). Findings become fix tickets (max 2 rounds).
- **Reuse first** — agents extend existing code; one-off solutions only when nothing fits or you ask for it.
- **Ideas, not surprises** — improvement suggestions go to `ideas.md` and are shown to you at the gates; you decide what becomes a ticket.
- **Language** — English by default; `/init` asks for another and then the conversation, specs, tickets, reviews, docs and commits use it (code follows the repo's convention). [references/language.md](references/language.md).
- **Git** — one commit per ticket on a feature branch, authored by you, no AI co-author trailers, `+`/`-`/`~` subjects ([references/commits.md](references/commits.md)). Never pushes, opens PRs or merges without your explicit OK.

## Skills

| Flow (user-invoked) | Auto (agent loads when relevant) |
|---|---|
| `init` `work` `grill` `batch-grill` `to-spec` `to-tickets` `implement` `review` `milestone-review` `triage` `wayfinder` `ship` `handoff` `claude-handoff` `improve-codebase-architecture` `wizard` `setup-pre-commit` `setup-ts-deep-modules` | `tdd` `debugging` `domain-docs` `codebase-design` `api-and-interface-design` `frontend-ui-engineering` `frontend-design` `browser-testing-with-devtools` `security-and-hardening` `performance-optimization` `observability-and-instrumentation` `code-simplification` `deprecation-and-migration` `ci-cd-and-automation` `git-workflow-and-versioning` `source-driven-development` `doubt-driven-development` `constraint-driven-development` `context-engineering` `prototype` `research` `resolve-conflicts` `writing-great-skills` |

Agents: `code-reviewer`, `security-auditor`, `test-engineer`, `web-performance-auditor`. Optional hooks (`sdd-cache`, `simplify-ignore`, Claude Code only) are offered by `/init`.

## Harness notes

- User-invoked skills carry both `disable-model-invocation: true` (Claude Code) and `hide: true` (omp).
- Flow skills call each other by reading `skills/<name>/SKILL.md`, because user-invoked skills can't be loaded by the model's skill tool.
- Subagents can't spawn subagents in Claude Code, so `/work` (the main session) runs every fresh-context review.
- Shared files in `references/` are resolved relative to each skill (`../../references/…`) — install the whole plugin, not single skill folders.

## With superpowers installed

superpowers overlaps (brainstorming ≈ `grill`, writing-plans ≈ `to-spec`/`to-tickets`, test-driven-development ≈ `tdd`, systematic-debugging ≈ `debugging`, requesting-code-review ≈ `review`) and its session hook pushes its own skills first. Use `/work` explicitly, or disable superpowers in repos that use lpgh-skills.

## Develop

```sh
./scripts/validate.sh   # frontmatter, invocation flags, catalog sync, stale names, links
```

Sources and licenses: [NOTICE.md](NOTICE.md).
