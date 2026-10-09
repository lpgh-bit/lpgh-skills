---
name: grill
description: Interviews the user relentlessly, one question at a time with a recommended answer each, until plan, design or idea reach a shared understanding — looking facts up instead of asking, leaving every decision to the user, and (in a codebase) recording glossary terms in CONTEXT.md and ADRs as decisions land. Can open with divergent variants when the idea is still rough, or with an intent check when the ask is underspecified. Use proactively whenever you are not 100% certain what the user wants — ambiguous, underspecified or open to more than one reasonable reading (missing who/why/success/constraints, vague goals like "make it better", conflicting requirements) — before planning or building, and keep going until nothing about their intent is left to guess. Also when the user says "grill me", "stress-test this", "interview me", "refine this idea", "ideate", "are we sure?".
---

# Grill

Interview the user relentlessly about every aspect of the plan, design or idea until you reach a **shared understanding**. Walk down each branch of the decision tree, resolving dependencies between decisions one by one.

For the batched variant — every frontier question at once, round by round — use `/batch-grill` instead.

## The rules

1. **One question at a time.** Wait for the answer before asking the next. Several questions at once are bewildering, invite skim answers, and lock in framing before earlier answers arrive.
2. **Always give your recommended answer** with each question, plus the reasoning that produced it. Reacting to a concrete guess is faster than answering from scratch, and it exposes *your* assumptions. Be visibly willing to be wrong — a polite user agreeing to be agreeable is the main risk.
3. **Facts are yours to find, decisions are the user's.** If a fact can be found by exploring the environment (files, code, git history, tools, docs), look it up — never ask. Put each *decision* to the user and wait for their answer.
4. **Walk the decision tree.** Ask questions whose prerequisites are settled first; a question that depends on an open answer waits. Each answer can open new branches — follow them until every branch is visited and nothing is silently assumed.
5. **Do not act until the user confirms shared understanding.** No code, spec, tickets or other downstream work during the session.

Question format:

```
Q: <one focused question>
Recommended: <your answer> — <why>
```

## Before the first question

- Read `docs/agents/project.md` (stack, commands) and the domain docs if present: `CONTEXT.md` / `CONTEXT-MAP.md` and relevant ADRs (layout per `docs/agents/domain.md`, default `docs/adr/`). If config is missing, discover what you need and suggest `/init` at the end.
- Pick the opening mode:

| Situation | Mode |
|---|---|
| A concrete plan or design to stress-test | **Grill** (default) — start walking the tree. |
| Ask is underspecified: missing *who*, *why*, *success* or the binding *constraint*; conventional ("build me a dashboard", "make it faster") | **Intent first** — see [INTENT.md](./INTENT.md). Then grill. |
| Idea is still rough; the user wants options, or "ideate"/"refine this idea" | **Diverge first** — see [DIVERGE.md](./DIVERGE.md). Then grill the chosen direction. |

Modes are openers, not separate sessions: once intent or direction is settled, continue grilling under the same rules.

**Invoked on your own** (you weren't 100% sure what the user wants): say in one line what is unclear and that you'll ask questions first. Then grill **until every decision about the user's intent is settled** — nothing left that you would otherwise have to guess. Small asks need fewer questions, never fewer than it takes to be certain. Restate, get the explicit yes, then go back to the original task (no forced `/to-spec` hand-off for small asks).

**Never guess what the user wants.** Facts you can look up (code, docs, git, tools) you look up. Everything about the user's intent — goals, scope, behaviour, priorities, look and feel, trade-offs — is the user's decision. Unless you are 100% certain what they want, `grill` them, and keep going until no such decision is left open. An assumption about intent is a bug, not a shortcut.

Don't use this skill for unambiguous mechanical asks (renames, typo fixes) or pure information requests. It needs a live user — in a non-interactive run (CI, scheduled loop, autonomous agent with no human), flag the open decisions as a blocker instead of answering them yourself.

## In a codebase: maintain the domain docs inline

When the session happens in a repo, grill **together with the `domain-docs` skill** — load it and apply it throughout:

- **Challenge against the glossary.** A term that conflicts with `CONTEXT.md` gets called out immediately: "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"
- **Sharpen fuzzy language.** Propose a precise canonical term for vague or overloaded words ("account" — Customer or User?).
- **Probe with concrete scenarios.** Invent edge cases that force precision about boundaries between concepts.
- **Cross-reference with code.** When the user states how something works, check the code. Surface contradictions: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"
- **Write as decisions land.** Update `CONTEXT.md` the moment a term is resolved; don't batch. Offer an ADR only when the decision is hard to reverse, surprising without context, *and* the result of a real trade-off. Formats and locations: `domain-docs`.
- **Flag ADR conflicts** explicitly rather than silently overriding: "Contradicts ADR-0007 — reopen it because…?"

`CONTEXT.md` is a glossary only — implementation decisions belong in the conversation (and later the spec) or an ADR.

## Listen for "want" vs. "should want"

Answers that sound like a thoughtful answer rather than a real one — "scalable", "clean architecture", "the standard approach", "I should probably…" — need a probe:

> "If you didn't have to justify this to anyone, what would you actually want?"

Likewise, "whatever you think is best" is delegation, not a decision: re-ask as a choice between two concrete options with your recommendation.

## When you're done

The session is done when every branch is visited **and** you can predict the user's reaction to the next three questions you would ask. If several rounds pass and you still can't, say so: "Something foundational is missing — want to step back?"

Then:

1. **Restate the shared understanding** tightly, in the user's words, so it can be confirmed or corrected line by line — the decisions made, plus an explicit **Out of scope** line (half of misalignment is silent disagreement about non-goals). For an intent-first session use the restate block in [INTENT.md](./INTENT.md).
2. **Get an explicit yes.** "Sounds good", "sure, let's go" or silence are not yes — ask "anything you'd refine?" Fold corrections in and restate.
3. **List what was written** — terms added to `CONTEXT.md`, ADRs created.
4. **Hand off and stop.** Tell the user the next step is **`/to-spec`** (it turns this conversation into `spec.md` without re-interviewing), or that `/work` continues from here if it started the session. Do not start downstream work in the same turn.

A divergent session may also produce the one-pager from [DIVERGE.md](./DIVERGE.md); save it to `docs/ideas/` only if the user asks.

## Red flags

- Two or more questions in one message (that is `/batch-grill`, not grill)
- A question without your recommended answer
- Asking the user something you could have looked up
- Answering a decision yourself, or treating "whatever you think" as a decision
- Accepting a buzzword ("scalable", "modern") as a goal without probing
- Glossary terms or ADRs batched up until the end instead of written as they land
- Implementation details written into `CONTEXT.md`
- Starting a spec, tickets or code before an explicit yes on the restate
- A restate without an "Out of scope" line

## Supporting files

- [INTENT.md](./INTENT.md) — read when the ask is underspecified: hypothesis + confidence, restate block, rationalizations.
- [DIVERGE.md](./DIVERGE.md) — read when the idea is still rough: variations, converge, one-pager.
- [frameworks.md](./frameworks.md), [refinement-criteria.md](./refinement-criteria.md), [examples.md](./examples.md) — read during divergent mode for lenses, the evaluation rubric, and sample sessions.
- `scripts/init-ideas-dir.sh` — creates `docs/ideas/` when the user asks to save a one-pager.
