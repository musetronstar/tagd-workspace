# Task

[One paragraph. State what must be documented, for whom, and why it matters to the project mission.]

## Principles

* State the document type: active reference, planning-only, historical, or superseded.
* State how the document improves consistency across code, tasks, reports, and doctrine.
* If the document describes a TAGL-facing subsystem, state how it preserves a TAGL-centered source of truth.

## Scope

### Read
* [code, tests, commits, task files, reports, architecture notes, or generated artifacts to inspect]

### Write
* [documentation files or report directories the agent may change]

### Non-goals
* [implementation work, refactors, or speculative design work that must not begin in this task]

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Constraints

* preserve behavior; documentation-only tasks do not begin implementation unless explicitly requested
* keep diff small and focused on the stated document purpose
* no new dependencies
* follow priority
  1. user prompts
  2. user specified task `.md` file
  3. `README.md` and `AGENTS.md`
  4. files referenced by the materials above
* inspect referenced code, tests, and relevant commit history before declaring a document complete
* distinguish completed work, active work, and proposed future work
* name the source of truth when documenting semantics, contracts, or workflow

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md` when documenting TAGL-oriented systems
* use clear headings and evidence-backed impact statements
* prefer classification, association, and reduction when synthesizing large note collections

## Verification

* verify claims against current files, tests, and relevant git history
* if no code changes occur, say so explicitly
* if test status is part of the document, name the exact command and result
* if a document is historical or superseded, state what replaced it

## Acceptance Criteria

* the document stays within scope and does not silently start implementation work
* key claims are grounded in inspected sources
* the document helps a future agent or reviewer choose the next step with less ambiguity
* the document defers to existing sources where possible instead of restating them poorly
* the document reduces semantic, status, or process drift in the corpus

## Deliverable: Concise Report

1. summary of documentation changes
2. verification performed
3. open issues, concerns, or interesting observations
4. suggested concise git commit message
