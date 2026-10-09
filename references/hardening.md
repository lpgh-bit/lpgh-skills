# Full hardening suite

The complete addyosmani test-and-security arsenal, applied without shortcuts. It is **on** when either holds:

- a ticket has `Risk: high` or `Risk: critical` → per ticket (in `/work` §5) **and** in its milestone review;
- the effort has `Scale: large` (spec header, confirmed at the spec gate) → in **every** milestone review and in `ship`, regardless of ticket risk.

`Scale: large` = more than one milestone **and** at least one of: several subsystems touched, external users/clients affected, data migration, new public API. Otherwise `small` (one ticket–one milestone) or `medium`. When in doubt, one level up.

## What runs

Every item runs as its own fresh-context subagent, dispatched by the **main session** (subagents can't spawn subagents). Agents from this plugin's `agents/` folder are dispatched *as* the subagent, never from inside one.

| # | Check | How | Blocks when |
|---|---|---|---|
| 1 | Five-axis code review | `code-reviewer` agent on the diff | any Critical |
| 2 | Security audit | `security-auditor` agent: threat model first, then OWASP Top 10 (+ LLM Top 10 if AI features), authn/authz, input validation, secrets, headers/CORS, data protection, error leakage — against `references/security-checklist.md` | any Critical/High |
| 3 | Dependency & secret scan | the project's audit command from `docs/agents/project.md` (e.g. `npm audit`, `./gradlew dependencyCheckAnalyze`, `pip-audit`, `osv-scanner`) + `gitleaks detect --redact` (or the repo's secret scanner); install-script gate for new packages | known-exploitable CVE in a used path; any secret |
| 4 | Test coverage analysis | `test-engineer` agent: happy path, edge cases, error paths, concurrency; Prove-It test for every fixed bug; `references/testing-patterns.md` | untested acceptance criterion or error path |
| 5 | Mutation spot-check | invert/neutralise 3–5 conditions the diff adds, run their tests, restore — a surviving mutant is a missing test | any survivor on a critical path |
| 6 | Doubt-driven pass | `doubt-driven-development`: fresh-context adversarial review of every non-trivial decision (ticket `## Decisions`, spec decisions); **offer a cross-model second opinion** | unresolved "this is wrong" finding |
| 7 | Performance, measured | `performance-optimization` + `references/performance-checklist.md`; web: `web-performance-auditor` agent (Core Web Vitals); backend: query plans, N+1, timing of hot paths before/after | regression beyond the budget in spec/`CONSTRAINTS.md` |
| 8 | Accessibility (UI) | `references/accessibility-checklist.md`; axe run via `webapp-testing`; keyboard-only walk; contrast; reduced motion | any WCAG A/AA failure on new UI |
| 9 | Observability | `observability-and-instrumentation` + `references/observability-checklist.md`: new endpoints/jobs/external calls have structured logs, RED metrics, traces, a symptom-based alert | new critical path without logs+metrics |
| 10 | Quality bar | `constraint-driven-development`: `CONSTRAINTS.md` checks (`check:full`) + the five "weakened bar" moves against the fixed point (new suppressions, skipped/deleted tests, stripped assertions, lowered thresholds, disabled checks) | any weakened bar without a recorded reason |
| 11 | Definition of Done | every section of `references/definition-of-done.md`, incl. per-feature Integration and Documentation | any unchecked item |
| 12 | User-level acceptance | `milestone-review` axis G through the real interface (`webapp-testing` for web) | failed or not executed |

At the end of an effort with the suite on, `ship` runs its GO/NO-GO decision with a mandatory rollback plan.

## Outcomes

Blocking findings → fix tickets via `to-tickets` append mode (`Severity` from the table, `Source: hardening`), worked and re-checked like any milestone-review finding. Non-blocking → `ideas.md`. Nothing in this suite may be skipped silently: a check that can't run (tool missing, no browser) is reported as **not run** with the reason, and the milestone cannot pass on it without the user's explicit OK.
