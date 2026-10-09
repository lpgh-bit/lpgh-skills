---
name: init
description: Set up a repo for lpgh-skills — issue tracker and `.tickets/`, status vocabulary, domain docs, a project profile with the real build/test/run commands, the agent-skills block in AGENTS.md/CLAUDE.md, and optional hooks. Run once per repo before /work, or again to refresh.
disable-model-invocation: true
hide: true
---

# Init

Scaffold the per-repo configuration every lpgh-skills skill reads. Prompt-driven, not a script: **explore → present findings → confirm one section at a time → write.** Lead every section with a recommended answer the user can accept in a word; skip sections exploration already settled.

Output:

| File | Purpose |
|---|---|
| `docs/agents/issue-tracker.md` | which tracker, concrete commands |
| `docs/agents/triage-labels.md` | status/type vocabulary → tracker strings |
| `docs/agents/domain.md` | where `CONTEXT.md` / ADRs live, how to consume them |
| `docs/agents/project.md` | stack, commands, how a user runs the product |
| `.gitignore` entry | `.tickets/` |
| `## Agent skills` block | in `AGENTS.md` and/or `CLAUDE.md` |
| hooks (optional) | `.claude/settings*.json` + `.claude/hooks/lpgh/` |

Templates live next to this file. The ticket protocol they implement is [`../../references/tickets.md`](../../references/tickets.md).

## 1. Explore

Read what exists; don't assume.

- `git remote -v` — GitHub? GitLab? none?
- `AGENTS.md`, `CLAUDE.md` — present? an `## Agent skills` block already?
- `docs/agents/` — earlier output of this skill (then this is a **refresh**: show diffs, change only what the user approves).
- `.tickets/`, `.scratch/` (old mattpocock layout), `.gitignore`.
- `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `src/*/docs/adr/`.
- Monorepo signals: `pnpm-workspace.yaml`, `workspaces` in `package.json`, `settings.gradle(.kts)` with many includes, a populated `packages/*`.
- Stack and commands: build files (`package.json` scripts, `build.gradle(.kts)`, `pom.xml`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Makefile`, `justfile`), CI config (`.github/workflows`, `.gitlab-ci.yml`) — CI shows the commands that really run. `README`/`CONTRIBUTING` for run instructions and standards.
- What kind of product it is (web app, API, CLI, library, game, desktop) and how a user would reach it.
- Which harness you run in (Claude Code or omp) — decides the hooks section.

**Verify commands before proposing them**: run the cheap ones (`--version`, typecheck, a single quick test) and note which pass. Never record a command you only guessed — mark it `unverified`.

## 2. Sections — one question at a time

**A. Issue tracker.** Recommend **local markdown** (`.tickets/`, gitignored). Mention GitHub (`gh`) or GitLab (`glab`) when the remote points there and the user wants issues there. "Other" (Jira, Linear…) → ask for a one-paragraph workflow and write it as prose, mapped onto the operations in `tickets.md`.
- If `.scratch/` exists, offer to migrate its efforts into `.tickets/` (rename `ready-for-agent` → `ready`, `ready-for-human` → `needs-human`, add missing header fields with `-`).
- GitHub/GitLab templates carry a "PRs as a request surface" flag, default **off** — leave it off and don't raise it.

**B. Status vocabulary.** One question: keep the canonical statuses (recommended)? Only on a real tracker that already has other labels, collect overrides.

**C. Domain docs.** Default **single-context** (`CONTEXT.md` + `docs/adr/` at root) — write without asking. Offer **multi-context** (`CONTEXT-MAP.md` → per-context `CONTEXT.md`) only with monorepo signals. Don't create `CONTEXT.md`/ADRs now — `domain-docs` creates them lazily.

**D. Project profile.** Present the filled `project.md` draft: stack, every command (verified / unverified), product kind, **how a user runs it** and which tool can drive it as a user (harness browser tool, Playwright, chrome-devtools MCP, real shell, xdotool + screenshots, or manual only). Ask the user to correct gaps.

**E. Agent block.** Which file(s): if one of `AGENTS.md`/`CLAUDE.md` exists, edit that one; if both exist, edit both; if neither, recommend `AGENTS.md` (read by omp and most harnesses) plus a one-line `CLAUDE.md` containing `@AGENTS.md` for Claude Code — ask. Never duplicate an existing block; update it in place.

**F. Hooks (optional).** Read [hooks.md](hooks.md). In Claude Code ask whether to register `sdd-cache` and/or `simplify-ignore` (recommend: no, unless the user uses `source-driven-development` or `code-simplification` a lot). In omp say they're Claude-Code-only and skip.

## 3. Confirm

Show drafts of every file and the agent block. Let the user edit before anything is written.

## 4. Write

- `docs/agents/issue-tracker.md` from [issue-tracker-local.md](issue-tracker-local.md), [issue-tracker-github.md](issue-tracker-github.md) or [issue-tracker-gitlab.md](issue-tracker-gitlab.md).
- `docs/agents/triage-labels.md` from [triage-labels.md](triage-labels.md) (local: canonical values in the middle column).
- `docs/agents/domain.md` from [domain.md](domain.md).
- `docs/agents/project.md` from [project.md](project.md), filled in.
- Local tracker: create `.tickets/` and add `.tickets/` to `.gitignore` (create the file if needed; don't duplicate the line).
- The agent block:

```markdown
## Agent skills

This repo uses lpgh-skills. Start work with `/work` (Claude Code: `/lpgh-skills:work`, omp: `/skill:work`).

- **Issue tracker** — <one line>. See `docs/agents/issue-tracker.md`.
- **Statuses/labels** — <one line>. See `docs/agents/triage-labels.md`.
- **Domain docs** — <single-/multi-context>. See `docs/agents/domain.md`.
- **Project profile** — commands and how a user runs the product. See `docs/agents/project.md`.
```

- Hooks, if chosen, per [hooks.md](hooks.md).

Don't commit; tell the user which files changed.

## 5. Done

Summarise what was written and what's unverified. Next steps: `/work <idea>` to start, or `/grill` to sharpen an idea first. Re-run `/init` to switch trackers or refresh the profile; small tweaks are just edits to `docs/agents/*.md`.
