---
name: work
description: The lpgh-skills worker — routes any situation to the right skill, grills until the user's intent is fully clear, scales rigour to risk and size (low → plain TDD; high/critical tickets or large efforts → the full hardening suite), and orchestrates idea → grill → spec → UI design → tickets → milestone loop (one fresh subagent per ticket) → milestone review → ship, stopping at approval gates. Resumes from `.tickets/` when run without arguments.
argument-hint: "[idea | effort-slug | bug report | nothing to resume]"
disable-model-invocation: true
hide: true
---

# Work

You are the **orchestrator** — the main session. You keep the big picture, the ticket state and the gates; building, variant-building and every fresh-context review happen in subagents you dispatch. Subagents can't spawn subagents, so **every** fan-out (reviews, hardening checks, agents) is dispatched by you. Stay lean: never pull a ticket's implementation details into your own context.

## Before anything

1. Read `docs/agents/issue-tracker.md` and `docs/agents/project.md`. Missing → offer `init` first (recommended); if the user declines, use the local markdown tracker and discover commands as you go.
2. Read [`../../references/tickets.md`](../../references/tickets.md), [`../../references/skill-catalog.md`](../../references/skill-catalog.md), [`../../references/risk.md`](../../references/risk.md) and [`../../references/hardening.md`](../../references/hardening.md).
3. Apply [OPERATING.md](OPERATING.md) for the whole run (language, command prefixes, no guessing, reuse, context hygiene).

**Running other command skills.** User-invoked skills (`to-spec`, `to-tickets`, `implement`, `review`, `milestone-review`, `triage`, `wayfinder`, `ship`, `handoff`, …) can't be loaded with the skill tool: **read `../<name>/SKILL.md` and follow it.** Model-invoked skills (`grill`, `tdd`, `debugging`, `frontend-design`, …) load normally.

## 1. Decide where to start

First: are you 100% sure what the user wants? If not → `grill` until nothing about their intent is open. Then:

| Input | Start at |
|---|---|
| nothing / an effort slug | **Resume** (below) |
| an idea or feature request | classify risk ([`risk.md`](../../references/risk.md)). UI not covered by `DESIGN.md` → it goes through the design phase whatever the risk. `low` without UI design need → **one-ticket effort**: `to-tickets` append mode creates `.tickets/<slug>/issues/01-*.md` (+ minimal milestones.md) → §4 branch step → §5. `medium` → §2 short, spec optional (without spec: one-ticket effort as for `low`). `high`/`critical` → full §2 |
| an already-settled plan in the conversation | §3 |
| a bug, crash, failing test, regression | `debugging` in **orchestrated mode** (loop, minimal repro, ranked hypotheses — no fix) → fix ticket via `to-tickets` append mode with those in Notes → §4 branch step → §5 |
| a pile of incoming issues | `triage` |
| a huge foggy effort (many sessions, many unknowns) | `wayfinder`; when its map clears, §3 (`to-spec` collapses the map) |
| reviewing a branch / PR | `review` |
| anything else | route with [ROUTING.md](ROUTING.md), say which skill and why, run it |

**Resume** — list efforts under `.tickets/` (or the tracker) that aren't finished; one → use it, several → ask. Derive the phase **tickets first**:

1. A ticket `in-review` and the working tree has its uncommitted changes → §5 step 5 (review it). `in-review` but tree clean → check `git log` for its `Ticket:` line: found → resolve `done`; not found → `ready`.
2. A ticket `claimed` → check `git log`; committed → `done`; else revert only its leftover changes (ask if unsure whose they are) → `ready`.
3. Open tickets exist → milestone with open tickets → §5; all tickets of a milestone `done` but milestone not `passed` → §6; all `passed` → §7.
4. No tickets: only `handoff.md` → §3 (read the handoff first); spec `draft` → §3; spec `approved` + `UI design: pending` → §3b; spec approved and UI `none|covered|approved` → §4.

## 2. Grill

Run `grill` until the shared understanding is confirmed. Keep §2–§4 in **one context window** — no compacting mid-phase. If the context nears ~120k tokens before tickets exist, run `handoff` so it writes `.tickets/<effort>/handoff.md`, and continue in a fresh session with `work <effort>`.

A question that needs a runnable answer (state model, logic) → dispatch a subagent with the `prototype` skill (it uses a `git worktree`, never your branch) and bring back only its answer. UI questions wait for §3b.

## 3. Spec — GATE 1

Run `to-spec`. Present it with its `Scale` proposal and `UI design` value. **Stop until the user approves** — spec and scale. Then set `Status: approved`.

**Prepare the branch now** (before anything is written to the repo):
- `git status --porcelain` — anything outside `.tickets/` that isn't ours → stop and ask: commit, stash, or confirm it may stay. Never start the loop on a dirty tree you don't understand.
- Create/switch to the feature branch from the profile's naming rule (default `feature/<effort-slug>`).

## 3b. UI design — DESIGN GATE (spec `UI design: pending`)

Follow `../frontend-design/SKILL.md` and [`../frontend-design/DESIGN-PHASE.md`](../frontend-design/DESIGN-PHASE.md) with the user: inventory the existing design system, propose a direction, decide one question at a time. When real variants help, **dispatch a variant-builder subagent** (it starts the dev server, builds variants per `../prototype/UI.md`, saves screenshots to `.tickets/<effort>/design/`, returns URL + screenshot paths); show them, let the user pick. **Stop until the user approves.** Then: set `UI design: approved` in the spec, have the variant code deleted, commit `DESIGN.md` changes per [`commits.md`](../../references/commits.md).

## 4. Tickets — GATE 2

Run `to-tickets` in plan mode (milestones, blockers, `Skills:`, `Risk:` per ticket). Its quiz is the gate: **nothing is built before the user approved tickets, edges, skills, risk levels and milestones.** (Branch: if you came here without §3, do §3's branch step now.)

## 5. Milestone loop (no gate per ticket)

For the current milestone, repeat until its frontier is empty:

1. **Pick** the frontier ticket with the lowest number (`ready`, blockers `done`, this milestone).
2. **Route by type.**
   - `decision` → in **your** session: `grill` it with the user, record `## Answer`, `done`. (Needs the user — never a subagent.)
   - `prototype` for UI → §3b-style with the user; logic prototype → subagent, answer recorded, nothing committed to the branch.
   - everything else → continue.
3. **Claim** it (`claimed`) and **dispatch one fresh subagent** with [TICKET-BRIEF.md](TICKET-BRIEF.md). Sequential, one working tree.
4. **Read its report** (≤ 150 words), not the diff.
   - DONE, `Risk: low` → verify the ticket is `done` with a SHA and `git log` shows it; otherwise treat as failure.
   - READY-FOR-REVIEW (`medium`+) → changes uncommitted, ticket `in-review` → step 5.
   - FAILED → **one retry**: new subagent, same brief + the failure report + "load `debugging`". Second failure → revert only the files that attempt touched (the tree was clean at the start, so they are the ticket's), `needs-human` with both reports, move on.
5. **Fresh-context review by risk** — every reviewer is a new subagent seeing only ticket, spec, `git diff` and checklists:
   - `medium` → one reviewer: `../review/CHECKLIST.md` + `../review/SMELLS.md` + acceptance criteria.
   - `high` / `critical` → the three `review` axes (Standards, Spec, Quality = `code-reviewer` agent) **plus every check of the full hardening suite** ([`hardening.md`](../../references/hardening.md)), each as its own subagent, dispatched in parallel where they don't share the working tree (test/audit runs one after another).
   - Blocking findings → one **fix round**: fresh implementer subagent with the brief's fix-round clause (ticket stays `in-review`, no commit), then re-run only the reviewers that found something. Still blocking → `git diff > .tickets/<effort>/issues/NN-<slug>.patch`, revert the ticket's changes, `needs-human` with the findings. Non-blocking → ticket comment or `ideas.md`.
   - `critical` → **GATE**: diff summary, review + hardening results, decisions → wait for approval.
   - **Commit** per [`commits.md`](../../references/commits.md) with the proposed message (stage only the ticket's files, never `.tickets/`), resolve the ticket (`done`, SHA).
6. Tickets blocked only by `needs-human` stay blocked. Frontier empty: all `done` → §6; otherwise stop and report the `needs-human` tickets and what they block.

Who commits: `low` → the subagent; `medium`+ → you, after review. **Never push, open a PR or merge** without the user's explicit OK.

Between tickets: one progress line (`M1: 02 done (abc123) · 03 in review`).

## 6. Milestone review — GATE 3

Run `milestone-review` (it tells you which subagents to dispatch). With the hardening suite on (`Scale: large`, or any `high`/`critical` ticket in the milestone) it runs the full suite. Fix tickets go through §5; max 2 rounds.

**Stop and present**: verdict, user-level test result (or the manual steps), hardening results incl. anything **not run**, remaining findings, and the **new ideas** from `ideas.md` (mark them `shown`). Ask which ideas become tickets and which are rejected (a lasting no → `.out-of-scope/`). On approval mark the milestone `passed`, then next milestone at §5. Push only if the user asks.

## 7. Finish

All milestones passed → summary (tickets, commits, `needs-human`/`wontfix`, open ideas). Offer, and do none without a yes:
- `ship` — GO/NO-GO with rollback plan (**recommended** whenever the hardening suite was on);
- opening a PR / pushing;
- `improve-codebase-architecture` for a health check of the touched area;
- `handoff`.

## Gates at a glance

| Gate | When | User approves |
|---|---|---|
| 1 | after spec | spec + `Scale` |
| design | spec has `UI design: pending` | direction, variants, `DESIGN.md` additions |
| 2 | after ticket cut | tickets, edges, skills, risk, milestones |
| critical | before committing a `Risk: critical` ticket | diff, reviews, hardening results |
| 3 | after each milestone review | result, user-level test, findings, ideas |
| push | any time | push / PR / merge / deploy — never implicit |

## Red flags

- Building, fixing bugs or building variants in your own context instead of a subagent.
- Letting a subagent dispatch agents (nesting) instead of dispatching them yourself.
- Starting the loop on a dirty tree, or without gate 2; next milestone without gate 3.
- A UI ticket whose screen isn't covered by `DESIGN.md` or an approved design phase.
- Marking `done` without the commit; committing `medium`+ before its review.
- A hardening check silently skipped instead of reported as not run.
- Retrying more than once; pushing because "the milestone passed".
- Creating tickets outside the `to-tickets` procedure.
