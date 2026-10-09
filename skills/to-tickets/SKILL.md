---
name: to-tickets
description: Break a spec, plan, or the current conversation into tracer-bullet tickets, each declaring its blockers, the skills its implementer must load, and its milestone — published to the configured tracker. Also the single entry point every other skill uses to create tickets (append mode).
disable-model-invocation: true
hide: true
---

# To Tickets

Turn agreed work into **tickets** — tracer-bullet vertical slices sized for one fresh agent context — grouped into **milestones**, each ticket naming the **skills** its implementer loads.

This skill is the **only** way tickets get created. Other skills (`review`, `milestone-review`, `debugging`, `triage`, `wayfinder`, `improve-codebase-architecture`, `deprecation-and-migration`) read this file and run **append mode**.

Read first:
- [`../../references/tickets.md`](../../references/tickets.md) — fields, statuses, file layout, operations.
- [`../../references/skill-catalog.md`](../../references/skill-catalog.md) — the skills you may put in `Skills:`.
- `docs/agents/issue-tracker.md` — which tracker and its commands (missing → local markdown; suggest `/init`).

## Modes

- **Plan mode** (default; user or `/work` invokes it with a spec, plan or conversation) — full process below, with the approval quiz.
- **Append mode** (another skill hands over a list of items for an existing effort) — skip steps 1–4. For each item fill the fields, pick `Risk` and `Skills:` (steps 3b–c), number after the effort's highest ticket, publish (step 5). No quiz unless the caller asks for one. Callers supply: title, what to build, acceptance criteria, `Type`, `Risk` (else classify it), `Severity` (fix), `Milestone`, `Blocked by`, `Source`.

## Plan mode

### 1. Gather context

Work from the conversation. If given a reference (effort slug, spec path, issue id), fetch it with all comments. Read `docs/agents/project.md`, `CONTEXT.md` and ADRs in the area. Use the glossary's vocabulary in titles.

If the effort already has open tickets for *different* work, stop and ask — never overwrite or renumber another plan's tickets.

### 2. Explore and find prefactoring

Explore the code the work touches. Note **existing code to reuse** (modules, helpers, components, patterns) and name it in each ticket's `## Notes` (by module/concept, not file path) so the implementer extends it instead of building a parallel solution. Look for **prefactoring** — "make the change easy, then make the easy change" — and put it first. Note risks and unknowns; schedule the riskiest slices early (fail fast).

### 3. Draft vertical slices

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, never one layer.
- A finished slice is demoable or verifiable on its own and leaves the system working.
- Each slice fits one fresh context window. Size S–M (≈1–5 files). L → split. "and" in the title → probably two tickets.
- ≤ 3–5 acceptance criteria per ticket; each testable.
- Every ticket gets a **User-level test**: how a user checks it through the real interface (browser click-path, CLI invocation, game input). Pure-internal tickets say which later ticket's user test covers them.

</vertical-slice-rules>

**a. Blocking edges.** Each ticket lists only the tickets that genuinely gate it. Unblocked tickets can start at once.

**b. Skills.** Every ticket that changes UI gets `frontend-design` **and** `frontend-ui-engineering`, and its `## Notes` name the `DESIGN.md` parts and the spec's `## UI Design` screen it implements. If the spec has UI but `UI design` isn't `approved`/`covered`, stop — the design gate comes first. For each ticket choose from the *Implementation skills* table in the catalog, following its "Choosing `Skills:`" rules — `tdd` by default for code tickets, plus every skill whose row matches what the ticket touches, typically 2–4.

**c. Risk.** Classify each ticket with [`../../references/risk.md`](../../references/risk.md) — highest matching row wins, one level up when in doubt — and add the skills that level requires to `Skills:` (e.g. `doubt-driven-development` for `high`/`critical`).

**d. Type.** `feature`, `fix`, `refactor`, `research`, `prototype`, `decision` or `chore`.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** breaks many call sites at once, so no vertical slice lands green. Sequence it **expand–contract**: expand (add the new form beside the old), migrate call sites in batches sized by blast radius (one ticket per batch, each blocked by the expand, CI green throughout), contract (delete the old form, blocked by every batch). If batches can't stay green alone, they share an integration branch and all block a final integrate-and-verify ticket — green is promised only there. Load `deprecation-and-migration` for these tickets.

### 4. Propose milestones, then quiz the user

Group tickets into **milestones**: each a demoable state a user can actually exercise end to end, typically 2–6 tickets. Order: prefactoring and risky slices in M1. Every milestone gets a goal, acceptance checks and one end-to-end **user-level test**.

Present:

```
M1 — <name>: <goal>
  01 <title>   [feature|medium] Skills: tdd, api-and-interface-design   Blocked by: -
     → <what it delivers>
  02 <title>   [feature|high] Skills: tdd, doubt-driven-development, security-and-hardening   Blocked by: 01
     → ...
  M1 user-level test: <steps>
M2 — ...
```

Ask:
- Granularity right (too coarse / too fine)? Merge or split anything?
- Blocking edges correct?
- Skills and risk level per ticket right?
- Milestone cuts right — is each one a state worth reviewing?

Iterate until approved. (`/work` treats this approval as its ticket gate.)

### 5. Publish

Publish in dependency order (blockers first) so `Blocked by` can reference real ids.

- **Local** — write `.tickets/<effort-slug>/milestones.md` and one file per ticket `.tickets/<effort-slug>/issues/NN-<slug>.md` using the templates in `tickets.md`. New tickets get `Status: ready` and `Source: to-tickets` (append mode: the caller's source). Make sure `.tickets/` is in `.gitignore`.
- **GitHub / GitLab** — one issue per ticket via the commands in `docs/agents/issue-tracker.md`: native milestone for `Milestone`, labels for `status:*` / `type:*` / `severity:*`, native blocking links where available (else a `Blocked by:` line), and the `Skills:` / `Source:` lines at the top of the body. Don't close or modify a parent issue.

Avoid file paths and code snippets in tickets — they go stale. Exception: a prototype snippet that encodes a decision (state machine, schema, type shape) — inline the decision-rich part and say it came from a prototype.

### 6. Hand off

Report: effort slug, milestones with ticket counts, the current frontier. Next step: `/work` (runs the milestone loop) or `/implement <effort>#NN` for one ticket at a time, clearing context between tickets.

## Red flags

- Horizontal slices ("all the API", "all the UI").
- A ticket without acceptance criteria or without a user-level test path.
- XL tickets, or tickets with 5+ skills.
- A milestone nobody could demo.
- Writing tickets from another skill without going through this procedure.
- Renumbering, deleting or overwriting existing tickets.

## Common rationalizations

| Rationalization | Reality |
|---|---|
| "The tasks are obvious" | Writing them down surfaces hidden dependencies and forgotten edge cases. |
| "I'll figure it out as I go" | Context windows are finite; tickets survive session boundaries. |
| "This one is too small to need a user-level test" | Then name the ticket whose user test covers it. |

Every ticket also clears the project-wide Definition of Done: [`../../references/definition-of-done.md`](../../references/definition-of-done.md).
