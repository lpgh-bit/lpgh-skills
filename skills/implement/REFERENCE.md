# Implement — increment reference

Read when choosing how to slice a ticket, or when an increment feels too big.

## The increment cycle

```
slice ──► red ──► green ──► verify (typecheck + single tests) ──► next slice
                                  │
                       red/unclear│──► revert to last green, smaller step
```

No refactor step inside the cycle — refactoring is a separate prefactoring step/ticket or `code-simplification`. Increments are verification checkpoints, not commits: the ticket lands as **one** commit. Keep each increment small enough that reverting the working tree to the previous green state costs minutes.

## Slicing strategies

**Vertical (preferred).** One complete path through the stack per slice:

```
Slice 1: create a task (storage + API + basic UI)  → user can create a task
Slice 2: list tasks                                → user sees their tasks
Slice 3: edit a task                               → user can modify tasks
```

**Contract-first.** When two sides must meet: define the contract (types/schema) first, implement one side against it with tests, then the other, then integrate.

**Risk-first.** Prove the riskiest piece (e.g. the WebSocket connection) before building on it. If it fails, you learn before investing in the rest.

If a ticket needs more than a handful of slices, it is probably two tickets — say so in the final report rather than silently growing it.

## Simplicity check

Before: "What is the simplest thing that could work?" After:

- Could this be fewer lines?
- Are the abstractions earning their complexity?
- Would a staff engineer ask "why didn't you just…"?
- Am I building for the ticket or for a hypothetical future?

```
✗ Generic event bus with middleware for one notification   ✓ a function call
✗ Abstract factory for two similar components              ✓ two components + shared helper
✗ Config-driven form builder for three forms               ✓ three forms
```

## Scope control

Do not: clean up adjacent code, refactor imports in files you only read, remove comments you don't fully understand, add unasked features, modernise syntax. Record instead:

```
NOTICED, NOT TOUCHED:
- <file/module>: <issue> (unrelated to this ticket)
→ candidate fix/refactor ticket via /to-tickets append mode
```

## Rollback-friendly steps

- Additive changes (new functions, new files) over edits to existing code.
- Edits to existing code minimal and focused.
- Schema migrations come with their rollback.
- Don't delete something and replace it in the same step — separate them.

## Safe defaults and flags

New options default to the conservative behaviour (`notify ?? false`). Use a feature flag only when the ticket ships an increment that must not be user-visible yet; the ticket or spec should say so.

## Increment checklist

- [ ] Does one thing, completely.
- [ ] Affected tests pass; typecheck passes (where the stack has one).
- [ ] Project still builds.
- [ ] No files outside the ticket's scope touched.

Run a command again only after the code changed since its last green run.
