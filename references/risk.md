# Risk levels

How hard the process escalates is decided by **risk**, not by habit. Every ticket carries `Risk: low | medium | high | critical`; `/to-tickets` proposes it, the user confirms it at the ticket gate, `/work` also classifies requests that arrive without a ticket. **When in doubt, go one level up.**

## Rubric — the highest matching row wins

| Risk | Any one of these | Examples |
|---|---|---|
| `low` | cosmetic or copy change on an existing screen (a **new** screen or component is at least `medium` and goes through the design phase); internal tooling/scripts; trivially reversible; no user data touched | button label, CSS tweak, README, dev script |
| `medium` | normal feature or logic change following existing patterns; covered or coverable by tests; reversible by a revert | new list filter, new endpoint in an established module, validation rule |
| `high` | authentication/authorisation; payments or pricing logic; personal/user data; public API or contract change other teams/clients depend on; concurrency/caching/consistency; performance-critical path; unfamiliar or untested legacy code; framework/library APIs where version details matter | login flow, role checks, GDPR export, API v2 shape, cache invalidation |
| `critical` | irreversible or hard to undo: production data migration, deleting data, schema drops; cryptography, secrets, key handling; security-vulnerability fixes; moving money | drop column, re-encrypt data, fix an auth bypass, payout job |

## Process per level

| Step | low | medium | high | critical |
|---|---|---|---|---|
| Grill + spec before building (requests without a ticket) | spec may be skipped → one-ticket effort → build | spec optional | full `grill` + `to-spec` | full `grill` + `to-spec` |

At every level: `grill` whenever you aren't 100% sure what the user wants, and run the design phase for UI that `DESIGN.md` doesn't cover — risk never skips either.
| Skills auto-added to `Skills:` | — (`tdd` unless purely cosmetic) | `tdd` | `tdd`, `doubt-driven-development`, plus `security-and-hardening` / `source-driven-development` / `performance-optimization` where the trigger applies | as high |
| Who commits | the implementer | orchestrator, after review | orchestrator, after review | orchestrator, after **user approves the diff** |
| Ticket review | implementer self-review | **one fresh-context review subagent** (review CHECKLIST + SMELLS + acceptance on the ticket diff) | **three-axis `review`** + the **full hardening suite** ([`hardening.md`](hardening.md)) on the ticket diff | as high |
| Doubt-driven | — | — | part of the hardening suite, incl. the offer of a cross-model second opinion | as high |
| Extra gate | — | — | — | **stop before commit**: show diff + review results, wait for approval |

## Effort scale

Besides per-ticket risk, every spec carries `Scale: small | medium | large` (see [`hardening.md`](hardening.md)). `Scale: large` switches the full hardening suite on for every milestone review and `ship`, even when all tickets are `low`/`medium`.

## Why fresh context

Reviewing your own work in the context that produced it inherits its blind spots. From `medium` up, the reviewer is a subagent that sees only the ticket, spec, diff and checklists — never the implementer's reasoning.

## Nesting

Subagents generally can't spawn subagents (Claude Code forbids it). So the **orchestrator** (`/work`, or the main session running `/implement` by hand) runs every fresh-context review and doubt pass. The implementer only prepares: for `medium`+ it stops before committing, records its non-trivial decisions in the ticket, and returns.
