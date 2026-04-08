# Task

[One paragraph. State the desired change in behavior or structure, not the internal implementation choreography.]

**Engineering Excellence**

* State how this task preserves or improves consistency across semantics, ontology, code, tests, build behavior, and documentation.
* If the task touches TAGL-facing behavior, state how it keeps the enterprise speaking TAGL consistently.
* Name the seam where change should be concentrated.

## Scope

### Read
* [repositories, modules, documents, tests, generated artifacts the agent should inspect]

### Write
* [files or directories the agent may change]

### Non-goals
* [explicitly name nearby files, subsystems, or ideas that are out of scope]

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Design Principles

* Think small: prefer one reviewable improvement at a time.
* Preserve behavior while improving structure unless the task explicitly changes behavior.
* Respect the existing external contract first: parser contract, CLI surface, file formats, and test expectations.
* Prefer deterministic outputs, deterministic tests, and explicit tie-breakers in tooling.
* Keep generated artifacts, build paths, and test fixtures aligned with the active workspace layout.
* Reuse existing repo patterns before inventing new ones.
* Reduce coupling by clarifying ownership boundaries, not by introducing extra abstraction for its own sake.
* Preserve consistency as a first-class engineering goal.
* **We eat our own dogfood**: prefer designs that keep input, processing, output, diagnostics, and service seams aligned with TAGL instead of fragmenting the truth model.

## Constraints

* preserve behavior unless the task explicitly says otherwise
* keep diff small, reviewable, and local to the stated scope
* no new dependencies unless explicitly requested
* follow priority
  1. user prompts
  2. user specified task `.md` file
  3. `README.md` and `AGENTS.md`
  4. files referenced by the materials above
* do not silently broaden scope when a missing prerequisite is discovered
* if generated files or build products are expected, name them explicitly
* if a report or plan is part of the task, distinguish completed work from proposed follow-on work
* if the task changes a truth-bearing structure, state the source of truth explicitly

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md` when working in TAGL-oriented repos
* preserve the author's comments and design intent unless the task explicitly changes them

## Tests

* write or update tests at the boundary that proves the requested change
* prefer fast in-process tests first, system tests second when CLI or process behavior matters
* modified code must be tested
* state the exact command(s) required for task completion
* task is not complete until the required test layer(s) pass
* if the build or tests depend on workspace-relative paths, verify those paths explicitly

## Acceptance Criteria

* boundary: changes stay within the declared scope and non-goals
* behavior: the requested contract is preserved or improved as specified
* verification: named tests/build commands pass
* reviewability: resulting structure is easier to understand, extend, or swap at the stated seam
* consistency: the change reduces or avoids semantic, ontological, system, or documentation drift

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns, or interesting observations
4. suggested concise git commit message
