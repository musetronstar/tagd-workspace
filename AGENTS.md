# tagd Agent Workspace

## Startup

On each new session:

1. Find the most recent markdown file in `TASKS.d/`.
2. Read it.
3. Treat it as the current assignment.
4. Before editing, summarize objective, scope, constraints, deliverables, and acceptance criteria.
5. If repo doctrine and task conflict, stop and report the conflict.

If the user explicitly provides the task to follow, use that instead.

## Meta Commands

* `~next` asks for the next meaningful TDD iteration from the current checkpoint.
* `~status` asks for worktree status and checkpoint readiness.
* `~/...` is a home-directory path prefix, not a meta-command.

## Workflow

* Work in reviewable, feature-sized batches.
* Prefer test first, then the smallest meaningful batch that completes one deliverable feature or contract.
* Build and test after each meaningful batch.
* Keep diffs scoped and reviewable.
* Intelligence over Efficiency:
    + Preserve existing style on untouched lines.
    + Do not reformat unrelated code.
    + Self-documenting code preferred, but REQUIRED: add concise intent comments for non-trivial or non-obvious logic.
    + Comments are part of the program narrative and system specification; if they diverge from the code, they are defects and must be corrected.
    + Do not remove comments unless they are incorrect, obsolete, or explicitly instructed to be removed.
    + Do not split naturally related changes when they belong to one tested deliverable.
    + If a line does not need to change, leave it alone.

