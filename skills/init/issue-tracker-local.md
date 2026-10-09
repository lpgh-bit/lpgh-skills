# Issue tracker: Local Markdown

Tickets and specs for this repo live as markdown files under `.tickets/` (gitignored). Format, fields and operations are defined in the lpgh-skills ticket protocol (`references/tickets.md` in the plugin); this file records the repo-specific choices.

## Conventions

- One effort per directory: `.tickets/<effort-slug>/`
- Spec: `.tickets/<effort-slug>/spec.md`
- Milestones: `.tickets/<effort-slug>/milestones.md`
- Tickets: `.tickets/<effort-slug>/issues/<NN>-<slug>.md`, numbered from `01` per effort — never a combined file
- Wayfinder map: `.tickets/<effort-slug>/map.md`
- Triaged reports without an effort: `.tickets/inbox/issues/<NN>-<slug>.md`
- Header lines: `Status`, `Type`, `Risk`, `Milestone`, `Skills`, `Blocked by`, `Severity`, `Source`
- Comments append under `## Comments`; wayfinder answers under `## Answer`

## When a skill says "publish to the issue tracker"

Create the file under `.tickets/<effort-slug>/` (creating directories as needed). Tickets are only created through the `/to-tickets` procedure.

## When a skill says "fetch the relevant ticket"

Read the file. The user usually passes `<effort>#NN`, a path, or a number.

## Frontier

Scan `.tickets/<effort>/issues/`: `Status: ready`, every `Blocked by` ticket `done`. Lowest number wins.

## Committed?

`.tickets/` is in `.gitignore` — tickets are local working state, not part of the repo history.
