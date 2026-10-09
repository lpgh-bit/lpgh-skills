# Intent-first opening

Use when the ask is missing at least one of **who** it's for, **why** (why now), what **success** looks like, or the binding **constraint** — or when it is conventional ("build me a dashboard", "make it faster") and you can't unpack the convention without guessing. What people ask for and what they want differ; the cheapest moment to find the gap is before any plan, spec or code exists.

All grill rules still apply: one question at a time, recommended answer attached, facts looked up rather than asked.

## 1. Hypothesis with a confidence number

Before the first question, state your best read in one sentence plus an honest confidence (0–100%). Below ~70%, say on the same line what is still missing.

```
HYPOTHESIS: You want a way to answer "how are we doing?" in standup, and "dashboard" was the convention that came to mind.
CONFIDENCE: ~30% — missing: who it's for, what "metrics" means here, what success looks like
```

If you wrote a high number but can't predict the user's reaction to your next three questions, the number is wrong.

## 2. Ask, update, repeat

Ask one question with your recommended answer. After each answer, update the hypothesis and confidence visibly ("Updated read: not a team dashboard — a personal experiment tracker. ~60%, still missing: what done looks like."). Occasionally recommend in a direction you expect the user to push back on, to test for agreeableness.

If confidence isn't rising after three or more questions, you're asking the wrong questions — reframe.

## 3. Restate

When you can predict the next three reactions, write back the intent in the user's words:

```
Here's what I now think you want:

- Outcome:      <one line>
- User:         <one line — who benefits>
- Why now:      <one line — what changed>
- Success:      <one line — how we know it worked>
- Constraint:   <one line — the binding limit>
- Out of scope: <one line — what we're explicitly not doing>

Yes / no / refine?
```

"Out of scope" is mandatory. Gate on an explicit yes (see SKILL.md). Then continue grilling the plan, or — if the intent was the whole question — hand off to `/to-spec`.

## Example

```
User: build me a dashboard for our metrics

HYPOTHESIS: You want a way to answer "how are we doing?" in standup.
CONFIDENCE: ~30% — missing: who it's for, what "metrics" are, what success looks like

Q: Who's asking "how are we doing?" — you alone, the team in standup, or up the chain?
Recommended: the team in standup — "our" usually scopes that way. Execs would change the metrics a lot.

User: It's for me. I keep losing track of which experiments are running.

Updated read: a personal experiment tracker, not a team dashboard. ~60% — missing: what "track" means.

Q: Is the gap that you don't know which experiments exist, or that you can't see their results in one place?
Recommended: the second — results spread across tools.

User: The first. I don't have a list at all.
```

Two questions in, the real ask is "a list", not "a dashboard" — different artifact, different scope.

## Common rationalizations

| Rationalization | Reality |
|---|---|
| "The ask is clear enough" | If you can't write the desired outcome in one sentence now, it isn't. Write the hypothesis first. |
| "Questions waste their time" | A handful of targeted questions is cheap; building the wrong thing is not, and the user pays for it. |
| "I'll figure it out as I build" | Discovery during implementation is rework. |
| "They said 'whatever you think'" | Delegation, not decision. Re-ask as a choice of two concrete options. |
| "I'll give them a menu of options" | Options help when the user knows what they want. Before that, a menu widens the search; a question narrows it. (Divergent mode is the exception — when the user *asks* for variations.) |
| "Attaching my guess leads them" | Leading is the point. The risk is sycophancy; counter it by being visibly willing to be wrong. |
| "The user said yes, we're done" | A yes to a vague restate is hollow. Restate concretely and re-confirm. |
