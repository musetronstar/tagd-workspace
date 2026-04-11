---
name: tagd-status
description: Use when the user asks for worktree status, says ~status, asks what changed, asks whether the current slice is ready to commit, or wants a concise status report aligned to TASKS.d/ or out/ in tagd-workspace.
---

# tagd-status

Use this skill when the user asks for the current status of work in `tagd-workspace`, especially via `~status`.

## Goal

Report the current worktree state, align the current slice to the strongest available task intent, and say whether the current slice looks ready to commit.

Do not run a commit when using this skill. If the current slice looks ready, offer a proposed commit message and echo the full `git commit` command only.

## Workflow

1. Inspect the current `tagd` worktree state first.
2. Prefer the current conversation context for the active slice when it clearly explains the current worktree.
3. If the worktree is clean:
   - state that it is clean
   - summarize the most recent completed checkpoint from the latest relevant commit subject
   - mention the strongest matching task or report file if that adds clarity
4. If the worktree is dirty:
   - summarize staged, modified, and untracked files separately
   - inspect only the changed files needed to understand the current slice
   - if the current conversation context already explains the slice with high confidence, use it and skip task/report file analysis
   - otherwise try to align the changes to the most relevant directive in `TASKS.d/`
   - if no strong task match exists, check `out/`
   - if no strong document match exists, analyze the changes directly and state what they appear to represent
5. Assess whether the dirty worktree looks like one coherent task slice.
6. If the slice looks ready to checkpoint:
   - propose a commit message using the local convention `<agent>: <concise task slice description>`
   - echo the full `git commit` command
7. If the slice does not look ready:
   - say why not
   - identify the smallest missing piece

## Alignment rules

- Prefer the current conversation context when it clearly explains the active slice.
- Prefer explicit task language in `TASKS.d/` over inferred similarity.
- Use `out/` only when it better explains the current slice than `TASKS.d/`.
- If using the current conversation context or most recent task context gives the strongest match, say so.
- Do not overstate certainty. If the mapping is weak, say that it is inferred.

## Readiness rules

Offer a commit command only when the current dirty worktree appears:
- coherent
- aligned to one intent
- not obviously half-finished
- free of unrelated mixed changes, as far as the current inspection shows

If those conditions are not met, do not offer a commit command.

## Response shape

Keep the response concise and practical.

Include:
- worktree state: clean or dirty
- checkpoint summary or current slice summary
- strongest intent/source match:
  - `TASKS.d/...`
  - `out/...`
  - or inferred from current changes
- impact summary
- readiness judgment
- if ready: proposed commit message and full commit command

## Style rules

- Preserve the user's workflow language: "status", "what changed", "ready to commit", "what's next".
- Prefer `tagd` / TAGL source vocabulary already used in the codebase.
- Align with the local doctrine in `AGENTS.md`.
- Be explicit when making an inference rather than reporting a direct task-file match.
