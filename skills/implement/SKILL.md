---
name: implement
description: Implements one ticket (`.tickets/<effort>/issues/NN-*.md` or a tracker id) or a small no-ticket change — claims it, loads the ticket's skills, builds in thin test-first increments at the agreed seams, verifies, self-reviews, resolves the ticket and makes one commit on the current branch. Never pushes. On failure writes a report into the ticket and returns it. Use when the user says "implement <ticket>", "build the next ticket", or when /work dispatches a ticket.
disable-model-invocation: true
hide: true
---

# Implement

Build **one** ticket — or one small change that has no ticket — to done: tested, verified, self-reviewed, committed. One ticket per run; one commit per ticket.

Read first: [`../../references/tickets.md`](../../references/tickets.md) — fields, statuses, Claim/Comment/Resolve.

## 1. Fetch

- **Ticket given** (`<effort>#NN`, a path, or a tracker id): Fetch the ticket including comments, the effort's `spec.md` (or spec issue), and the ticket's milestone entry in `milestones.md`. Earlier failure reports in `## Comments` are input — don't repeat the approach that failed.
- **No ticket** (small change from the conversation): restate the change and its acceptance in two or three lines and unless you are 100% certain what the user wants, run `grill` until nothing about their intent is open (only when a user is reachable — a ticket subagent records the ambiguity in the ticket and stops instead). If it's bigger than one ticket's worth (several seams, more than ~5 files, needs design decisions), stop and suggest `/to-spec` → `/to-tickets`.

Check the ticket is workable: `Status: ready` (or `claimed` by this run's caller), every `Blocked by` ticket `done`. **Fix round:** when the brief says "fix round", the ticket is `in-review` with the reviewers' findings — accept it as is: no re-claim, no status reset; fix the findings in the working tree and return it `in-review`. Otherwise not workable → stop and say why.

## 2. Claim

Set `Status: claimed` and save **before any work** (real tracker: also assign `@me`). Skip for no-ticket changes and fix rounds.

## 3. Load context

- Read the ticket's `Risk` and [`../../references/risk.md`](../../references/risk.md). No `Risk` line (or no ticket) → classify it yourself with the rubric and write it into the ticket. Add the skills that level requires.
- Load **every skill named in the ticket's `Skills:` field** (`tdd` is the usual default) — they are model-invoked (`grill` included) and load normally; a user-invoked one would be read from `../<name>/SKILL.md`. Their rules apply for the whole run. In a ticket subagent `grill` can't reach the user: record the open questions in the ticket and stop.
- Read `docs/agents/project.md` for the test, single-test, typecheck, lint, build and run commands (plus `check:fast` / `check:task` when the repo has a `CONSTRAINTS.md`), and how a user runs the app. Missing → discover them from the repo (build files, CI config, README) and suggest `/init` in your final report.
- Use `CONTEXT.md` vocabulary; respect `docs/adr/`. Read the spec's **Testing Decisions** (agreed seams) and **Boundaries** (always / ask first / never). An "ask first" item stops the run for a human decision.

### Reuse first

**Reuse existing code first.** Before writing anything new, search the codebase for code that already does it or nearly does it — helpers, services, components, utilities, patterns, dependencies already in the build. Use or extend it. Write a new, one-off solution only when nothing fits or the ticket/user explicitly asks for it, and record why under the ticket's `## Decisions` ("no reuse: <what you checked, why it doesn't fit>"). Never add a new dependency when an existing one covers the need.

## 4. Build in thin increments

Drive the `tdd` skill at the **pre-agreed seams** from the spec/ticket — behaviour-level tests through the public interface, one red → green cycle at a time. Refactoring is not part of the loop (`tdd`): it happens only as a separate prefactoring step or ticket, or via `code-simplification`. Don't invent new seams; if the agreed one turns out untestable, record why in the ticket and pick the next-highest seam.

Each increment:

1. **Pick the smallest complete slice** — vertical through the stack where the ticket spans layers; the riskiest slice first when something is uncertain.
2. **Red → green** via `tdd`.
3. **Verify:** typecheck and run the affected single test file(s). Lint if fast.
4. **Stay green.** The project builds and existing tests pass after every increment. If an increment goes wrong and you can't see why quickly, revert the working tree to the last green state and take a smaller step (load `debugging` if the cause is unclear).

Discipline (details and examples: [REFERENCE.md](REFERENCE.md)):

- **Simplest thing that works.** No abstraction before the third use; three similar lines beat a premature helper.
- **Scope control.** Touch only what the ticket needs. No drive-by cleanups, import reshuffles, syntax modernising, or "useful" extras. Write what you notice into the effort's `ideas.md` (**Note idea**, `tickets.md`) and list it under *Noticed, not touched* in the final report.
- **One logical thing per increment;** never mix a refactor with new behaviour in the same step.
- **Rollback-friendly.** Additive over invasive; migrations come with their down path; don't delete and replace in one step.
- **Safe defaults;** a feature flag only if the ticket ships something not yet user-ready.
- Don't re-run an unchanged command for reassurance.
- **Throwaway branches only via `git worktree add`** (e.g. `git worktree add ../<repo>-<slug> -b throwaway/<slug>`) — never switch or stash the shared working tree; remove the worktree when done.

### Research and prototype tickets

`Type: research` / `Type: prototype` tickets produce an answer, not feature code:

- **research** — do the `research` work **inline** in this context (a subagent can't spawn a background agent); write the findings under the ticket's `## Answer` with sources.
- **prototype** — build it in a **worktree** on a throwaway branch (`git worktree add`), per `prototype`; record the verdict under `## Answer` and the branch as a context pointer.
- **Nothing is committed to the feature branch.** Resolve the ticket with the answer instead of a commit SHA (step 7 commit is skipped).

## 5. Verify the whole ticket

1. Run the **full test suite** once, plus typecheck, lint and build. If the repo has a `CONSTRAINTS.md`, run its `check:task` command from `docs/agents/project.md` and get it green — never by weakening the bar (`constraint-driven-development`).
2. Tick off each **acceptance criterion** against evidence (a test, a command output).
3. Run the ticket's **User-level test** through the real interface (CLI invocation, browser: `webapp-testing` — headless Playwright — for every UI ticket; `browser-testing-with-devtools` only for interactive debugging when that MCP exists; game input) when feasible in this environment. If not feasible, say exactly why and what a human should run.
4. Check the standing bar in [`../../references/definition-of-done.md`](../../references/definition-of-done.md).

## 6. Record decisions, then self-review

Write every non-trivial decision you made (approach chosen over alternatives, assumptions, edge-case handling, anything a reviewer could disagree with) under `## Decisions` in the ticket, one line each with the reason. For `high`/`critical` this is what the orchestrator's doubt pass cross-examines — be honest and complete.

### Light self-review

Review **this ticket's diff only** against the `review` skill's [CHECKLIST.md](../review/CHECKLIST.md) (five dimensions) and [SMELLS.md](../review/SMELLS.md), plus the ticket's acceptance criteria. Do it yourself — no subagents; the full three-axis review is `/review` and `/milestone-review`. Optionally invert one condition the change adds, run its test, and restore the file — a mutation that stays green means a missing test case. Fix what you find, re-verify, then move on.

## 7. Resolve and commit — depends on `Risk`

- **`low`** — commit and resolve yourself (steps 1–3 below).
- **`medium` / `high` / `critical`** — **do not commit.** Leave the changes in the working tree, set `Status: in-review`, put the proposed commit message in a ticket comment (`- <date> implement: READY FOR REVIEW — proposed commit: <subject>`), and return. The orchestrator runs the fresh-context review(s) from `risk.md`, then commits and resolves (or sends findings back to a fresh implementer). Run by hand without `/work`: you are the orchestrator — spawn the review subagent(s) from `risk.md` yourself, address findings, and for `critical` show the user the diff and wait for approval before committing.

1. Set `Status: in-review`.
2. Commit to the **current branch** — one commit for the ticket, following [`../../references/commits.md`](../../references/commits.md): authored by the user's git identity, **no Co-Authored-By or other AI attribution**, subject `+ / - / ~ <imperative summary>`, body with the why, last line `Ticket: <effort>#NN`. Stage only files the ticket touched; never commit `.tickets/`. **Never push.** No-ticket change: same format without the `Ticket:` line.
3. **Resolve** per `tickets.md`: `Status: done`, tick the acceptance boxes, Comment with the commit SHA and the user-level test result.

Final report: ticket, SHA, tests/user-level result, *Noticed, not touched*, anything a human must check.

## When blocked or failing

After an honest attempt — the agreed approach tried, `debugging` applied to a failure you don't understand, no progress for a sustained stretch — stop. Don't loosen tests, skip verification, or widen scope to get green.

1. Revert uncommitted half-work to the last green state (keep nothing broken in the tree); keep useful notes.
2. Comment on the ticket:
   ```
   - <date> implement: FAILED — <one-line reason>
     Tried: <approaches, briefly>
     Evidence: <failing test / command + key output>
     Suspected cause: <best hypothesis>
     Needs: <decision, access, spec change, or smaller ticket>
   ```
3. Leave `Status: claimed` and return the report. The caller (`/work`) decides: retry with a fresh context, or set `needs-human`. Run standalone, show the report to the user.

## Red flags

- Writing code before claiming the ticket, or before a failing test.
- More than ~100 lines written without running a test.
- "While I'm here…" edits outside the ticket.
- A new helper/component/service that duplicates or parallels existing code, or a new dependency where an existing one would do.
- Build or tests red between increments.
- Several unrelated changes in one increment.
- Tests weakened, skipped or deleted to go green.
- User-level test silently skipped.
- Pushing, or committing `.tickets/`.

| Rationalization | Reality |
|---|---|
| "I'll test it all at the end" | Bugs compound; a broken slice 1 makes slices 2–5 wrong. |
| "Faster to do it all at once" | Until it breaks and you can't tell which of 500 lines did it. |
| "This refactor is small enough to include" | Mixed refactor + behaviour is harder to review and revert. Note it; separate ticket. |
| "The user-level test is obvious, skip it" | Unit-green and user-broken is the failure this step catches. |
