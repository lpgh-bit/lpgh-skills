---
name: work
description: The lpgh-skills worker — routes any situation to the right skill, scales process rigour to the risk of the work (low → plain TDD, high/critical → fresh-context reviews, doubt-driven development, extra gates), and orchestrates the whole flow idea → grill → spec → tickets → milestone loop (one fresh subagent per ticket) → milestone review → ship, stopping at approval gates. Resumes from `.tickets/` when run without arguments.
argument-hint: "[idea | effort-slug | bug report | nothing to resume]"
disable-model-invocation: true
hide: true
---

# Work

You are the **orchestrator**. You keep the big picture, the ticket state and the gates; the actual building happens in fresh subagents. Stay lean: never pull a ticket's implementation details into your own context.

## Before anything

1. Read `docs/agents/issue-tracker.md` and `docs/agents/project.md`. Missing → offer `/init` first (recommended); if the user declines, use the local markdown tracker and discover commands as you go.
2. Read [`../../references/tickets.md`](../../references/tickets.md) and [`../../references/skill-catalog.md`](../../references/skill-catalog.md).
3. Apply the operating behaviours in [OPERATING.md](OPERATING.md) for the whole run.

**Running other command skills.** Flow skills (`grill`, `to-spec`, `to-tickets`, `implement`, `review`, `milestone-review`, `triage`, `wayfinder`, `ship`, …) are user-invoked only, so you can't load them with the skill tool. Run one by **reading `../<name>/SKILL.md` and following it** as if it had been invoked. Model-invoked skills (`tdd`, `debugging`, …) load normally.

## 1. Decide where to start

| Input | Start at |
|---|---|
| nothing | **Resume** (below) |
| an effort slug / `.tickets/<effort>` path | Resume that effort |
| an idea or feature request | classify its risk with [`../../references/risk.md`](../../references/risk.md): `low` → `implement` directly (still a fresh subagent, §5 steps 3–6); `medium` → short §2, spec optional; `high`/`critical` → full §2 |
| an already-settled plan in the conversation | §3 Spec |
| a bug, crash, failing test, regression | `debugging` → fix ticket via `to-tickets` append mode → §5 for that ticket |
| a pile of incoming issues | `triage` |
| a huge foggy effort (more than a few sessions, many unknowns) | `wayfinder`; when its map clears, continue at §3 |
| anything else / unsure | route with [ROUTING.md](ROUTING.md), tell the user which skill and why, run it |

**Resume:** list `.tickets/*/` efforts (or tracker efforts) with open tickets. One → use it; several → ask which. Then derive the phase from state:

- no `spec.md` or spec `Status: draft` → §3 · approved spec with `UI design: pending` → §3b · approved spec (UI approved/covered/none) but no tickets → §4 · `milestones.md` has a milestone with tickets not all `done` → §5 for it · all tickets of a milestone `done` but milestone not `passed` → §6 · all milestones `passed` → §7.
- Tickets stuck in `claimed`/`in-review` from a crashed session: check git log for their commit; finished → `done`, else back to `ready`.

## 2. Grill

Run `grill`. Keep §2–§4 in **one context window** (no compacting) so spec and tickets build on the same thinking. If the context nears ~120k tokens before tickets exist, run `handoff` and continue in a fresh session with `/work <effort>`.

If a question needs a runnable answer (state model, UI feel), detour through `prototype` and bring the answer back.

## 3. Spec — GATE 1

Run `to-spec`. Present the spec. **Stop and wait for the user's approval.** Apply requested changes, then continue.

## 3b. UI design — DESIGN GATE (only when the spec has UI)

If the spec's `## UI Design` says `pending`: run the design phase with the user — read `../frontend-design/SKILL.md` and [`../frontend-design/DESIGN-PHASE.md`](../frontend-design/DESIGN-PHASE.md): inventory the existing design system, propose a direction, show real in-app variants when the screen is new or the user is unsure, record the result in `DESIGN.md` and the spec. **Stop until the user approved the UI design** (`UI design: approved`). `covered by DESIGN.md` → skip.

## 4. Tickets — GATE 2

Run `to-tickets` in plan mode (milestones, blockers, `Skills:` per ticket). Its quiz is the gate: **don't start building until the user approved tickets, edges, skills and milestones.**

Then create the feature branch from the project profile's naming rule (default `feature/<effort-slug>`) unless already on it.

## 5. Milestone loop (no gate per ticket)

For the current milestone, repeat until its frontier is empty:

1. **Pick** the frontier ticket with the lowest number (Status `ready`, blockers `done`, this milestone).
2. **Claim** it (Status `claimed`) before dispatching.
3. **Dispatch one fresh subagent** with the brief from [TICKET-BRIEF.md](TICKET-BRIEF.md). One ticket per subagent; run them sequentially (one working tree).
4. **Read its report** (≤ 150 words) — not the diff.
   - Success, `Risk: low` → verify the ticket says `done` with a commit SHA and `git log` shows it. If not, treat as failure.
   - Success, `Risk: medium`+ → the changes are uncommitted and the ticket is `in-review`. Continue with step 5.
   - Failure → **one retry**: a new subagent with the same brief plus the first failure report and the instruction to load `debugging`. Second failure → `git restore`/`git clean` only the files that attempt touched (ask before anything destructive beyond that), set `needs-human` with both reports in Comments, and move on.
5. **Fresh-context review by risk** ([`../../references/risk.md`](../../references/risk.md)) — each reviewer is a new subagent that gets only ticket, spec, `git diff` of the working tree and the checklists:
   - `medium` → one review subagent: `../review/CHECKLIST.md` + `../review/SMELLS.md` + the ticket's acceptance criteria.
   - `high` → the three `review` axes (Standards, Spec, Quality) as parallel subagents, plus one **doubt** subagent that cross-examines the ticket's `## Decisions` per `doubt-driven-development`.
   - `critical` → as `high` + `security-auditor`; offer the user a cross-model second opinion.
   Blocking findings (anything that breaks acceptance, correctness, security, or a documented standard) → one **fix round**: a fresh implementer subagent gets the findings and fixes them in the working tree (no commit), then re-run only the reviewers that found something. Still blocking → save the diff into the ticket (`git diff > .tickets/<effort>/issues/NN-<slug>.patch`), revert the ticket's uncommitted changes, set `needs-human` with the findings. Non-blocking findings → ticket comment.
   - `critical` → **GATE**: show the user the diff summary, review results and decisions; wait for approval.
   - Then **commit** with the subagent's proposed message (stage only the files the ticket touched, never `.tickets/`) and resolve the ticket (`done`, SHA comment).
6. Tickets blocked only by a `needs-human` ticket stay blocked. When the frontier is empty: if every ticket is `done` → §6; otherwise stop and report the `needs-human` tickets and what they block.

Commits: one per ticket, made by the subagent on the feature branch. **Never push, never open a PR, never merge** without the user's explicit OK.

Between tickets give the user a one-line progress note (`M1: 02 done (abc123) · 03 claimed`).

## 6. Milestone review — GATE 3

Run `milestone-review` for the milestone. It creates fix tickets for findings and loops (max 2 rounds), running them through §5's dispatch.

**Stop and present** its report: verdict, user-level test result (or the manual test steps the user must run), remaining findings — plus the **new ideas** from `ideas.md` (one line each, mark them `shown`). Ask which ideas to turn into tickets (`to-tickets` append mode, into this or a later milestone) and which to reject. Wait for the user. On approval mark the milestone `passed` in `milestones.md`, then continue with the next milestone at §5. The user may also ask to push here — only then push.

## 7. Finish

All milestones passed → summarise the effort (tickets, commits, open `needs-human`/`wontfix`) and every idea still `new`/`shown` in `ideas.md` for the user to accept or reject. Offer: `ship` (pre-launch checklist, rollout, rollback), opening a PR, `handoff`. Do none of them without a yes.

## Gates at a glance

| Gate | When | What the user approves |
|---|---|---|
| 1 | after spec | the spec |
| design | after spec, when there is UI | direction, variants, `DESIGN.md` additions |
| 2 | after ticket cut | tickets, blocking edges, skills, milestones |
| 3 | after each milestone review | milestone result, user-level test, remaining findings |
| critical | before committing a `Risk: critical` ticket | the diff, review and doubt results |
| push | any time | push / PR / merge — never implicit |

## Red flags

- Implementing in your own context instead of a subagent.
- Starting §5 without gate 2, or starting the next milestone without gate 3.
- Marking a ticket `done` because the subagent said so, without the commit.
- Retrying more than once.
- Reviewing a `medium`+ ticket in the implementer's own context, or committing it before the fresh-context review.
- Pushing because "the milestone passed".
- Creating tickets without the `to-tickets` procedure.
