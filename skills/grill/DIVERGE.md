# Diverge-first opening

Use when the idea is still rough, or the user asks to ideate / refine an idea / see options before committing. Open the idea up, converge on one direction with the user, then grill that direction under the normal rules.

Philosophy: push toward the simplest version that still solves the real problem; start from the user experience and work back to technology; focus means saying no to good ideas; "how it's usually done" is not a reason. Be honest, not supportive — a good thinking partner is not a yes-machine.

## Phase 1 — Understand & expand

1. **Restate the idea as a "How might we…" problem statement.** Forces clarity on what is actually being solved.
2. **Sharpen, one question at a time** (with a recommended answer each): who is it for, specifically? What does success look like? Real constraints (time, tech, resources)? What's been tried? Why now? Don't generate variations until *who* and *success* are clear. Keep it to the few questions that matter — usually 3–5.
3. **In a codebase, look first.** Scan for existing architecture, patterns, constraints and prior art; ground variations in what exists and cite files.
4. **Generate 5–8 variations**, each with a reason it exists (tell a story, don't just list). Lenses:
   - **Inversion** — what if we did the opposite?
   - **Constraint removal** — what if budget/time/tech weren't factors?
   - **Audience shift** — what if this were for a different user?
   - **Combination** — merge with an adjacent idea?
   - **Simplification** — the 10x simpler version?
   - **10x version** — what at massive scale?
   - **Expert lens** — what would domain experts find obvious?

   More lenses (SCAMPER, HMW, first principles, Jobs to be Done, pre-mortem…): [frameworks.md](./frameworks.md). Pick the lens that fits; don't run them all.

Say which variations you'd push toward and why. Then let the user react.

## Phase 2 — Evaluate & converge

1. **Cluster** what resonated into 2–3 meaningfully different directions.
2. **Stress-test** each against **user value** (painkiller or vitamin? who benefits, how much), **feasibility** (cost, hardest part), **differentiation** (would someone switch?). Full rubric: [refinement-criteria.md](./refinement-criteria.md).
3. **Surface hidden assumptions** per direction: what you're betting is true but haven't validated, what could kill it, what you're choosing to ignore and why that's fine for now. Most ideation fails here — don't skip it.
4. **Recommend one direction** and ask the user to pick. Their pick is a decision; yours is a recommendation.

## Phase 3 — Grill the chosen direction

Continue under the grill rules in SKILL.md: walk the remaining decision tree, maintain domain docs if in a codebase, restate, explicit yes, hand off to `/to-spec`.

Optionally summarise the result as a one-pager (show it in the conversation; save to `docs/ideas/<idea-name>.md` only if the user asks — `scripts/init-ideas-dir.sh` creates the folder):

```markdown
# [Idea Name]

## Problem Statement
[One-sentence "How might we" framing]

## Recommended Direction
[The chosen direction and why — 2-3 paragraphs max]

## Key Assumptions to Validate
- [ ] [Assumption — how to test it]

## MVP Scope
[The minimum version that tests the core assumption. What's in, what's out.]

## Not Doing (and Why)
- [Thing] — [reason]

## Open Questions
- [Question that needs answering before building]
```

The **Not Doing** list is the most valuable part: it makes the trade-offs explicit.

Sample sessions: [examples.md](./examples.md).

## Anti-patterns

- 20+ shallow variations instead of 5–8 considered ones
- Skipping "who is this for"
- Committing to a direction without surfacing assumptions
- Yes-machining weak ideas instead of pushing back with specifics
- No "Not Doing" list
- Ignoring the existing codebase when ideating inside a project
- Jumping to a one-pager without running phases 1 and 2
- Tone: be direct and slightly provocative — "that's interesting, but what if…" — without being exhausting
