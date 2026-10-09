# Project profile

Read by `implement`, `tdd`, `review`, `milestone-review` and `/work` instead of guessing commands. Keep it current; `/init` can refresh it.

## Stack

- Languages / frameworks: <e.g. Java 21 + Spring Boot 3, Angular 18>
- Package / build tools: <e.g. Gradle, npm>
- Kind of product: <web app | API service | CLI | library | game | desktop app | mixed>

## Design system

- `DESIGN.md`: <present | none yet — created by the first design phase>
- Theme/tokens: <path, e.g. src/styles/_tokens.scss, tailwind.config.ts>
- Component library: <e.g. Angular Material, shadcn/ui, none>
- Storybook / component catalogue: <URL/command | none>

## Commands

Run from the repo root unless noted. Leave a line as `-` when it doesn't exist.

| Purpose | Command |
|---|---|
| Install deps | |
| Typecheck / compile | |
| Lint | |
| Format check | |
| Unit tests (all) | |
| Single test file | `<cmd> <path>` |
| Integration / e2e tests | |
| Build | |
| Run locally | |

## How a user runs it

How a real user meets this product, used for user-level acceptance tests in `/milestone-review`:

- Entry point: <URL after "run locally" | CLI binary + typical invocation | game launch command | …>
- Test accounts / seed data: <how to get them>
- Tools for driving it as a user: <harness browser tool / Playwright / chrome-devtools MCP | real shell | xdotool + screenshots | manual only>

## Conventions

- Branch naming: <e.g. feature/<effort-slug>>
- Commit style: <e.g. Conventional Commits, `<effort>#NN` in the subject>
- Coding standards docs: <paths, e.g. CONTRIBUTING.md>
