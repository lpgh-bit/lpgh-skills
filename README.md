# lpgh-skills

One engineering skill pack for **omp** and **Claude Code**. It merges [mattpocock/skills](https://github.com/mattpocock/skills), [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) and Anthropic's [frontend-design](https://github.com/anthropics/skills/tree/main/skills/frontend-design) + [webapp-testing](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) into 42 skills with one vocabulary, adds a `/work` orchestrator, a markdown ticket system with milestones and risk-based escalation, and `/init`.

## Quick start

**1. Install** (once per machine)

| | omp | Claude Code |
|---|---|---|
| add + install | `omp plugin marketplace add lpgh-bit/lpgh-skills`<br>`omp plugin install lpgh-skills@lpgh-skills` | `/plugin marketplace add lpgh-bit/lpgh-skills`<br>`/plugin install lpgh-skills@lpgh-skills` |
| command prefix | `/skill:<name>` | `/lpgh-skills:<name>` |

Remove `mattpocock-skills` and `frontend-design` if installed — lpgh-skills replaces both.

**2. Set up the repo** (once per repo) — omp `/skill:init` · Claude Code `/lpgh-skills:init`
(Not the bare `/init` — in Claude Code that is the built-in CLAUDE.md generator.) It asks for the language, tracker, project commands and how a user runs your product.

**3. Work** — omp `/skill:work <what you want>` · Claude Code `/lpgh-skills:work <what you want>`
Run it without text to resume where you left off.

## Default workflow

What `/work <idea>` does, and what you do:

| # | Step | What happens | You |
|---|---|---|---|
| 1 | **Grill** | Asks one question at a time, each with a recommendation, until nothing about your intent is open. Looks up facts itself. | answer, confirm the summary |
| 2 | **Spec** — gate | Writes `.tickets/<effort>/spec.md`: stories, decisions, test seams, user-level acceptance, and a size (`Scale: small/medium/large`). Then checks the working tree is clean and creates `feature/<effort>`. | approve spec + size |
| 3 | **UI design** — gate, only with UI | Proposes a direction based on your existing design, shows real variants in the app, records `DESIGN.md`. | pick / adjust |
| 4 | **Tickets** — gate | Cuts vertical-slice tickets with blockers, `Skills:`, `Risk:` and milestones. | approve / reshape |
| 5 | **Build** | Per ticket a fresh subagent: test-first, reuse existing code, verify. Review depth by risk; `high`/`critical` tickets get the **full hardening suite**. One commit per ticket on `feature/<effort>`. | nothing — progress lines; `critical` tickets wait for your OK |
| 6 | **Milestone review** — gate | Coherence, readability, full suite, performance, security, accessibility, and a test through the real UI/CLI; the **full hardening suite** for `Scale: large` or risky milestones. Findings → fix tickets. Improvement ideas listed. | accept the milestone, pick ideas |
| 7 | repeat 5–6 per milestone, then **ship** | Summary; `ship` fans out reviewer, security auditor and test engineer and gives a GO/NO-GO with rollback plan. | decide; push yourself, or say "push" |

Everything is in `.tickets/<effort>/` (local, gitignored). Nothing is pushed, merged or PR'd without your explicit OK.

**Other entry points** — all through `/work`, which routes: a bug (`/work the export crashes on empty orders`) → debugging + fix ticket · a tiny low-risk change → straight to build · a huge foggy effort → `wayfinder` · reviewing a branch → `review`.

## How it works

```
idea ─► grill ─► to-spec ──[G1 spec]──► (UI? design phase ──[design gate]──►) to-tickets ──[G2 tickets·skills·risk·milestones]──►
   ┌─► per ticket: fresh subagent runs implement (tdd + the ticket's Skills)
   │      low: commits itself · medium+: fresh-context review → commit · critical: [your OK] → commit
   └── until milestone done ─► milestone-review ──[G3]──► next milestone … ─► ship
```

- **Tickets** live in `.tickets/<effort>/` (gitignored): `spec.md`, `milestones.md`, `ideas.md`, `issues/NN-slug.md`. GitHub/GitLab issues work too (`/init`). Protocol: [references/tickets.md](references/tickets.md).
- **No guessing** — unless the agent is 100% sure what you want, `grill` loads by itself and asks one question at a time (with a recommendation) until nothing about your intent is open; specs may not contain guessed intent or open questions at approval.
- **UI is designed with you** — `frontend-design` reads `DESIGN.md` and the existing design system first. Anything not covered gets a design phase: direction proposal, real in-app variants to flip through, your pick, recorded in `DESIGN.md` (committed) and the spec. UI tickets then follow it without asking.
- **Every ticket names its `Skills:`** — the implementer loads exactly those. Catalog: [references/skill-catalog.md](references/skill-catalog.md).
- **Full hardening suite** for hard, important or large work — every addyosmani test and security check: five-axis review, security audit, dependency & secret scan, coverage analysis, mutation spot-check, doubt-driven review with cross-model offer, measured performance, accessibility, observability, quality-bar guards, Definition of Done, user-level test. Nothing is skipped silently. [references/hardening.md](references/hardening.md).
- **Risk decides rigour** — `low` plain TDD + self-review · `medium` fresh-context review · `high` three-axis review + doubt-driven development · `critical` + security audit + your approval before commit. [references/risk.md](references/risk.md).
- **Milestone review** — spec & cross-ticket coherence, readability, full suite, test gaps, performance (measured), security, simplification, and a **user-level test through the real interface** (browser, CLI, game). Findings become fix tickets (max 2 rounds).
- **Reuse first** — agents extend existing code; one-off solutions only when nothing fits or you ask for it.
- **Ideas, not surprises** — improvement suggestions go to `ideas.md` and are shown to you at the gates; you decide what becomes a ticket.
- **Language** — English by default; `/init` asks for another and then the conversation, specs, tickets, reviews, docs and commits use it (code follows the repo's convention). [references/language.md](references/language.md).
- **Git** — one commit per ticket on a feature branch, authored by you, no AI co-author trailers, `+`/`-`/`~` subjects ([references/commits.md](references/commits.md)). Never pushes, opens PRs or merges without your explicit OK.

## Skills

| Flow (user-invoked) | Auto (agent loads when relevant) |
|---|---|
| `init` `work` `batch-grill` `to-spec` `to-tickets` `implement` `review` `milestone-review` `triage` `wayfinder` `ship` `handoff` `claude-handoff` `improve-codebase-architecture` `wizard` `setup-pre-commit` `setup-ts-deep-modules` | `grill` `tdd` `debugging` `domain-docs` `codebase-design` `api-and-interface-design` `frontend-ui-engineering` `frontend-design` `webapp-testing` `browser-testing-with-devtools` `security-and-hardening` `performance-optimization` `observability-and-instrumentation` `code-simplification` `deprecation-and-migration` `ci-cd-and-automation` `git-workflow-and-versioning` `source-driven-development` `doubt-driven-development` `constraint-driven-development` `context-engineering` `prototype` `research` `resolve-conflicts` `writing-great-skills` |

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
./scripts/validate.sh   # frontmatter, flags, catalog/routing/README sync, stale names, links + routing evals (evals/routing.json)
```

Sources and licenses: [NOTICE.md](NOTICE.md).
