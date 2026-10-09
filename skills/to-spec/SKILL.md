---
name: to-spec
description: Turns the current conversation into a spec (PRD) — problem, solution, user stories, decisions, test seams, success criteria, boundaries and a user-level acceptance test — and publishes it as `.tickets/<effort>/spec.md` or a tracker spec issue. Synthesis only, no new interview. Use when an idea has been discussed or grilled enough to write down, when the user says "write the spec/PRD", or when /work reaches the spec step.
disable-model-invocation: true
hide: true
---

# To Spec

Synthesise what the conversation and the codebase already say into one spec. **Don't re-interview what is already settled** — the grilling happened before (`/grill`, `/batch-grill`, or plain discussion). You ask the test-seam check in step 3 and approval at the end; any intent gap you find while writing goes through `grill` first — never guess it.

Read first: [`../../references/tickets.md`](../../references/tickets.md) — where the spec lives and how it is published — and [`../../references/hardening.md`](../../references/hardening.md) for the `Scale` rule.

Config: `docs/agents/issue-tracker.md` (which tracker), `CONTEXT.md` (domain vocabulary), `docs/adr/` (decisions), `docs/agents/project.md` (stack, commands, how a user runs the app). If any is missing, discover what you need from the repo and suggest `/init` at the end — don't block.

## Process

### 1. Ground yourself

Explore the repo enough to know the current state of the area you're specifying (skip if already done this session).

Read the effort's existing inputs if present: `.tickets/<effort>/handoff.md` (a session that handed off before the spec — read it first) and `.tickets/<effort>/map.md` with its wayfinder tickets (Decisions so far, each resolved ticket's `## Answer`) — those decisions are settled input, not questions to reopen. Read `.out-of-scope/` at the repo root: don't put anything recorded there into the spec without new reasons; list relevant entries under **Out of Scope**. Use the `CONTEXT.md` vocabulary throughout the spec. Respect ADRs in the area; if the conversation contradicts one, flag it in the spec under **Further Notes** rather than silently overriding.

### 2. Scope check

Most requests are one capability — skip to step 3. If the conversation bundles several **independently testable capabilities** (own consumers or data; acceptance criteria cluster into groups that could ship separately; one could be cut without rewriting the others), propose splitting: list each capability as a candidate effort with a kebab-case slug and its dependencies (one direction, no cycles), and ask the user which to spec now. One spec per effort.

### 3. Agree the test seams

Sketch the seams at which the feature will be tested, in the `codebase-design` vocabulary. Prefer existing seams to new ones; use the **highest seam** possible — the interface of a **deep module** that hides the feature's complexity behind a small surface; if new seams are needed, propose them as high as you can and say which module gets deeper. The fewer seams the better — the ideal is one.

Also sketch the **user-level acceptance**: how a user will exercise the finished feature through the real interface (browser, CLI invocation, game input, API call) — read "how a user runs the app" from `docs/agents/project.md`.

**Check with the user that the seams and the user-level path match their expectations.** This is the one question this skill asks before writing.

### 4. Write the spec

Pick the effort slug (kebab-case, short, stable — it names the folder and prefixes every ticket ref `<effort>#NN`). If `.tickets/<effort>/spec.md` already exists, update it in place instead of creating a second spec.

Fill the template below. Rules:

- **No guessed intent.** If writing the spec reveals anything about the user's intent that wasn't explicitly agreed (behaviour, scope, priorities, numbers, edge cases), stop and `grill` those points first, one question at a time — then write. The spec only records what the user decided or what you verified in the code.
- **Reframe vague goals as testable success criteria** ("faster" → "dashboard LCP < 2.5 s on 4G"). Thresholds come from the user (grill for them, with a recommended number) — never invent them.
- **No file paths or code snippets** — they go stale. Exception: a prototype snippet that encodes a decision more precisely than prose (state machine, reducer, schema, type shape) — inline only the decision-rich part and say it came from a prototype.
- Stack, commands, layout and code style belong in `docs/agents/project.md`, not the spec. Reference it; only record spec-specific deviations.
- If the project already uses an external spec system (OpenSpec etc.), keep its format and location; this skill still owns the content and the approval gate.

### 5. Publish

Per `tickets.md` **Publish spec**:

- **Local tracker** — write `.tickets/<effort>/spec.md` (create the folder; make sure `.tickets/` is in `.gitignore`).
- **GitHub / GitLab** — one issue labelled `spec` with the spec as its body, via the commands in `docs/agents/issue-tracker.md`.

Spec header starts `Status: draft`. Do not create tickets here.

Header values (fixed, English — see `tickets.md`):

- `Scale:` — propose `small` · `medium` · `large` per the rule in `hardening.md` (one level up when in doubt); the user confirms it at the approval gate. `large` turns on the full hardening suite for every milestone.
- `UI design:` — `none` (no UI), `pending` (design phase needed) or `covered` (`DESIGN.md` already covers every screen). **Never write `approved`** — that is set only after the user approved the design phase.

### 6. Present and stop

1. Summarise the spec in a few lines, including the proposed `Scale` (with the reason) for the user to confirm. **Open Questions** must be empty and **Assumptions** may only hold verified technical facts — anything else goes back through `grill` before you ask for approval.
2. Ask the user to approve or request changes.
3. **Stop.** Don't break it into tickets or write code in the same turn. On approval, set `Status: approved` (local) / comment "approved" (tracker).

When `/work` runs this skill, it owns the approval gate — just present and ask; `/work` records the outcome and continues.

End with: **Next: /to-tickets**

## Spec template

```markdown
# Spec — <Feature name>

Effort: <effort-slug>
Status: draft
Scale: small | medium | large
UI design: none | pending | covered

## Problem Statement

The problem the user faces, from the user's perspective.

## Solution

The solution, from the user's perspective.

## User Stories

A LONG, numbered list covering every aspect of the feature — happy paths, edge cases, errors, roles, empty states:

1. As a <actor>, I want <feature>, so that <benefit>

## Success Criteria

Specific, testable conditions that mean "done" — functional outcomes and measurable targets.

- [ ] ...

## Non-functional Requirements

Only what applies: performance budgets, security/privacy, accessibility, observability, compatibility, data retention. Each one testable.

## Implementation Decisions

Decisions made in the conversation: modules built or modified, their interfaces, schema changes, API contracts, architectural choices, specific interactions, technical clarifications from the developer. No file paths or code (prototype exception above).

**Reuse:** existing modules, components, services and dependencies this work builds on or extends. A new parallel solution is listed here only with its reason (nothing fits, or the user explicitly asked for it).

## Testing Decisions

- What makes a good test here: external behaviour only, not implementation details.
- The agreed seams (step 3) and which modules are tested through them.
- Prior art: similar tests already in the codebase.

## User-level Acceptance

How a user exercises the finished feature through the real interface, end to end. Concrete steps with expected results, e.g.:

1. Run `<command>` / open `<page>` / press `<key>` …
2. Expect …

This is what `/milestone-review` runs at the end.

## UI Design

Only when the work has a user interface (no UI → header `UI design: none`, omit this section). Leave the header as `UI design: pending` — the design phase (`../frontend-design/DESIGN-PHASE.md`, run by `/work` after spec approval) fills it with the chosen direction, wireframes, per-screen states and copy decisions, and sets `UI design: approved`. If `DESIGN.md` / the design system already covers every screen, set the header to `UI design: covered` and list here which `DESIGN.md` parts apply.

## Boundaries

- **Always:** things every implementer must do (e.g. validate input at the API edge, keep the old endpoint working).
- **Ask first:** changes needing a human OK (schema migrations, new dependencies, CI changes, public API breaks).
- **Never:** hard lines (commit secrets, edit vendored code, delete failing tests to go green).

## Out of Scope

What this spec deliberately does not cover.

## Assumptions

Technical facts the spec relies on, each verified in the code/docs (with where). No assumptions about user intent — those are grilled.

## Open Questions

Must be empty before approval. If something is open, grill it first.

## Further Notes

ADR conflicts, links, risks, anything else.
```

## Keeping the spec alive

The spec is the source of truth `/implement`, `/review` and `/milestone-review` check against. When a decision or scope changes later, update the spec first (and note it under Further Notes), then the tickets.

## Red flags

- Asking the user a string of clarifying questions — that's `grill`'s job; synthesise what's settled and send real gaps through `grill`. Open Questions must be empty at approval, never a parking spot.
- Writing the spec and starting tickets or code in the same turn.
- Vague success criteria ("works well", "fast") with no measurable condition.
- No user-level acceptance, or one that only runs unit tests.
- One spec spanning several independently shippable capabilities.
- File paths and code in Implementation Decisions.

| Rationalization | Reality |
|---|---|
| "This is simple, it doesn't need a spec" | Then the spec is short — it still needs success criteria and a user-level check. |
| "Requirements will change anyway" | That's why the spec is updated, not skipped. |
| "The user knows what they want" | Clear requests still carry implicit decisions; grill them instead of writing them down as assumptions. |
| "I'll split the capabilities during ticketing" | By then the oversized spec exists. Decide boundaries before writing. |
