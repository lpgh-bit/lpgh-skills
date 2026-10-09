# Review reference

Read when a review raises one of these topics: oversized change, dependency changes, dead code, disagreements, or when you catch yourself rubber-stamping.

## Change sizing

```
~100 lines changed   → good, reviewable in one sitting
~300 lines changed   → acceptable if it's one logical change
~1000 lines changed  → too large; recommend splitting
```

One change = one self-contained modification with its tests that leaves the system working. A change that refactors *and* adds behaviour is two changes. Large is fine for whole-file deletions and automated refactors where only intent needs checking.

Splitting strategies: **stack** (sequential small changes), **by file group** (different reviewers), **horizontal** (shared code/stubs first, then consumers), **vertical** (smaller full-stack slices — preferred for features).

## Dependency discipline

Adding: does the existing stack already solve it? Size, maintenance, known vulnerabilities, license? Prefer the standard library — every dependency is a liability.

Upgrading is a behaviour change you didn't write:

1. Read the changelog, not the version number — semver is a promise, not a guarantee.
2. One dependency per change, so a break names its cause and the revert is clean.
3. Green suite before and after decides; thin coverage around the dependency is itself a finding.
4. Review the lockfile diff (transitive changes); never hand-edit it; commit it.

Supply-chain triage belongs to `security-and-hardening`.

## Dead code

After a refactor, list code that became unreachable or unused and **ask before deleting** it. Don't leave it, don't silently remove what you're unsure about.

## Commit messages

Format and authorship per [`../../references/commits.md`](../../references/commits.md): `+`/`-`/`~` prefix, short imperative standalone subject ("~ Fix session expiry check"), body with what and why, `Ticket: <effort>#NN`; user as author, no AI attribution (flag any `Co-Authored-By` agent trailer as a finding). Anti-patterns: "Fix bug", "Fix build", "Phase 1", "Moving code from A to B".

## Disagreements

1. Technical facts and data beat opinions.
2. The repo's style guide is the authority on style.
3. Design is judged on engineering principles, not preference.
4. Consistency with the codebase is acceptable if it doesn't degrade health.

Don't accept "I'll clean it up later" — require the cleanup or a fix ticket.

## Honesty

- No rubber stamps — "LGTM" without evidence helps nobody.
- Don't soften real bugs into "minor concerns". Quantify where possible ("adds ~50 ms per list item").
- Push back on approaches with clear problems; sycophancy is a review failure mode.
- Approve a change that definitely improves code health even if it isn't how you'd write it.
- Comment on the code, not the author. If the author has more context and disagrees, defer.

## Rationalizations

| Rationalization | Reality |
|---|---|
| "It works, that's good enough" | Unreadable, insecure or mis-structured working code is compounding debt. |
| "I wrote it, so I know it's correct" | Authors are blind to their own assumptions. |
| "AI-generated code is probably fine" | It needs more scrutiny — confident and plausible even when wrong. |
| "The tests pass, so it's good" | Tests don't catch architecture, security or readability problems. |
| "The refactor makes it cleaner" | If the reader holds the same number of concepts, it isn't cleaner. |
| "It's only a small addition to this file" | Judge the resulting structure, not the diff size. |
| "It's just a version bump" | A bump is behaviour change you didn't write. |

## Red flags

- Review that only checks whether tests pass.
- Findings without severity labels.
- Security-sensitive change with no security-focused pass.
- Bug fix without a regression test.
- Refactor that moves code around without reducing concepts.
- New conditionals scattered into unrelated paths; feature logic in shared modules.
- Bulk "bump deps" with no changelog review; hand-edited lockfile.
