---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
hide: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS - not the current workspace.

**Exception — `/work` before a spec exists:** when called from `/work` (or for an effort) and `.tickets/<effort>/spec.md` doesn't exist yet, write to `.tickets/<effort>/handoff.md` instead (create the folder; see `references/tickets.md`). `/work <effort>` then resumes at the spec step and reads it first. Say the path and the resume command in your reply.

**Handoff vs `/compact`:** `/compact` (built-in) stays in the same conversation and summarises earlier turns — use it only at intentional breaks between phases, never mid-phase, where the agent can lose its way. Handoff forks: a fresh session picks up from the file. Handoff forks; compact continues.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
