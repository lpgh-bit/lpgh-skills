# Documentation beyond the glossary

Document the *why*: context, constraints and trade-offs. Code shows what was built; docs explain why it was built this way and what was rejected. Don't document obvious code, don't restate what code says, don't write docs for throwaway prototypes.

Examples below use TypeScript syntax for illustration — apply the same ideas in the project's language and its doc-comment convention.

## Code comments

Comment the *why*, not the *what*:

```ts
// BAD: restates the code
// Increment counter by 1
counter += 1;

// GOOD: explains non-obvious intent
// Sliding window: reset at the window boundary, not on a fixed schedule,
// so bursts at window edges can't double the rate.
if (now - windowStart > WINDOW_SIZE_MS) {
  counter = 0;
  windowStart = now;
}
```

- Don't comment self-explanatory code.
- Don't leave `TODO: add error handling` — just add it. A TODO that must stay names an owner or a ticket.
- Don't leave commented-out code — delete it; git has history.
- **Do document known gotchas** where they bite, and point at the ADR:

```ts
/**
 * Must be called before the first render. Called after hydration it causes
 * a flash of unstyled content, because the theme context isn't available
 * during SSR. See ADR-0003.
 */
export function initializeTheme(theme: Theme): void { /* … */ }
```

Use domain terms exactly as `CONTEXT.md` defines them in names and comments.

## API documentation

For public interfaces (library exports, REST/GraphQL/RPC endpoints, CLI commands):

- Document inline with the types where the language supports it: purpose, parameters, return value, errors raised and when, a short example.
- For HTTP APIs keep a machine-readable contract (OpenAPI, GraphQL schema, protobuf) next to the code, including error responses — not only the happy path.
- Write the doc as part of the change that adds or changes the API. The doc is the first test of the design: if it's hard to explain, the interface is probably wrong.

## README

Every project's README covers, briefly:

- **What it is** — one paragraph.
- **Quick start** — clone, install, configure, run. Take the real commands from `docs/agents/project.md` (or the build files); don't invent them.
- **Commands** — test, typecheck, lint, build, run.
- **Architecture** — a short overview of the structure; link `CONTEXT.md` and the ADRs rather than repeating them.
- **Contributing** — standards, review/PR process.

## Changelog

For shipped, user-visible changes keep a changelog grouped by version and date under **Added / Changed / Fixed / Removed**, one line per change with its ticket or PR reference. Say what changed for the user, not what files moved.

## Documentation for agents

- **Rules files** (`CLAUDE.md`, `AGENTS.md`) — project conventions, so agents follow them. Keep them current.
- **`CONTEXT.md`** — the vocabulary; prevents synonym drift.
- **ADRs** — why past decisions were made; prevents re-deciding.
- **Specs** (`.tickets/<effort>/spec.md`) — keep in sync with what's being built.
- **Inline gotchas** — prevent agents falling into known traps.

## Common rationalizations

| Rationalization | Reality |
|---|---|
| "The code is self-documenting" | Code shows what. It doesn't show why, what was rejected, or which constraints apply. |
| "We'll document when the API stabilizes" | APIs stabilize faster when documented — the doc is the first test of the design. |
| "Nobody reads docs" | Agents do. Future engineers do. You in three months do. |
| "ADRs are overhead" | A one-paragraph ADR prevents the same debate six months later. |
| "Comments get outdated" | Comments on *why* are stable. Comments on *what* rot — so only write the former. |

## Red flags

- Hard-to-reverse decisions with no written rationale
- Public APIs with no documentation or types
- A README that doesn't say how to run the project
- Commented-out code; TODOs that have sat for weeks
- Comments that restate the code
- Rules files that contradict what the code actually does

## Verification

- [ ] Every decision meeting the three ADR criteria has an ADR
- [ ] README covers what, quick start, commands, architecture
- [ ] Public APIs document parameters, returns and errors
- [ ] Known gotchas are documented where they bite
- [ ] No commented-out code remains
- [ ] Rules files are current
