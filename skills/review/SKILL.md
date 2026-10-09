---
name: review
description: Reviews the changes since a fixed point (commit, branch, tag, or merge-base) along three independent axes run as parallel subagents — Standards (the repo's documented standards plus a Fowler smell baseline), Spec (does it do what the spec/ticket asked?), and Quality (correctness, readability, architecture, security, performance) — and reports them side by side without reranking. Can turn findings into fix tickets. Use when the user wants to review a branch, PR, or work in progress, asks to "review since X", or before merging.
disable-model-invocation: true
hide: true
---

# Review

Three-axis review of the diff between `HEAD` and a fixed point:

- **Standards** — does the code follow this repo's documented coding standards (plus the smell baseline)?
- **Spec** — does the code faithfully implement the originating spec / ticket?
- **Quality** — is it correct, readable, well-structured, secure and fast enough? (five dimensions)

Each axis runs in its **own parallel subagent** so they don't pollute each other's context; this skill aggregates their reports.

Config: `docs/agents/issue-tracker.md` (how to fetch tickets/specs), [`../../references/tickets.md`](../../references/tickets.md). If config is missing, assume the local `.tickets/` tracker and suggest `/init`.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — SHA, branch, tag, `main`, `HEAD~5`. If they gave none, ask (suggest the merge-base with the default branch). A caller (`/work`, `/milestone-review`) passes it explicitly.

Capture once: `git diff <fixed-point>...HEAD` (three-dot → against the merge-base) and `git log <fixed-point>..HEAD --oneline`. Confirm the ref resolves (`git rev-parse <fixed-point>`) and the diff is non-empty — a bad ref or empty diff fails here, not inside three subagents. If uncommitted changes are part of what the user wants reviewed, say so and include `git diff HEAD` too.

### 2. Find the spec source

In this order:

1. A path, ticket ref (`<effort>#NN`) or issue id the user passed.
2. Ticket refs in the commit messages (`<effort>#NN`, `#123`, `Closes #45`, `!67`) → fetch the ticket file `.tickets/<effort>/issues/NN-*.md` (or tracker issue, per `docs/agents/issue-tracker.md`) **and** its effort's `.tickets/<effort>/spec.md` / spec issue.
3. A `.tickets/<effort>/spec.md` whose effort slug matches the branch name or feature; then spec/PRD files under `docs/` or `specs/`.
4. Nothing found → ask the user. If there is none, the Spec axis is skipped and reported as "no spec available".

### 3. Find the standards sources

Anything that documents how code should be written: `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `CONTEXT.md` (vocabulary), `docs/adr/`, lint/format configs (to know what tooling already enforces), `docs/agents/project.md`. The Standards axis always also carries the [smell baseline](SMELLS.md).

### 4. Spawn the three subagents in parallel

One message, three Agent/task-tool calls. Each prompt gets the diff command, the commit list, and its brief. Keep each report under 400 words.

**Standards subagent** — also: the standards-source file list and [SMELLS.md](SMELLS.md) pasted in full. Brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard — cite file + rule; (b) any baseline smell — name it and quote the hunk. Mark each finding *hard* or *judgement*: documented-standard breaches can be hard, baseline smells are always judgement, and a documented repo standard overrides the baseline. Skip anything tooling enforces."

**Spec subagent** — also: the spec path or fetched contents, and the ticket(s) with their acceptance criteria. Brief: "Report (a) requirements or acceptance criteria missing or partial; (b) behaviour in the diff nobody asked for (scope creep); (c) requirements that look implemented but wrong; (d) any spec Boundary ('never' / 'ask first') crossed. Quote the spec or ticket line for each finding." Skip this subagent if there's no spec.

**Quality subagent** — use the `code-reviewer` agent ([`../../agents/code-reviewer.md`](../../agents/code-reviewer.md)) if the harness offers it; otherwise spawn a generic subagent and paste that agent file plus [CHECKLIST.md](CHECKLIST.md) into its prompt. Also pass the spec/ticket summary. Brief: "Review the tests first, then each changed file across correctness, readability, architecture, security, performance. Label every finding Critical / Required / Optional / Nit with file:line and a concrete fix for Critical and Required. Don't report Fowler smells — another reviewer owns them. Read-only: don't modify files."

If the diff touches auth, sessions, secrets, untrusted input or payments, also spawn the `security-auditor` agent in the same message (its report goes under Quality as a sub-section).

**Why Quality is a third axis, not folded into Standards:** Standards answers "does it follow *this repo's* rules?" — a documented rule is citable and can be hard. The five dimensions are general engineering judgement that applies even when the repo documents nothing, and correctness/security findings are often the most severe. Mixing them would let a long list of smells bury a security hole, or let a clean Standards report imply the code is correct. Three focused contexts also review deeper than one crowded one.

### 5. Aggregate

Present the reports under `## Standards`, `## Spec`, `## Quality`, verbatim or lightly cleaned. **Do not merge or rerank across axes.** Where two axes flag the same hunk, leave both — the duplication is signal.

End with one line per axis: number of findings and the worst issue *within that axis*. Don't pick a single winner across axes.

### 6. Offer fix tickets

Turn actionable findings into fix tickets via the `/to-tickets` procedure in **append mode** ([`../to-tickets/SKILL.md`](../to-tickets/SKILL.md)) — never write ticket files yourself.

- **Run standalone:** list the proposed tickets (title + severity) and ask the user which to create. Create only on OK.
- **Run by `/work` or `/milestone-review`:** return the findings and proposed items; the caller decides.

Per item hand over: title, what to fix (behaviour, not file paths), acceptance criteria, `Type: fix`, `Severity`, `Milestone` (the reviewed ticket's milestone, or `-`), `Blocked by: -`, `Source: review`, and the effort (the spec's effort; `inbox` if none).

Severity mapping: Quality Critical → `critical`; Quality Required, hard Standards violation, missing/wrong Spec requirement, crossed Boundary → `major`; Quality Optional, judgement smells, scope creep → `minor`. Nits and FYIs are not ticketed. Group findings that share one fix into one ticket. Optional improvements and suggestions (Quality Optional, nits worth keeping, refactor/performance ideas) go to the effort's `ideas.md` (**Note idea**, `../../references/tickets.md`) so the user can decide later.

## Why separate axes

A change can pass one axis and fail another:

- Follows every standard but implements the wrong thing → Standards pass, Spec fail.
- Does exactly what the ticket asked but breaks conventions → Spec pass, Standards fail.
- Conventional and on-spec but has an injection hole or an N+1 → Quality fail.

Reporting them separately stops one axis from masking another.

## Reviewing well

- Approve when the change definitely improves code health, even if it isn't perfect.
- No rubber stamps, no softened bugs, quantify where possible.
- For oversized diffs, dependency bumps, dead code, disagreements and the rationalization table: [REFERENCE.md](REFERENCE.md).
- `/implement` uses [CHECKLIST.md](CHECKLIST.md) and [SMELLS.md](SMELLS.md) for its light self-review; the full three-axis run is this skill and `/milestone-review`.
