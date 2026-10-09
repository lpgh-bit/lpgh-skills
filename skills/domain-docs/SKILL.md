---
name: domain-docs
description: Builds and maintains a project's domain documentation — the CONTEXT.md glossary (ubiquitous language), ADRs in docs/adr/, and supporting docs (README, API docs, code comments, changelog). Use when pinning down domain terminology, recording a hard-to-reverse architectural decision, when a change introduces new domain terms or changes a public API, when a grill session runs in a codebase, or when another skill needs to maintain the domain model.
---

# Domain Docs

Actively build and sharpen the project's domain model as you design, and write the glossary and decisions down the moment they crystallise. This is the *active* discipline — challenging terms, inventing edge-case scenarios, recording decisions. Merely *reading* `CONTEXT.md` for vocabulary is a habit every skill has (see "Consuming the docs"); load this skill when you are changing the model or the docs, not just using them.

## Layout

Read `docs/agents/domain.md` first (written by `/init`): it says whether the repo is single- or multi-context and where the glossary and ADRs live. Its choices override the defaults below. If it's missing, infer the layout from the repo and suggest `/init` when you report back.

Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

When multiple contexts exist, infer which one the topic belongs to; if unclear, ask.

Create files lazily — only when you have something to write. No `CONTEXT.md` yet: create it when the first term is resolved. No ADR directory yet: create it when the first ADR is needed.

## Consuming the docs (every skill)

- Before exploring an area, read `CONTEXT.md` (or the relevant ones via `CONTEXT-MAP.md`) and the ADRs that touch it. If they don't exist, proceed silently — don't flag their absence or create them upfront.
- Use the glossary's terms exactly in names, tests, tickets and proposals. Don't drift to synonyms listed under `_Avoid_`. Needing a term that isn't there means either you're inventing language (reconsider) or there's a real gap (resolve it here).
- If your output contradicts an ADR, say so explicitly rather than silently overriding: _"Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…"_

## Sharpening the model

### Challenge against the glossary

When the user uses a term that conflicts with `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force precision about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. Surface contradictions: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

The term or boundary itself is the user's decision; facts about the current code are yours to look up.

## Writing CONTEXT.md

When a term is resolved, update `CONTEXT.md` right there. Don't batch — capture terms as they happen. Format and rules: [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` is a glossary and nothing else — no implementation details, not a spec, not a scratch pad, not a place for implementation decisions. Only terms specific to this project's domain; general programming concepts don't belong.

## Writing ADRs

Offer an ADR only when **all three** are true:

1. **Hard to reverse** — changing your mind later is costly
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and one was picked for specific reasons

If any is missing, skip it. Typical qualifiers: architectural shape, integration patterns between contexts, technology with lock-in (database, auth, framework, hosting), hard-to-migrate data models and API styles, boundary decisions, deliberate deviations from the obvious path, constraints invisible in the code, non-obvious rejected alternatives.

Default form is one paragraph: context, decision, why. Match any existing ADR convention in the repo before using the defaults. Never delete an ADR; supersede it with a new one. Template, optional sections, numbering and convention rules: [ADR-FORMAT.md](./ADR-FORMAT.md).

## Other documentation

When a change adds or alters a public API, ships user-visible behaviour, or leaves a non-obvious gotcha, document it with the change: comment the *why* not the *what*, document APIs with their types and errors, keep README quick start and commands accurate (commands from `docs/agents/project.md`), keep the changelog and agent rules files current. Read [DOCUMENTATION.md](./DOCUMENTATION.md) when writing comments, API docs, a README, a changelog or rules files.

## Red flags

- A conflicting or fuzzy term accepted without challenge
- Glossary updates batched until the end of a session
- Implementation details, specs or TODOs in `CONTEXT.md`
- General programming terms (timeouts, retries, DTOs) in the glossary
- An ADR for an easily reversible or obvious choice — or none for a hard-to-reverse, surprising trade-off
- A second ADR numbering scheme or location next to an existing one
- An old ADR edited or deleted instead of superseded
- Code, tests or tickets using a synonym the glossary says to avoid

## Report back

When used inside another skill (e.g. `/grill`), end by listing what changed: terms added or redefined in `CONTEXT.md`, ADRs created or superseded, other docs touched.
