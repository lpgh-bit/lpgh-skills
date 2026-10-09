# Risk levels

How hard the process escalates is decided by **risk**, not by habit. Every ticket carries `Risk: low | medium | high | critical`; `/to-tickets` proposes it, the user confirms it at the ticket gate, `/work` also classifies requests that arrive without a ticket. **When in doubt, go one level up.**

## Rubric — the highest matching row wins

| Risk | Any one of these | Examples |
|---|---|---|
| `low` | cosmetic or copy change; isolated UI with no logic; internal tooling/scripts; trivially reversible; no user data touched | button label, CSS tweak, README, dev script |
| `medium` | normal feature or logic change following existing patterns; covered or coverable by tests; reversible by a revert | new list filter, new endpoint in an established module, validation rule |
| `high` | authentication/authorisation; payments or pricing logic; personal/user data; public API or contract change other teams/clients depend on; concurrency/caching/consistency; performance-critical path; unfamiliar or untested legacy code; framework/library APIs where version details matter | login flow, role checks, GDPR export, API v2 shape, cache invalidation |
| `critical` | irreversible or hard to undo: production data migration, deleting data, schema drops; cryptography, secrets, key handling; security-vulnerability fixes; moving money | drop column, re-encrypt data, fix an auth bypass, payout job |

## Process per level

| Step | low | medium | high | critical |
|---|---|---|---|---|
| Grill + spec before building (requests without a ticket) | may skip → `implement` directly | short `grill`, spec optional | full `grill` + `to-spec` | full `grill` + `to-spec` |
| Skills auto-added to `Skills:` | — (`tdd` unless purely cosmetic) | `tdd` | `tdd`, `doubt-driven-development`, plus `security-and-hardening` / `source-driven-development` / `performance-optimization` where the trigger applies | as high |
| Who commits | the implementer | orchestrator, after review | orchestrator, after review | orchestrator, after **user approves the diff** |
| Ticket review | implementer self-review | **one fresh-context review subagent** (review CHECKLIST + SMELLS + acceptance on the ticket diff) | **three-axis `review`** (Standards, Spec, Quality — each a fresh subagent) | three-axis `review` + `security-auditor` |
| Doubt-driven | — | — | fresh-context doubt review of each non-trivial decision the implementer recorded | as high + offer a cross-model second opinion |
| Extra gate | — | — | — | **stop before commit**: show diff + review results, wait for approval |

## Why fresh context

Reviewing your own work in the context that produced it inherits its blind spots. From `medium` up, the reviewer is a subagent that sees only the ticket, spec, diff and checklists — never the implementer's reasoning.

## Nesting

Subagents generally can't spawn subagents (Claude Code forbids it). So the **orchestrator** (`/work`, or the main session running `/implement` by hand) runs every fresh-context review and doubt pass. The implementer only prepares: for `medium`+ it stops before committing, records its non-trivial decisions in the ticket, and returns.
