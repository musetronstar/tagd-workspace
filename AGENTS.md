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

Defined in the `skills` directory:

* `~next` asks for the next meaningful TDD iteration from the current checkpoint.
  mapping: `skills/tagd-next-iteration/`
* `~status` asks for worktree status and checkpoint readiness.
  mapping: `skills/tagd-status`

## Workflow

* Work in reviewable, feature-sized batches.
* Design tests first as the contract specification — written before implementation begins, not after.
* Comments: **self-documenting code preferred**, but REQUIRED: add concise **intent comments** (**why** not "what") for
  + non-trivial or non-obvious logic
  * important/impactful to overall system design
  + seams designed to STL protocols warrant a concise erudite comment
* Build the smallest meaningful batch that fulfills the contract, then verify tests pass.
* Keep diffs scoped and reviewable.
* Intelligence over Efficiency:
    + Preserve existing style on untouched lines.
    + Do not reformat unrelated code.
    + Comments are part of the program narrative and system specification; if they diverge from the code, they are defects and must be corrected.
    + Do not remove comments unless they are incorrect, obsolete, or explicitly instructed to be removed.
    + Do not split naturally related changes when they belong to one tested deliverable.
    + If a line does not need to change, leave it alone.
