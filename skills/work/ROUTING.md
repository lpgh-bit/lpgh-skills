# Routing

When the situation isn't the main flow, pick from here, tell the user which skill and why in one line, then run it. User-invoked skills: read `../<name>/SKILL.md` and follow it. Full list: [`../../references/skill-catalog.md`](../../references/skill-catalog.md).

## Main flow

```
idea ─► grill ─► to-spec [G1] ─► to-tickets [G2] ─► milestone loop (implement per ticket)
     ─► milestone-review [G3] ─► … ─► ship
```

- No codebase yet / just thinking → `grill` (it skips the domain docs when there's no repo).
- Many questions at once preferred → `batch-grill`.
- A question needs a runnable answer → `prototype` (throwaway), bring the answer back.
- Facts needed from docs/APIs → `research` (background), feed the result into `grill`.
- Small, obvious change (≤ one ticket) → `implement` directly, no spec.
- New UI or a redesign without a spec → `frontend-design` design phase with the user first, then `implement` (or the main flow if it's bigger).
- Context getting full → `handoff`, continue in a fresh session with `/work <effort>`.

## On-ramps

```
Task arrives
 ├─ Request unclear / ambiguous ─────────────► grill (until clear), then route below
 ├─ Something broke / failing test / flake ──► debugging ─► fix ticket (to-tickets append) ─► implement
 ├─ Incoming reports piling up ──────────────► triage (not for tickets to-tickets made)
 ├─ Huge, foggy effort ──────────────────────► wayfinder ─► (map clear) ─► to-spec
 ├─ Review a branch / PR ────────────────────► review
 ├─ Codebase health, spare time ─────────────► improve-codebase-architecture ─► grill
 ├─ Merge/rebase conflict ───────────────────► resolve-conflicts
 ├─ Deploying / launching ───────────────────► ship
 ├─ Removing or replacing a system ──────────► deprecation-and-migration ─► to-tickets (expand–contract)
 ├─ Quality bar not written down ────────────► constraint-driven-development
 ├─ CI/CD pipeline work ─────────────────────► ci-cd-and-automation
 ├─ Logs / metrics / alerts ─────────────────► observability-and-instrumentation
 ├─ Manual multi-step procedure for a human ─► wizard
 ├─ Pre-commit hooks ────────────────────────► setup-pre-commit
 ├─ Enforce deep modules in a TS repo ───────► setup-ts-deep-modules
 ├─ Writing or editing a skill ──────────────► writing-great-skills
 └─ Repo not configured ─────────────────────► init
```

## While building (load alongside implement)

UI → `frontend-ui-engineering` + `frontend-design` (design phase with the user when `DESIGN.md` doesn't cover it) · API/contracts → `api-and-interface-design` · module shape → `codebase-design` · untrusted input/auth → `security-and-hardening` · hot paths → `performance-optimization` · framework APIs → `source-driven-development` · high stakes/unfamiliar code → `doubt-driven-development` · browser verification → `browser-testing-with-devtools` · domain terms/decisions → `domain-docs` · agent context setup → `context-engineering` · git/release → `git-workflow-and-versioning`.

## Typical short chains

- Bug: `debugging` → `tdd` (regression test) → `review`.
- Refactor: `codebase-design` → `to-tickets` (expand–contract if wide) → `implement` → `review`.
- Small feature: `grill` → `implement` → `review`.
