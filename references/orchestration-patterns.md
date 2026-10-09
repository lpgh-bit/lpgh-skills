# Orchestration Patterns

Reference catalog of agent orchestration patterns this repo endorses, plus anti-patterns to avoid. Read this before adding a new slash command that coordinates multiple personas, or before introducing a new persona that "wraps" existing ones.

The governing rule: **the user, or the main session running a slash command with the user's gates, is the orchestrator. Personas do not invoke other personas, and subagents never spawn subagents.** Skills are mandatory hops inside a persona's workflow.

---

## Endorsed patterns

### 1. Direct invocation (no orchestration)

Single persona, single perspective, single artifact. The default and the cheapest option.

```
user → code-reviewer → report → user
```

**Use when:** the work is one perspective on one artifact and you can describe it in one sentence.

**Examples:**
- "Review this PR" → `code-reviewer`
- "Find security issues in `auth.ts`" → `security-auditor`
- "What tests are missing for the checkout flow?" → `test-engineer`

**Cost:** one round trip. The baseline you should always compare orchestrated patterns against.

---

### 2. Single-persona slash command

A slash command that wraps one persona with the project's skills. Saves the user from re-explaining the workflow every time.

```
/implement → one fresh subagent (with tdd + the ticket's skills) → report
```

**Use when:** the same single-persona invocation happens repeatedly with the same setup.

**Examples in this repo:** `/implement`, `tdd`, `code-simplification`.

**Cost:** same as direct invocation. The slash command is just a saved prompt.

**Anti-signal:** if the slash command's body is mostly "decide which persona to call," delete it and let the user call the persona directly.

---

### 3. Parallel fan-out with merge

Multiple personas operate on the same input concurrently, each producing an independent report. A merge step (in the main agent's context) synthesizes them into a single decision.

```
                    ┌─→ code-reviewer    ─┐
/ship → fan out  ───┼─→ security-auditor ─┤→ merge → go/no-go + rollback
                    └─→ test-engineer    ─┘
```

**Use when:**
- The sub-tasks are genuinely independent (no shared mutable state, no ordering dependency)
- Each sub-agent benefits from its own context window
- The merge step is small enough to stay in the main context
- Wall-clock latency matters

**Examples in this repo:**
- `/review` — three axes (Standards, Spec, Quality) as parallel subagents; aggregated side by side, not reranked.
- `/milestone-review` — axes A–F as parallel subagents (`test-engineer`, `security-auditor`, `web-performance-auditor`, …), G (user-level test) run by the main session, findings merged into fix tickets.
- `/ship` — `code-reviewer` + `security-auditor` + `test-engineer` in one turn, merged into a GO/NO-GO with a rollback plan.
- The hardening suite (`references/hardening.md`) — all 12 checks as fresh-context subagents, each dispatched by the main session.

**Cost:** N parallel sub-agent contexts + one merge turn. Higher than direct invocation, but faster wall-clock and produces better reports because each sub-agent stays focused on its single perspective.

**Validation checklist before adopting this pattern:**
- [ ] Can I run all sub-agents at the same time without ordering issues?
- [ ] Does each persona produce a different *kind* of finding, not just the same finding from a different angle?
- [ ] Will the merge step fit in the main agent's remaining context?
- [ ] Is the user's wait time long enough that parallelism is actually noticeable?

If any answer is "no," fall back to direct invocation or a single-persona command.

---

### 4. Gated main-session orchestrator (`/work`)

A user-invoked command whose **main session** walks the lifecycle and dispatches each building or reviewing step to a fresh subagent — stopping at user gates where judgment matters. The user can also run every step by hand; `/work` just saves the bookkeeping.

```
/work (main session)
  grill → to-spec ─[GATE 1: spec]→ design ─[GATE: UI design]→ to-tickets ─[GATE 2: tickets]→
  per ticket: fresh implementer subagent → fresh reviewer subagents (by risk) → commit
  per milestone: milestone-review fan-out ─[GATE 3: milestone]→ … → ship (GO/NO-GO, no deploy without OK)
```

**Rules that make it safe:**
- **Gates are hard stops.** Spec, UI design, tickets and every milestone wait for the user's approval; push/PR/merge/deploy only on an explicit OK.
- **Subagents get file paths, not paraphrases.** A ticket brief points at `.tickets/<effort>/issues/NN-*.md`, `spec.md`, `docs/agents/project.md` and the checklists; the subagent reads them itself. The orchestrator never summarises the spec into the prompt.
- **No nesting.** Only the main session dispatches. Implementers, reviewers and agents from `agents/` never spawn further subagents; anything that must be fresh-context is dispatched by the main session.
- **Lean orchestrator.** The main session reads ≤ 150-word reports and ticket state, never the implementation details.

**Use when:** the workflow has dependencies (each step needs the previous step's output) and human judgment between steps adds value.

**Examples in this repo:** `/work` over `to-spec` → `to-tickets` → `implement` → `review` → `milestone-review` → `ship`; each step also runs standalone.

**Cost:** one fresh subagent per ticket and per review axis; the orchestration layer costs a small main-session context because it holds state and file paths, not content.

**Why it isn't the anti-pattern:** the failure modes of an LLM lifecycle orchestrator — losing nuance through hand-off summaries, skipping human checkpoints, paraphrasing turns — are designed out: artifacts on disk are the hand-off, gates stay with the user, and there is exactly one orchestration level.

---

### 5. Research isolation (context preservation)

When a task requires reading large amounts of material that shouldn't pollute the main context, spawn a research sub-agent that returns only a digest.

```
main agent → research sub-agent (reads 50 files) → digest → main agent continues
```

**Use when:**
- The main session needs to stay focused on a downstream task
- The investigation result is much smaller than the input it consumes
- The decision quality benefits from the main agent having room to think after

**Examples:** "Find every call site of this deprecated API across the monorepo," "Summarize what these 30 ADRs say about caching."

**Cost:** one isolated sub-agent context. Worth it any time the alternative is loading hundreds of files into the main context.

**On Claude Code, use the built-in `Explore` subagent** rather than defining a custom research persona. `Explore` runs on Haiku, is denied write/edit tools, and is purpose-built for this pattern. Define a custom research subagent only when `Explore` doesn't fit (e.g. you need a domain-specific system prompt the model wouldn't infer).

---

## Claude Code compatibility

This catalog is harness-agnostic, but most readers will run it on Claude Code. Here's how each pattern maps onto Claude Code's primitives — and where the platform enforces our rules for us.

### Where personas live

Plugin subagents go in `agents/` at the plugin root. This repo is a plugin (`.claude-plugin/plugin.json`), so `agents/code-reviewer.md`, `agents/security-auditor.md`, and `agents/test-engineer.md` are auto-discovered when the plugin is enabled. No path configuration needed.

### Subagents vs. Agent Teams

Claude Code has two parallelism primitives. Pattern 3 (parallel fan-out with merge) maps to **subagents**. If you need teammates that talk to each other, use **Agent Teams** instead.

| | Subagents | Agent Teams |
|--|-----------|-------------|
| Coordination | Main agent fans out, sub-agents only report back | Teammates message each other, share a task list |
| Context | Own context window per subagent | Own context window per teammate |
| When to use | Independent tasks producing reports | Collaborative work needing discussion |
| Status | Stable | Experimental — requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` |
| Cost | Lower | Higher — each teammate is a separate Claude instance |

**The personas in this repo work in both modes.** When spawned as subagents (e.g. by `/ship`, `/milestone-review` or the hardening suite), they report findings to the main session. When spawned as teammates (`Spawn a teammate using the security-auditor agent type…`), they can challenge each other's findings directly. The persona definition is the same; only the spawning context changes.

One subtlety: the `skills` and `mcpServers` frontmatter fields in a persona are honored when it runs as a subagent but **ignored when it runs as a teammate** — teammates load skills and MCP servers from your project and user settings, the same as a regular session. If a persona depends on a specific skill or MCP server being loaded, configure it at the session level so it's available in both modes.

### Platform-enforced rules

Two rules in this catalog aren't just convention — Claude Code enforces them:

- **"Subagents cannot spawn other subagents"** (verbatim from the docs). Anti-pattern B (persona-calls-persona) and Anti-pattern D (deep persona trees) cannot exist on Claude Code by construction.
- **"No nested teams"** — teammates cannot spawn their own teams. Same anti-patterns blocked at the team level.

This means you can adopt the patterns in this catalog without worrying about contributors accidentally building the anti-patterns. They'll just fail to load.

### Built-in subagents to know about

Before defining a custom subagent, check whether one of these covers the role:

| Built-in | Purpose |
|----------|---------|
| `Explore` | Read-only codebase search and analysis. Use this for Pattern 5 (research isolation). |
| `Plan` | Read-only research during plan mode. |
| `general-purpose` | Multi-step tasks needing both exploration and modification. |

Don't redefine these. Layer your specialist personas (code-reviewer, security-auditor, test-engineer) on top of them.

### Frontmatter restrictions for plugin agents

Plugin subagents do **not** support the `hooks`, `mcpServers`, or `permissionMode` frontmatter fields — these are silently ignored. If a future persona needs any of those, the user must copy the file into `.claude/agents/` or `~/.claude/agents/` instead.

The fields that DO work in plugin agents are: `name`, `description`, `tools`, `disallowedTools`, `model`, `maxTurns`, `skills`, `memory`, `background`, `effort`, `isolation`, `color`, `initialPrompt`. Use `model` per-persona if you want to optimize cost (e.g. Haiku for `test-engineer` coverage scans, Sonnet for `code-reviewer`, Opus for `security-auditor`).

### Spawning multiple subagents in parallel

In Claude Code, parallel fan-out (Pattern 3) requires issuing **multiple Agent tool calls in a single assistant turn**. Sequential turns serialize execution. `/review`, `/milestone-review`, `/ship` and the hardening suite call this out explicitly. Any new orchestrator command should do the same.

---

## Worked example: Agent Teams for competing-hypothesis debugging

This example shows when to reach for **Agent Teams** instead of `/ship`'s subagent fan-out. The two patterns look similar from a distance — both spawn the same three personas — but the value comes from a different place.

### The scenario

> *Checkout occasionally hangs for ~30 seconds before completing. It happens roughly once every 50 sessions. No errors in logs. Started after last week's release.*

Plausible root causes (mutually exclusive, all fit the symptoms):

1. A race condition in the new payment-confirmation flow
2. An auth check that occasionally falls through to a slow synchronous network call
3. A missing index on a query that scales with cart size
4. A flaky third-party API where the SDK retries silently before timing out

A single agent will pick the first plausible theory and stop investigating. A `/ship`-style subagent fan-out would have each persona report independently — but their reports never meet, so nothing rules out the wrong theories.

This is exactly the case the Agent Teams docs describe: *"With multiple independent investigators actively trying to disprove each other, the theory that survives is much more likely to be the actual root cause."*

### Why this is *not* a `/ship` job

| | `/ship` (subagents) | Agent Teams |
|--|--------------------|-------------|
| Sub-agents see | The same diff, different lenses | A shared task list, each other's messages |
| Output | Three independent reports → one merge | Adversarial debate → consensus root cause |
| Right when | You want a verdict on a known artifact | You want to *find* the artifact among hypotheses |

`/ship` is a verdict; Agent Teams is an investigation.

### Setup (one-time, per-environment)

Agent Teams is experimental. In `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Requires Claude Code v2.1.32 or later. The personas in this repo are picked up automatically — no team-config files to author by hand.

### The trigger prompt

Type into the lead session, in natural language:

```
Users report checkout hangs for ~30 seconds intermittently after last
week's release. No errors in logs.

Create an agent team to debug this with competing hypotheses. Spawn
three teammates using the existing agent types:

  - code-reviewer  — investigate race conditions and blocking calls
                     in the checkout code path
  - security-auditor — investigate auth checks, session handling,
                       and any synchronous network calls added recently
  - test-engineer  — propose tests that would distinguish between the
                     hypotheses and check coverage gaps in checkout

Have them message each other directly to challenge each other's
theories. Update findings as consensus emerges. Only converge when
two teammates agree they can disprove the others'.
```

The lead spawns three teammates referencing the existing persona names. The persona body is **appended** to each teammate's system prompt as additional instructions (on top of the team-coordination instructions the lead installs); the trigger prompt above becomes their task.

### What happens

1. Each teammate runs in its own context window, exploring the codebase from its own lens.
2. Teammates use `message` to send findings to each other directly. The lead doesn't have to relay.
3. The shared task list shows who's investigating what — visible at any time with `Ctrl+T` (in-process mode) or in a tmux pane (split mode).
4. When `code-reviewer` finds a `Promise.all` that should be sequential, it messages `security-auditor` to confirm the auth call isn't part of the race. `security-auditor` checks and replies — either confirming the race is the real issue or producing counter-evidence.
5. `test-engineer` proposes a focused integration test for whichever theory is winning, which the team uses to verify before declaring consensus.
6. The lead synthesizes the converged finding and presents it to you.

You can interrupt at any teammate by cycling with `Shift+Down` and typing — useful for redirecting an investigator who's gone down a wrong path.

### When to clean up

When the investigation lands on a root cause, tell the lead:

```
Clean up the team
```

Always cleanup through the lead, not a teammate (per the docs: teammates lack full team context for cleanup).

### Cost expectation

Three Sonnet teammates running for ~10–15 minutes of investigation costs noticeably more than the same three personas spawned as subagents by `/ship`. The justification is *quality of conclusion* — for production debugging where the wrong fix is expensive, the extra tokens are a bargain. For a routine PR review, stick with `/ship`.

### Anti-pattern in this scenario

Do **not** rebuild this as a `/debug` slash command that fans out subagents. Subagents can't message each other — you'd lose the adversarial debate that makes the pattern work. If a workflow keeps coming up, document the trigger prompt above as a snippet rather than wrapping it in a slash command that misuses subagents.

### When *not* to use Agent Teams

- Production-bound verdict on a known diff → use `/ship` (subagents).
- One specialist perspective on one artifact → direct persona invocation.
- Sequential lifecycle (spec → tickets → build) → `/work` or the user running the steps (Pattern 4).
- Read-heavy research with a small digest → built-in `Explore` subagent.

Reach for Agent Teams only when teammates **need** to challenge each other to produce the right answer.

---

## Anti-patterns

### A. Router persona ("meta-orchestrator")

A persona whose job is to decide which other persona to call.

```
/dispatch → router-persona → "this needs a review" → code-reviewer → router (paraphrases) → user
```

**Why it fails:**
- Pure routing layer with no domain value
- Adds two paraphrasing hops → information loss + roughly 2× token cost
- The user already knew they wanted a review; they could have called `/review` directly
- Replicates the work that slash commands and intent mapping in `AGENTS.md` already do

**What to do instead:** add or refine slash commands. Document intent → command mapping in `AGENTS.md`. (`/work`'s routing table is different: the main session routes and then *runs* the skill itself or dispatches with file paths — there is no router persona in between.)

---

### B. Persona that calls another persona

A `code-reviewer` that internally invokes `security-auditor` when it sees auth code.

**Why it fails:**
- Personas were designed to produce a single perspective; chaining them defeats that
- The summary the calling persona passes loses context the called persona needs
- Failure modes multiply (which persona's output format wins? whose rules apply?)
- Hides cost from the user

**What to do instead:** have the calling persona *recommend* a follow-up audit in its report. The user or a slash command runs the second pass.

---

### C. Orchestrator that skips gates, paraphrases context, or nests subagents

An agent that runs `to-spec` → `to-tickets` → `implement` … on the user's behalf **without stopping at the gates**, hands each step a summary it wrote instead of the files, or runs as a subagent that spawns its own subagents.

**Why it fails:**
- Skipped gates lose the human checkpoints that catch wrong-direction work
- Paraphrased hand-offs drift over a long pipeline and double token cost
- Nested orchestration can't exist on Claude Code (subagents can't spawn subagents) and, where it can, multiplies summarisation loss
- Removes user agency at exactly the points where judgment matters most

**What to do instead:** Pattern 4 — orchestrate from the main session, stop at every gate, pass file paths, keep depth at one.

---

### D. Deep persona trees

`/ship` calls a `pre-ship-coordinator` that calls a `quality-coordinator` that calls `code-reviewer`.

**Why it fails:**
- Each layer adds latency and tokens with no decision value
- Debugging becomes a multi-level investigation
- The leaf personas lose context to multiple summarization steps

**What to do instead:** keep the orchestration depth at most 1 (main session → subagents/personas). The merge happens in the main session.

---

## Decision flow

When considering a new orchestrated workflow, walk this flow:

```
Is the work one perspective on one artifact?
├── Yes → Direct invocation. Stop.
└── No  → Will the same composition repeat?
         ├── No  → Direct invocation, ad hoc. Stop.
         └── Yes → Are sub-tasks independent?
                  ├── No  → Gated main-session orchestrator or the user running the steps (Pattern 4).
                  └── Yes → Parallel fan-out with merge (Pattern 3).
                           Validate against the checklist above.
                           If any check fails → fall back to single-persona command (Pattern 2).
```

---

## When to add a new pattern to this catalog

Add a new entry only after:

1. You've used the pattern at least twice in real work
2. You can name a concrete artifact in this repo that demonstrates it
3. You can explain why an existing pattern wouldn't have worked
4. You can describe its anti-pattern shadow (what people will mistakenly build instead)

Premature catalog entries become aspirational documentation that no one follows.
