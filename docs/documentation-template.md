# Task

[concise objective]

## Scope

[documents, reports, or design files which can be changed]

## Purpose

This is a design, planning, critique, or documentation task.

Do not treat it as an implementation task unless the user explicitly expands
scope to include code changes.

## Decision Gate

If the task exists to refine or choose an architectural direction, make that
decision explicit before proposing implementation work.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Design Principles

+ keep the document concise
+ state boundaries and ownership clearly
+ prefer durable guidance over task-local instructions
+ classify open items clearly instead of leaving them vague

## Constraints

+ keep diff small
- no new dependencies
+ do not mix planning and implementation unless explicitly requested
+ follow priority
  1. user prompts
  2. user specified task `.md` file
  3. `README.md` and `AGENTS.md`
  4. files references encountered when processing
     the files above should be folowed as needed

## Language & Style

* follow `STYLE.md`
* keep conclusions direct and reviewable

## Acceptance criteria

* within set boundaries
* design/documentation result is clearer than what it replaced
* decisions, deferred items, and superseded items are explicit

## Deliverable: Concise Report

1. summary of conclusions
2. recommended next step
3. deferred, superseded, or incomplete items
