# Status & label vocabulary

The skills speak in the canonical statuses and types from the lpgh-skills ticket protocol. This file maps them to the strings this repo's tracker actually uses. Local markdown uses the canonical values verbatim in the `Status:` / `Type:` lines.

| Canonical | In our tracker | Meaning |
|---|---|---|
| `needs-triage` | `status:needs-triage` | Maintainer needs to evaluate |
| `needs-info` | `status:needs-info` | Waiting on the reporter |
| `ready` | `status:ready` | Fully specified, an agent may take it |
| `claimed` | `status:claimed` | An agent/session is working on it |
| `in-review` | `status:in-review` | Implemented, awaiting review |
| `done` | `status:done` (+ closed) | Finished |
| `needs-human` | `status:needs-human` | Needs a human (judgement, access, or agent failed twice) |
| `wontfix` | `status:wontfix` (+ closed) | Will not be actioned |
| type `fix` (bug) | `type:fix` | Something is broken |
| type `feature` (enhancement) | `type:feature` | New feature or improvement |

Edit the middle column if the tracker already uses other names, so skills apply existing labels instead of creating duplicates.
