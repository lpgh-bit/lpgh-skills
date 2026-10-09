# Optional hooks

Two hooks ship with lpgh-skills (from addyosmani/agent-skills). They are **never** active unless `/init` registers them for a project after the user agrees.

| Hook | What it does | Docs |
|---|---|---|
| sdd-cache | Caches `WebFetch` results for `source-driven-development` and revalidates them with the origin (ETag / Last-Modified) on every reuse | `hooks/SDD-CACHE.md` |
| simplify-ignore | Hides `/* simplify-ignore-start */ … /* simplify-ignore-end */` blocks from `code-simplification` | `hooks/SIMPLIFY-IGNORE.md` |

## Registering in Claude Code

1. Copy the scripts from the plugin's `hooks/` folder (two levels up from this skill folder) into the project at `.claude/hooks/lpgh/` so the path survives plugin updates.
2. Merge the hook entries from the hook's `.md` doc into `.claude/settings.json` (shared) or `.claude/settings.local.json` (personal — ask which), replacing `${CLAUDE_PROJECT_DIR}/hooks/` with `${CLAUDE_PROJECT_DIR}/.claude/hooks/lpgh/`.
3. Never overwrite existing hook entries — append to the arrays.

## omp

omp does not run Claude Code `settings.json` hooks; its hooks are JS/TS factories in `.omp/hooks/pre/` and `.omp/hooks/post/`. Tell the user the hooks are Claude-Code-only for now and skip them in omp. The skills work without them.
