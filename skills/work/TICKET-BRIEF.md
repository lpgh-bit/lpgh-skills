# Ticket subagent brief

Send this to a **fresh** subagent (Claude Code: Agent tool; omp: task agent), filled in. Give it paths, not pasted content — it reads the files itself. Nothing else from your context.

```text
You implement exactly one ticket in this repo and then stop.

Ticket: <effort>#<NN> — <path to ticket file or tracker id>
Spec: <path to spec.md or spec issue>
Milestone: <M#> — see <path to milestones.md>
Project profile: docs/agents/project.md
Branch: <feature branch> (already checked out — do not switch branches)
Risk: <low|medium|high|critical> — see <plugin>/references/risk.md

Procedure: read <plugin>/skills/implement/SKILL.md and follow it exactly. It tells you to claim
(already claimed by the orchestrator — keep it claimed), load every skill in the ticket's `Skills:`
line, build test-first at the agreed seams, verify (full suite, typecheck, lint, build, the ticket's
User-level test), record non-trivial decisions under `## Decisions`, self-review.
Risk low: commit once on this branch and resolve the ticket.
Risk medium/high/critical: do NOT commit — leave changes in the working tree, set in-review,
propose the commit message in a ticket comment, and return. Reviews happen outside your context.

Rules:
- Only this ticket. Don't touch other tickets' files or scope.
- Reuse existing code (helpers, services, components, patterns, dependencies) before writing new code.
  A one-off solution only if nothing fits or the ticket explicitly asks for it — record why under `## Decisions`.
- UI: follow DESIGN.md and the spec's `## UI Design` exactly; don't ask the user. Gaps → closest existing
  pattern, recorded under `## Decisions`, plus an idea in ideas.md.
- Improvements you notice outside this ticket: note them in the effort's ideas.md (see tickets.md "Note idea"), don't do them.
- Never push, merge, rebase or switch branches. Never commit `.tickets/`.
- If you cannot finish after an honest attempt: revert your uncommitted changes, write the failure
  report into the ticket's Comments as implement/SKILL.md describes, and return.
<fix round only:> - Fix exactly these review findings in the working tree, re-verify, don't commit:
  <findings>
<retry only:> - A previous attempt failed. Its report is in the ticket's Comments. Load the `debugging`
  skill first and do not repeat the failed approach.

Return ≤ 150 words: DONE, READY-FOR-REVIEW or FAILED, commit SHA (low only), test/typecheck/build results, user-level test
result (or why it couldn't run), anything noticed but not touched, anything a human must check.
```

`<plugin>` is this plugin's root — two levels above this file.
