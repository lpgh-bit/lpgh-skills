---
name: milestone-review
description: Big review after a milestone's tickets are done — spec and cross-ticket coherence, standards, readability, full verification suite, test coverage, performance, security, simplification, and a user-level acceptance test through the product's real interface (browser, CLI, game). Findings become fix tickets that are worked and re-reviewed (max 2 rounds). Use when /work finishes a milestone or the user asks to review a milestone.
argument-hint: "<effort> <milestone, e.g. M1>"
disable-model-invocation: true
hide: true
---

# Milestone Review

A milestone is only **passed** when the code is coherent, readable, verified, secure, fast enough — and a user can actually use it. This review proves that across the whole milestone, not ticket by ticket.

Read first: [`../../references/tickets.md`](../../references/tickets.md), `docs/agents/project.md` (commands, product kind, **how a user runs it**), the effort's `spec.md` and the milestone's entry in `milestones.md`.

## 0. Preconditions

- Every ticket of the milestone is `done` (or `wontfix`). Otherwise stop and list what's open.
- Fixed point = the commit before the milestone's first ticket commit (or the end of the previous milestone). Diff: `git diff <fixed-point>...HEAD`. Confirm it resolves and is non-empty.
- Set the milestone's `Status: in-review` in `milestones.md`.

## 1. Run the axes

Run axes A–F as **parallel subagents** (each gets: fixed point, diff command, spec path, milestone entry, ticket paths, `docs/agents/project.md`; each returns ≤ 400 words of findings with file/hunk, severity `critical|major|minor`, and evidence). Run G yourself after A–F, or in parallel if it doesn't share the working tree with a running build.

| Axis | How | Looks for |
|---|---|---|
| **A. Spec & coherence** | the Spec axis of `review` across all milestone tickets + `milestones.md` acceptance | missing/partial acceptance, scope creep, **tickets that don't fit together**: duplicated logic across tickets **or with code that already existed before the milestone** (one-off re-implementations instead of reuse), inconsistent naming/patterns/error handling, a broken end-to-end path between slices, glossary drift from `CONTEXT.md`, ADR conflicts, **UI drift from `DESIGN.md` / the spec's `## UI Design`** (tokens, components, layout, states, copy) |
| **B. Standards & readability** | the Standards axis of `review` ([SMELLS](../review/SMELLS.md)) + readability pass | documented-standard violations, smells, and **readability**: can a new engineer follow it without explanation? names, function length, nesting, comments that explain *why*, dead code, clever code. Unreadable code is a `major` finding, not a nit. |
| **C. Verification & tests** | run **full** suite, typecheck, lint, build from `project.md`; `test-engineer` agent for gaps | red anything (→ `critical`), flaky tests (run the suite twice if it's fast), untested behaviour in the diff, tests coupled to implementation, weakened/skipped tests |
| **D. Performance** | `performance-optimization` skill; for web apps also the `web-performance-auditor` agent | measured regressions on the milestone's paths (startup, hot endpoints, queries/N+1, bundle size, Core Web Vitals, frame time for games); measure, don't guess — report numbers |
| **E. Security** | `security-auditor` agent + `security-and-hardening` skill | untrusted input, authn/z, secrets, injection, dependency risks in the diff |
| **F. Simplification** | `code-simplification` skill (read-only here) | needless abstraction, indirection, code that could be deleted |
| **G. User-level acceptance** | see §2 | the milestone works for a user, end to end |

Spawn subagents with the generic subagent/task tool of the harness; agents in this plugin's `agents/` folder are available by name.

## 2. User-level acceptance test (G)

Test the milestone **the way its user meets it** — never by calling internals or firing raw requests at an API that users reach through a UI.

| Product | Test through |
|---|---|
| Web app | a real browser: the harness's browser tool (omp built-in browser; Claude Code chrome / Playwright / chrome-devtools MCP via `browser-testing-with-devtools`). Click, type, navigate like a user; check console errors and visible results. |
| CLI | real invocations of the built binary/script in a shell, incl. `--help`, wrong input, exit codes, output format. |
| API product (the API *is* the user surface) | the documented client path: curl/HTTP client against the running service as an integrator would. |
| Game / desktop / GUI | launch it; drive it with input automation (e.g. xdotool, platform automation, the engine's test harness) and screenshots; check the milestone's behaviour visibly happens. |
| Library | a small consumer script using only the public API, as a user's project would. |

Steps:
1. Build and start the product with the commands from `project.md` (seed data/test accounts as documented).
2. Execute the milestone's **User-level test** from `milestones.md`, then each ticket's User-level test, then one unscripted "real user" pass around the edges (empty states, bad input, back/refresh, repeated actions).
3. Record evidence: steps, observed result, screenshots/output snippets, console errors. For UI, compare screenshots against `DESIGN.md` and the chosen variant (desktop and mobile width).
4. Stop anything you started.

**If no means to test as a user exists** in this environment (best available tool order: harness tool → Playwright/automation → nothing): the milestone **cannot pass** here. Write precise manual test steps (setup, actions, expected results) for the user and mark G as `pending-manual`. Never substitute an API call or unit test and call it a user test.

## 3. Findings → fix tickets

Collect findings from A–G, de-duplicate across axes (keep the higher severity, note both axes). Then:

- `critical` / `major` → fix tickets via the `to-tickets` procedure in **append mode** (read `../to-tickets/SKILL.md`): `Type: fix`, `Severity`, `Milestone: <this one>`, `Source: milestone-review`, acceptance = the finding resolved + evidence, `Skills:` from the catalog (e.g. `security-and-hardening` for E findings).
- `minor` findings and every improvement suggestion (optimisation, simplification, reuse opportunity, UX) → **Note idea** in `ideas.md` (`seen by: milestone-review`) and list them in the report; they become tickets only when the user picks them.
- Contradictions with the spec that need a decision → `needs-human` ticket, not a fix.

**Loop** (when run by `/work`): the fix tickets go through `/work`'s ticket dispatch; afterwards re-run **only the axes that produced findings** plus C and G. At most **2 rounds**; whatever remains goes to the user at the gate.

Run standalone: present the findings and ask before creating tickets.

## 4. Report (the gate)

```
## Milestone <M#> — <name>: PASSED | NOT PASSED | PENDING MANUAL TEST

User-level test: <passed/failed/pending-manual> — <evidence or manual steps>
Verification: suite <n passed/failed>, typecheck, lint, build
Rounds: <n>; fix tickets: <list with status>

### Remaining findings
| Sev | Axis | Finding | Where |

### Per axis (one line each)
A … G
```

Verdict rules: **PASSED** only when C is green, G passed, and no `critical`/`major` finding remains. G `pending-manual` → PENDING MANUAL TEST. Set `Status: passed` in `milestones.md` **only after the user approves at the gate** (`/work` does this).

## Red flags

- Reviewing ticket by ticket instead of the milestone as a whole.
- "User test" done via API calls/unit tests for a product users reach through a UI.
- Performance claims without measurements.
- Passing with a red suite or an unexecuted user test.
- More than 2 fix rounds without asking the user.
- Fixing findings directly instead of through fix tickets.
