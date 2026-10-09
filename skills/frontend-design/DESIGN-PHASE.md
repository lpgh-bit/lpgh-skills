# Design phase — working out the UI together with the user

Used by `/work` (design gate, after the spec) and whenever UI work arrives that the existing design doesn't cover. The user decides; you propose, show, and record.

## 0. When it runs, when it doesn't

| Situation | Do |
|---|---|
| `DESIGN.md` / the project's design system already covers the screens and components | No phase. Build by it. |
| New screen, new component type, new flow, or a redesign not covered | Run the phase. |
| Inside a ticket subagent (no user reachable) | **Never ask.** Follow `DESIGN.md` + the spec's `## UI Design`. Anything uncovered: take the closest existing pattern, record it under the ticket's `## Decisions`, and note an idea in `ideas.md` for the user. |

## 1. Inventory what exists (reuse first)

Before proposing anything, find the existing design: `DESIGN.md`; the design-system line in `docs/agents/project.md`; theme/token files (CSS variables, Tailwind config, SCSS variables, design tokens JSON); component libraries in the build (Angular Material, MUI, shadcn, PrimeNG, Vuetify…); Storybook; existing screens that the new UI will sit next to. Take screenshots of the neighbouring screens if the harness can.

An existing design system **wins**: new UI extends it, it doesn't start a parallel look. Only propose a new direction when there is none, or the user asked for a redesign.

## 2. Propose a direction

Following the main `SKILL.md` (subject grounding, the generic-defaults calibration list, restraint), write a compact proposal:

- **Subject, audience, primary job** of the screen(s) — confirm if you had to infer them.
- **Tokens** — palette (4–6 named hex values), type families + scale, spacing, radius, elevation. Reuse existing tokens; mark new ones as `new`.
- **Layout** — one-sentence concept per screen + ASCII wireframe; alignment; responsive behaviour.
- **Components** — which existing components are reused, which are new.
- **The one memorable thing** — where the boldness goes.
- **States** — empty, loading, error, success for each screen.

Present it and ask, grill-style, one decision at a time with your recommendation: direction OK? which open axis to change?

## 3. Show it for real when it matters

When the screen is new, the change is large, or the user is unsure between options: build **2–4 radically different variants** in the real app with the `prototype` skill's UI mode (`../prototype/UI.md` — same route, `?variant=`, floating switcher), using real data and the surrounding chrome. Screenshot each variant if the harness can and show them; tell the user the URL to flip through them.

The user picks one, or combines parts ("layout of B, palette of A"). Iterate until they say yes. Variants are throwaway: delete the prototype code once the decision is recorded.

## 4. Record

- **`DESIGN.md`** at the repo root (committed) — the design system. Create it from the template below if missing; otherwise **extend** it (never silently change existing tokens — a change to an existing token is its own decision with the user, and existing screens may need tickets).
- **Spec `## UI Design`** (in `.tickets/<effort>/spec.md`) — screen-specific decisions: chosen variant and why, ASCII wireframes, per-screen states, copy decisions, which `DESIGN.md` parts apply.
- Mark the spec's UI design `approved` (`UI design: approved` line in that section). That is the design gate.

## DESIGN.md template

```markdown
# Design

Source of truth for how this product looks and reads. Extend it; don't fork it. Read by every UI ticket.

## Principles
- <3–5 lines that make this product's UI specific>

## Tokens
| Token | Value | Use |
|---|---|---|
| color.bg | #… | |
| color.fg | #… | |
| color.accent | #… | the one place boldness goes |
| font.display / font.body | … | |
| type scale | … | |
| space / radius / elevation | … | |
Implemented in: <path to theme/token file>

## Components
| Component | Source (library or path) | Rules |
|---|---|---|

## Layout
<grid, breakpoints, alignment, density>

## Copy
<voice, sentence case, action names stay the same through a flow, error/empty-state style>

## Accessibility floor
Keyboard focus visible, contrast AA, reduced motion respected, responsive to mobile.
```
