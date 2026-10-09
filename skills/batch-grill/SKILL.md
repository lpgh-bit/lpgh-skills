---
name: batch-grill
description: A relentless interview that asks every frontier question at once, round by round.
disable-model-invocation: true
hide: true
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Before the first round read the domain docs (`CONTEXT.md`, relevant ADRs) and `.out-of-scope/` at the repo root — don't propose scope recorded there as rejected without new reasons. Everything the `grill` skill says applies here too, except the one-question-at-a-time rule: **never guess the user's intent** (unless you are 100% certain, it's a question for the frontier), and in a codebase **maintain the domain docs inline with `domain-docs`** — update `CONTEXT.md` the moment a term is resolved, offer an ADR for hard-to-reverse trade-offs, flag ADR conflicts.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask *now* without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a *later* round, not this one.

Finding *facts* is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it (heavy documentation lookups: the `research` skill) — don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report — ask the rest of the frontier now. The *decisions* are the user's — put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
