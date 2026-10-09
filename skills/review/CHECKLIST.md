# Quality checklist (five dimensions)

Used by the **Quality** axis of `/review` (via the `code-reviewer` agent) and by `/implement`'s light self-review of a ticket diff. Review the tests first — they reveal intent and coverage — then walk each changed file through the five dimensions.

Fowler smells are owned by the Standards axis ([SMELLS.md](SMELLS.md)); don't re-report them here.

## 1. Correctness

- [ ] Matches the spec / ticket acceptance criteria.
- [ ] Edge cases handled (null, empty, boundary values).
- [ ] Error paths handled, not just the happy path; no silent fallback hiding an unclear invariant.
- [ ] No off-by-one, race condition, or state inconsistency.
- [ ] Tests exercise behaviour through the agreed seam (not implementation details), have descriptive names, and would catch a regression. Bug fixes carry a regression test.

## 2. Readability & simplicity

- [ ] Names descriptive and consistent with `CONTEXT.md` and project conventions (no bare `data`, `temp`, `result`).
- [ ] Control flow straightforward — no nested ternaries, deep callbacks, "clever" tricks.
- [ ] Could it be done in fewer lines? Are abstractions earning their complexity (don't generalise before the third use)?
- [ ] No dead code: unused variables, back-compat shims, commented-out blocks, debug output.
- [ ] No new conditional bolted onto an unrelated flow (a design smell, not a nit — push it into its own helper/state/policy).

## 3. Architecture

- [ ] **Reuse:** does the diff re-implement something the codebase already has (helper, service, component, util, pattern) or add a dependency an existing one covers? Search for it — a parallel one-off solution is a `major` finding unless the ticket explicitly asked for it or `## Decisions` justifies it.
- [ ] Follows existing patterns; a new pattern is justified (and recorded as an ADR if hard to reverse).
- [ ] Module boundaries kept; dependencies flow one way, no cycles.
- [ ] Refactors *reduce* complexity, not relocate it — count the concepts a reader must hold.
- [ ] No feature-specific logic leaking into shared modules.
- [ ] Type boundaries explicit — question gratuitous `any`/casts/optionals.
- [ ] Change doesn't push an already-large file (~1000 total lines) further without decomposing first.
- [ ] **Deep modules** (`codebase-design`): no new shallow module whose interface is about as complex as its implementation; no pass-through layer.
- [ ] **Deletion test:** would deleting a new module/wrapper just move its complexity to the callers (keep it) or change nothing (it shouldn't exist)?
- [ ] **Seam placement:** tests and adapters sit at the highest seam that works; no new seam where an existing one would do.
- [ ] **UI diffs:** conform to `DESIGN.md` (tokens, components, states from the spec's `## UI Design`) and pass [`../../references/accessibility-checklist.md`](../../references/accessibility-checklist.md) (keyboard, labels, contrast, focus, reduced motion).

## 4. Security

Depth: `security-and-hardening` skill, [`../../references/security-checklist.md`](../../references/security-checklist.md).

- [ ] Untrusted input (users, APIs, files, logs, config) validated at system boundaries.
- [ ] No secrets in code, logs, or version control.
- [ ] Authentication/authorisation checked where needed.
- [ ] Queries parameterised; output encoded (no injection, no XSS).
- [ ] New dependencies trusted, maintained, license-compatible, no known vulnerabilities.

## 5. Performance

Depth: `performance-optimization` skill, [`../../references/performance-checklist.md`](../../references/performance-checklist.md).

- [ ] No N+1 queries; no unbounded loops or fetches; list endpoints paginated.
- [ ] No synchronous work that should be async; no large allocations in hot paths.
- [ ] No unnecessary re-renders (UI).

## Severity labels

Every Quality finding carries one:

| Label | Meaning | Fix-ticket `Severity` |
|---|---|---|
| **Critical** | Blocks merge: security hole, data loss, broken functionality | `critical` |
| **Required** | Must fix before merge: missing test, wrong abstraction, poor error handling | `major` |
| **Optional** | Worth considering: simpler design, useful refactor | `minor` |
| **Nit** | Formatting / taste; author may ignore | not ticketed |
| **FYI** | Context only | not ticketed |

**Lead with what matters:** correctness and security first, then structural regressions and missed simplifications, then the rest. One structural problem and ten nits → the structural problem *is* the review.

**Presumptive blockers** — surface each with the simpler design; escalate to Required only when the change actively makes structure worse: complexity relocated not reduced; a file pushed past the size boundary with no decomposition; feature logic in a shared module; a near-duplicate of a canonical helper; a silent fallback hiding an unclear invariant.

## Structural remedies

When flagging a structural problem, propose the move, not just the problem:

- Replace a chain of conditionals with a typed model or explicit dispatcher.
- Collapse duplicate branches into one clearer flow.
- Separate orchestration from business logic.
- Move feature-specific logic out of a shared module into its owner.
- Reuse the canonical helper instead of a near-duplicate.
- Make a type boundary explicit so downstream branching disappears.
- Delete a pass-through wrapper.
- Extract a helper, or split a large file into focused modules.

Prefer the remedy that removes moving pieces over one that spreads the same complexity around.
