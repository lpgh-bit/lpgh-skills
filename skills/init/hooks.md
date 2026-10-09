# Optional hooks

Two hooks ship with lpgh-skills (from addyosmani/agent-skills). They are **never** active unless `/init` registers them for a project after the user agrees.

| Hook | What it does | Docs |
|---|---|---|
| sdd-cache | Caches `WebFetch` results for `source-driven-development` and revalidates them with the origin (ETag / Last-Modified) on every reuse | `hooks/SDD-CACHE.md` |
| simplify-ignore | Hides `/* simplify-ignore-start */ … /* simplify-ignore-end */` blocks from `code-simplification` | `hooks/SIMPLIFY-IGNORE.md` |

## simplify-ignore: real scope

Before offering it, tell the user what it really does:

- While registered, it filters **every** `Read` in the session — not only `code-simplification` runs.
- The `BLOCK_<hash>` placeholders sit **on disk** until the `Stop` hook expands them. Anything that runs mid-session — tests, builds, formatters, `git add`/commit — sees the placeholder version.
- Therefore **never register it in repos where `/work` runs tests or commits mid-session** (every lpgh-skills repo that uses `/work`) unless the user explicitly accepts that risk.

When it is registered anyway:

- Add `.claude/.simplify-ignore-cache/` to `.gitignore`.
- Suggest a staged-diff check that refuses commits containing placeholders, e.g. a pre-commit step `git diff --cached | grep -E 'BLOCK_[0-9a-f]{8}' && { echo "simplify-ignore placeholder staged"; exit 1; }` (via `setup-pre-commit` or the repo's hook tool).

## Registering in Claude Code

1. Copy the scripts from the plugin's `hooks/` folder (two levels up from this skill folder) into the project at `.claude/hooks/lpgh/` so the path survives plugin updates.
2. Merge the hook entries from the hook's `.md` doc into `.claude/settings.json` (shared) or `.claude/settings.local.json` (personal — ask which), replacing `${CLAUDE_PROJECT_DIR}/hooks/` with `${CLAUDE_PROJECT_DIR}/.claude/hooks/lpgh/`.
3. Never overwrite existing hook entries — append to the arrays.

## omp

omp does not run Claude Code `settings.json` hooks; its hooks are JS/TS factories in `.omp/hooks/pre/` and `.omp/hooks/post/`. Tell the user the hooks are Claude-Code-only for now and skip them in omp. The skills work without them.
