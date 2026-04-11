---
name: tagd-status
description: Use when the user asks for worktree status, says ~status, asks what changed, asks whether the current slice is ready to commit, or wants a concise status report aligned to TASKS.d/ or out/ in tagd-workspace.
---

# tagd-status

Report current `~status` and whether the slice looks ready to commit.

## Rules

* Inspect worktree state first.
* Prefer current conversation context when it clearly explains the slice.
* Otherwise align to the strongest task match.
* Check `out/` only if it clarifies the slice better than task context.
* For dirty worktrees, summarize staged, modified, and untracked files separately.
* State when alignment is inferred.
* Offer a commit message and full `git commit` command only if the slice is coherent and ready.
* Do not run a commit.

## Response Shape

* worktree state: clean or dirty
* checkpoint or current slice summary
* strongest intent/source match
* impact summary
* readiness judgment
* if ready: commit message and full `git commit` command
