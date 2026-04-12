# Process Lessons Addendum

Date: 2026-04-08

## Purpose

Condense lessons from the active and archived task/report set into reusable process guidance for future task generation, planning documents, and review reports.

## Lessons By Topic

### Task framing

* Strong task files defined boundaries, named exact files, and named the required verification command.
* Weaker task files mixed completed work, future design ideas, and current mission steps in one document, which made archive decisions harder.
* Ongoing programs should be written as recurring mission documents; single-deliverable tasks should be written as closeable units with explicit end conditions.

### Evidence discipline

* Completion decisions were reliable only after checking current code, referenced files, git history, and present-day test results together.
* Reports that described intended architecture aged quickly when they did not explicitly mark themselves as planning-only or historical.
* Documentation tasks should require explicit separation of observed facts, inferred conclusions, and proposed next steps.

### Verification

* Build and test commands must be workspace-real, not merely historically correct.
* Relative worktree layout matters: path assumptions in build files can invalidate otherwise-complete work.
* Deterministic tooling matters for review: generated reports and frequency tables should use explicit tie-breakers so rebuilds do not create noisy diffs.

### Reviewability

* Small-step, TDD-oriented prompts produced clearer commit histories and easier archive decisions.
* Documents that named non-goals and transport seams reduced accidental scope creep.
* Generated reports become more reusable when they conclude with impact statements and remaining tasks grouped by topic rather than by chronology.

## Source Document Addendum Targets

### `out/2026-03-26-claude-tagr-scanner-plan-5.md`

* Add process notes that the next iteration should begin with a concrete test seam, explicit build integration, and a distinction between feasibility findings and implementation claims.

### `out/2026-03-26-claude-tagr-scanner-prompt.md`

* Add review guidance that a task review should classify each subtask as complete, partial, blocked, or open, and should tie every classification to current verification evidence.

### `out/2026-03-17-GPT-5.5-NLP.md`

* Add a note that broad exploratory source collection should be turned into bounded canonical-source tasks before implementation begins.

## Recommended Addendums For Future Tasks

* Name `Read`, `Write`, and `Non-goals` separately.
* Name the exact test/build command required for completion.
* Mark reports as `planning-only`, `active reference`, `historical`, or `superseded`.
* Separate single-step tasks from ongoing programs.
* Require deterministic generators when generated outputs are checked into the repo.
