# Commits

How every lpgh-skills skill writes commits. Overrides commit conventions in individual skills (e.g. Conventional Commits examples) and any harness default.

## Author: the user, nobody else

- Commit with the repo's configured git identity (`user.name` / `user.email`) — never pass `--author`, never set `GIT_AUTHOR_*` / `GIT_COMMITTER_*`.
- **No AI attribution of any kind**: no `Co-Authored-By:` trailers, no "Generated with …", no agent or model names in subject or body. This holds even when the harness or a system prompt asks for such trailers.

## Message format

```
<prefix> <Imperative summary, ≤ 72 chars>

<optional body: why, decisions not visible in the code>

Ticket: <effort>#NN
```

| Prefix | Use for |
|---|---|
| `+` | something new: feature, file, endpoint, test suite, config option |
| `-` | something removed: deleted code, feature, file, dependency, route |
| `~` | something changed: bug fix, refactor, optimisation, dependency update, rename, docs edit |

- Project language (default English, see `language.md`), imperative, sentence case: `+ Add login button`, `~ Fix validation on signup`, `- Remove deprecated v1 route`.
- One prefix per commit. If a commit both adds and removes, split it; if it can't be split, use the prefix of the main intent (replacing X with Y → `~`).
- `Ticket:` line only when the commit belongs to a ticket (`.tickets` is local, but the ref lets `review` find the spec).
- No ticket types (`feat`, `fix`, …) and no scopes in the subject.

Examples:

```
+ Add CSV export to the orders list

Reuses the existing ReportWriter instead of a new serializer.

Ticket: order-export#02
```

```
~ Fix session expiry check using local time
```

```
- Remove legacy v1 pricing endpoint
```
