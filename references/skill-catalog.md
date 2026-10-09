# Skill catalog

Every skill in lpgh-skills with one line on when it applies. `/to-tickets` picks each ticket's `Skills:` from the **Implementation skills** table; `/work` routes with the whole catalog. Keep this file in sync when adding or renaming a skill (`scripts/validate.sh` checks it).

**Invocation:** `cmd` = user-invoked only (`/lpgh-skills:<name>` in Claude Code, `/skill:<name>` in omp; marked `disable-model-invocation: true` + `hide: true`); `auto` = the agent may load it itself.

## Flow commands

| Skill | Inv. | Use when |
|---|---|---|
| `init` | cmd | Once per repo: tracker, `.tickets/`, domain docs, project profile, agent block, optional hooks. |
| `work` | cmd | Drive anything end to end: idea → grill → spec → tickets → milestone loop → ship; or resume from `.tickets/`. Also the router when unsure which skill fits. |
| `grill` | cmd | Sharpen an idea or plan by one-question-at-a-time interview; records glossary terms and ADRs as decisions land. |
| `batch-grill` | cmd | Same as grill, but every frontier question at once, round by round. |
| `to-spec` | cmd | Turn the agreed conversation into `spec.md` — no new interview. |
| `to-tickets` | cmd | Split a spec/plan into tracer-bullet tickets with blockers, skills and milestones; **the only way any skill creates tickets** (append mode). |
| `implement` | cmd | Build one ticket (or a small no-ticket change) test-first, verify, commit. |
| `review` | cmd | Two-axis review (Standards + Spec) of a diff since a fixed point, plus correctness/readability/architecture/security/performance pass. |
| `milestone-review` | cmd | Big review after a milestone: spec + coherence, readability, full suite, performance, security, simplification, user-level acceptance test. |
| `triage` | cmd | Move incoming bug reports / requests through triage states into agent-ready tickets. |
| `wayfinder` | cmd | Huge, foggy effort: chart a map of decision tickets and resolve them one per session. |
| `ship` | cmd | Pre-launch checklist, staged rollout, monitoring, rollback. |
| `handoff` | cmd | Compact the conversation into a handoff doc for a fresh session. |
| `claude-handoff` | cmd | Hand the conversation to a fresh background agent (Claude Code). |
| `improve-codebase-architecture` | cmd | Survey the codebase for deepening opportunities (HTML report), then grill one. |
| `wizard` | cmd | Generate an interactive bash wizard for a manual procedure. |
| `setup-pre-commit` | cmd | Husky + lint-staged + typecheck + tests on commit. |
| `setup-ts-deep-modules` | cmd | dependency-cruiser rules that enforce deep modules in a TS repo. |

## Implementation skills (valid in a ticket's `Skills:`)

| Skill | Use when the ticket… |
|---|---|
| `tdd` | changes behaviour that can be tested — **default for every feature/fix ticket**. |
| `debugging` | fixes a bug, flake, crash or regression; needs a reproducing feedback loop first. |
| `codebase-design` | introduces or reshapes a module interface or seam. |
| `api-and-interface-design` | adds/changes a public API, endpoint, type contract or module boundary. |
| `frontend-ui-engineering` | builds or changes UI components, layout, state, accessibility. |
| `frontend-design` | needs visual/aesthetic direction (new screens, redesigns). |
| `browser-testing-with-devtools` | must be verified in a real browser (DOM, console, network, perf). |
| `security-and-hardening` | touches untrusted input, auth, sessions, secrets, storage, third-party calls. |
| `performance-optimization` | has a performance requirement or touches a hot path / queries. |
| `observability-and-instrumentation` | adds logging, metrics, tracing or alerting. |
| `code-simplification` | is a refactor for clarity without behaviour change. |
| `deprecation-and-migration` | removes/replaces an API, feature or schema (expand–contract). |
| `ci-cd-and-automation` | changes build, CI or deployment pipelines. |
| `git-workflow-and-versioning` | involves release/versioning or tricky git work. |
| `source-driven-development` | depends on a framework/library API that must be checked against official docs. |
| `doubt-driven-development` | is high-stakes or in unfamiliar code (auth, money, irreversible migrations). |
| `constraint-driven-development` | sets or must respect the project's quality bar (`CONSTRAINTS.md`). |
| `domain-docs` | introduces domain terms or a hard-to-reverse decision (glossary/ADR/docs). |
| `context-engineering` | sets up rules files / agent context for the project. |
| `prototype` | is a `prototype` ticket: throwaway code to answer a design question. |
| `research` | is a `research` ticket: gather facts from primary sources. |
| `resolve-conflicts` | needs a merge/rebase conflict resolved. |
| `writing-great-skills` | creates or edits a skill. |

## Agents (subagents the review skills dispatch)

| Agent | Used by |
|---|---|
| `code-reviewer` | `review`, `milestone-review` |
| `security-auditor` | `milestone-review`, `review` on security-sensitive diffs |
| `test-engineer` | `milestone-review` (coverage gaps), `tdd` (test strategy) |
| `web-performance-auditor` | `milestone-review` for web apps |

## Choosing `Skills:` for a ticket

1. Start with `tdd` for `feature`/`fix`/`refactor` tickets (`debugging` instead of or in addition for `fix` tickets whose cause is unknown).
2. Add every implementation skill whose row matches what the ticket touches. Prefer 2–4 skills; more means the ticket is probably too big.
3. `research` / `prototype` / `decision` tickets list the matching skill (`research`, `prototype`, `grill`).
4. Add what the ticket's `Risk` level requires ([`risk.md`](risk.md)): `doubt-driven-development` for `high`/`critical`, plus `security-and-hardening` / `source-driven-development` / `performance-optimization` where their trigger applies.
