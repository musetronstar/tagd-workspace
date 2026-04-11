---
name: tagd-next-iteration
description: Use when the user asks "what's next", says ~next, asks for the next iteration after a clean checkpoint, or wants a concise approval-gated proposal for the next small TDD step in tagd-workspace.
---

# tagd-next-iteration

Use this skill when the user asks for the next small iteration in `tagd-workspace`, especially with `~next` after a commit or other clean checkpoint.

## Goal

Propose exactly one small next iteration that fits the active `TASKS.d/` context and the current checkpoint state.

Do not implement changes when using this skill unless the user separately approves with a follow-up such as `go`, `proceed`, or `yes`.

## Workflow

1. Inspect the current `tagd` worktree state.
2. Inspect the active task context in `TASKS.d/`.
3. Inspect nearby notes in `out/` only if they help clarify what was just completed.
4. Infer the smallest logical next iteration from:
   - the current checkpoint
   - recent commits if they clarify what was just completed
   - the established small-step TDD workflow in `tagd-workspace`
5. Respond with a concise proposal only.

## Proposal rules

The response should be brief and decision-ready.

Include:
- a one-line title naming the next iteration
- the focused test to add or run
- the minimal implementation seam to touch
- the expected output or behavior shape
- one explicit out-of-scope note

Do not:
- produce a long roadmap
- propose multiple unrelated next steps
- widen scope beyond one reviewable slice
- auto-run the implementation

## Style rules

- Preserve the user's workflow language: "next iteration", "what's next", "go", "proceed", "stop", "explain".
- Prefer `tagd` / TAGL source vocabulary already used in the codebase.
- Align with the local doctrine in `AGENTS.md`.
- Keep the proposal small, reviewable, and test-oriented.

## Response shape

Use this shape:

- `Next iteration: <short title>`
- one short line for the focused regression or check
- one short line for the minimal code seam
- one short line for the expected output or behavior
- one short line for what stays out of scope

Example:

- `Next iteration: _role:tagdb:error for failed put`
- Add one focused regression for a failed `put` path.
- Emit the attempted canonical TAGL operation, then `-- tagdb code=...`.
- Keep existing structured error output unchanged.
- Do not widen into replay tooling or shell lifecycle.
