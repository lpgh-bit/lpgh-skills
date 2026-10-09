# Ticket protocol

The single source of truth for how every lpgh-skills skill reads and writes **tickets**. Skills reference this file instead of restating it.

The repo's tracker is configured by `/init` in `docs/agents/issue-tracker.md`. That file says *which* tracker and gives the concrete commands; this file says *what* the operations mean. If `docs/agents/issue-tracker.md` is missing, assume the **local markdown** tracker below and suggest running `/init`.

## Vocabulary

- **Effort** — one feature, fix-batch or decision effort. Owns one spec (optional), one milestones file (optional), one map (wayfinder only), and its tickets.
- **Ticket** — one unit of work sized to one fresh agent context. Declares what blocks it.
- **Blocking edge** — "ticket B cannot start until ticket A is `done`".
- **Frontier** — tickets with `Status: ready`, every blocker `done`, not claimed. Lowest number first.
- **Milestone** — a group of tickets that together reach a demoable, user-testable state. Closed by `/milestone-review`.

## Fields

Every ticket carries these header fields (local: plain `Key: value` lines under the title; GitHub/GitLab: see adapter mapping).

| Field | Values | Notes |
|---|---|---|
| `Status` | `needs-triage` · `needs-info` · `ready` · `claimed` · `in-review` · `done` · `needs-human` · `wontfix` | exactly one |
| `Type` | `feature` · `fix` · `refactor` · `research` · `prototype` · `decision` · `chore` | exactly one |
| `Risk` | `low` · `medium` · `high` · `critical` | decides review depth and gates — see `risk.md` |
| `Milestone` | `M1`, `M2`, … or `-` | must exist in `milestones.md` |
| `Skills` | comma list of skill names from `references/skill-catalog.md` | the skills the implementer loads |
| `Blocked by` | comma list of ticket numbers, or `-` | |
| `Severity` | `critical` · `major` · `minor` · `-` | `fix` tickets only |
| `Source` | skill that created it (`to-tickets`, `milestone-review`, `review`, `triage`, `wayfinder`, `debugging`, …) | |

### Status lifecycle

```
needs-triage ─► needs-info ─► needs-triage          (triage only)
needs-triage ─► ready | needs-human | wontfix
ready ─► claimed ─► in-review ─► done
claimed ─► needs-human                               (gave up after retry)
any ─► wontfix                                       (out of scope, already built)
```

- `ready` = fully specified, an agent may pick it up (was `ready-for-agent`).
- `needs-human` = needs a human: judgement call, external access, or an agent failed twice (was `ready-for-human`).
- `in-review` = implemented; for `low` already committed, for `medium`+ changes left uncommitted until the fresh-context review passes (see `risk.md`).
- Triage-only categories map onto `Type`: bug → `fix`, enhancement → `feature`.

## Local markdown tracker (default)

```
.tickets/                       # gitignored
  <effort-slug>/
    spec.md                     # from /to-spec
    milestones.md               # from /to-tickets
    map.md                      # only for /wayfinder efforts
    ideas.md                    # improvement suggestions, not tickets (see below)
    issues/
      01-<slug>.md
      02-<slug>.md
  inbox/issues/NN-<slug>.md     # triaged reports with no effort yet
```

- One ticket per file, numbered from `01` in dependency order (blockers first). Never a combined file.
- Numbers are per effort; refer to a ticket elsewhere as `<effort-slug>#NN`.
- `done` tickets stay where they are.

### Ticket file template

```markdown
# <NN> — <Ticket title>

Status: ready
Type: feature
Risk: medium
Milestone: M1
Skills: tdd, frontend-ui-engineering
Blocked by: 01
Severity: -
Source: to-tickets

## What to build

End-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer list.

## Acceptance criteria

- [ ] ...

## User-level test

How a user would verify this through the product's real interface (browser, CLI invocation, game input). One or two concrete steps with the expected result.

## Decisions

Non-trivial decisions the implementer made (filled in during implementation; reviewed by the doubt pass for `high`/`critical`).

## Notes

Decisions, prototype snippets, links. No file paths or code that will go stale, unless a prototype snippet encodes a decision.

## Comments
```

### milestones.md template

```markdown
# Milestones — <effort>

## M1 — <name>
Goal: <the demoable state a user reaches>
Tickets: 01, 02, 03
Acceptance:
- [ ] <user-visible check>
User-level test: <how to exercise M1 as a user, end to end>
Status: open            # open | in-review | passed
```

### spec.md

Written by `/to-spec`; its template lives in that skill. It carries a `Status: draft | approved` line — `approved` once the user passed gate 1, and only then may `/to-tickets` cut tickets from it.

### ideas.md — improvement backlog

Any skill or agent that notices an optimisation or improvement **outside its current scope** (refactor, performance, UX, simplification, tooling, reuse opportunity, tech debt) writes it here instead of doing it. Ideas are suggestions, not work: nothing in `ideas.md` gets built until the user picks it.

```markdown
# Ideas — <effort>

- [ ] I-01 <one-line suggestion> — why: <benefit> · cost: S|M|L · seen by: <skill>, <ticket or milestone> · status: new
```

`status`: `new` → `shown` (presented to the user) → `accepted` (became ticket `<effort>#NN` via `to-tickets` append mode) | `rejected` (one-line reason). No effort yet → `.tickets/ideas.md`. On a real tracker: one issue per idea labelled `idea`.

## Operations

Every skill uses these names. The configured tracker file gives the concrete commands.

- **Publish ticket(s)** — **only through the `/to-tickets` procedure** (`skills/to-tickets/SKILL.md`). Other skills never write ticket files or issues directly: they hand `/to-tickets` a list of items (title, what to build, acceptance, type, severity, milestone, blockers, source) in *append mode*. This keeps numbering, fields and the `Skills:` assignment consistent.
- **Publish spec** — `/to-spec` writes `spec.md` (local) or one issue labelled `spec`.
- **Fetch** — read the ticket/spec/map file or issue, including comments.
- **Frontier** — list the effort's tickets, keep `Status: ready` whose blockers are all `done`; optionally filter by `Milestone`. Lowest number first.
- **Claim** — set `Status: claimed` and save *before* any work. On a real tracker also assign `@me`.
- **Set status** — rewrite the `Status:` line (local) / swap the `status:*` label.
- **Comment** — append under `## Comments` as `- <date> <author>: <text>` (local) / tracker comment.
- **Resolve** — set `Status: done`, tick acceptance boxes, append a closing comment with the commit SHA(s). Real tracker: close the issue with that comment.
- **Note idea** — append an `I-NN` line to `ideas.md` (status `new`). Never act on it in the same run.
- **Wayfinder map** — `map.md` (local) / an issue labelled `wayfinder:map`. Wayfinder ticket types map onto `Type`: research → `research`, prototype → `prototype`, grilling → `decision`, task → `chore`. Resolution answer goes under `## Answer` in the ticket.

## Rules every skill follows

- Use the domain vocabulary from `CONTEXT.md`; flag ADR conflicts instead of silently overriding.
- Never delete a ticket. Out of scope → `wontfix` with a one-line reason.
- Never change another effort's tickets unless the user asked.
- Write tickets in English.
