# tagd Agent Workspace

## Startup

On each new session:

1. Find the most recent markdown file in `TASKS.d/`.
2. Read that file.
3. Use `AGENTS.md` as standing workflow doctrine.
4. Treat the selected task file as the current assignment.
5. Before editing, summarize objective, scope, constraints, deliverables, and acceptance criteria.
6. If doctrine and task conflict, stop and report the conflict.

If the user explicitly provides the task to follow, use that instead.

## Meta Commands

* `~next` asks for the next small TDD iteration from the current checkpoint.
* `~status` asks for worktree status and checkpoint readiness.
* `~/...` is a home-directory path prefix, not a meta-command.

## Workflow

* Work in small, reviewable steps.
* Prefer test first, then the smallest code change.
* Build and test after each change.
* Preserve existing style on untouched lines.
* Do not reformat unrelated code.
* Do not alter comments or remove commented-out blocks unless asked.
* Keep diffs minimal.
* If a line does not need to change, leave it alone.
