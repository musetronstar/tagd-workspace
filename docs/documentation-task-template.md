# Task

[One paragraph. State what must be documented, for whom, and why it matters to the project mission.]

## Scope

### Read
* [code, tests, commits, task files, reports, architecture notes, or generated artifacts to inspect]

### Write
* [documentation files or report directories the agent may change]

### Non-goals
* [implementation work, refactors, or speculative design work that must not begin in this task]

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Documentation Principles

* Document current truth, not remembered architecture.
* Separate observed facts, grounded in code/tests/history, from inference or recommendation.
* Prefer concise operational documents over broad narrative unless the task explicitly asks for exploration.
* Keep one source of truth per topic; avoid duplicating instructions across tasks, reports, and templates.
* Use documentation to sharpen the next engineering step: boundaries, decisions, evidence, and remaining work.
* When documenting generated or archived artifacts, state whether they are active, historical, superseded, or planning-only.

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

* boundary: the document stays within scope and does not silently start implementation work
* fidelity: key claims are grounded in the inspected sources
* utility: the document helps a future agent or reviewer choose the next step with less ambiguity
* non-duplication: the document links or defers to existing sources where possible instead of restating them poorly

## Deliverable: Concise Report

1. summary of documentation changes
2. verification performed
3. open issues, concerns, or interesting observations
4. suggested concise git commit message
