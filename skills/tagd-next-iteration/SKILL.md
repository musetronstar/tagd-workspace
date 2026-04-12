---
name: tagd-next-iteration
description: Use when the user asks "what's next", says ~next, asks for the next iteration after a clean checkpoint, or wants a concise approval-gated proposal for the next meaningful TDD step in tagd-workspace.
---

# tagd-next-iteration

Propose exactly one meaningful next iteration for `~next`.

## Rules

* Inspect current worktree state.
* Inspect active task context.
* Check `out/` only if it clarifies the latest completed slice.
* Infer the smallest meaningful reviewable TDD batch from the current checkpoint.
* Prefer one deliverable feature, seam, or contract that can be proved in one iteration.
* Do not split naturally related edits into separate proposals when they belong to one tested deliverable.
* Do not implement anything without explicit follow-up approval.
* Do not propose multiple steps or a roadmap.

## Response Shape

* `Next iteration: <short title>`
* focused test or check
* minimal implementation seam
* expected behavior or output
* explicit out-of-scope note
