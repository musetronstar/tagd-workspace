# Task

Refactor `tagd/tagsh/tests` so `tester.exp` and related expect coverage are reserved for true shell and process behavior, while logger behavior, parser-owned behavior, and other lower-layer contracts move to the fastest in-process test layer that actually owns them. The desired structural change is a readable, durable test split: `tagsh` expect tests cover prompts, shell commands, argv/process wiring, and other terminal-facing behavior; `tagsh`, `tagl`, and `tagd` unit or in-process tests cover logger routing, parser and callback behavior, and output contracts that do not require spawning a shell.

##Engineering Excellence

* Preserve or improve consistency across semantics, ontology, code, tests, build behavior, and documentation by testing each behavior at the layer that owns it instead of re-proving everything through a spawned shell.
* If the task touches TAGL-facing behavior, keep the enterprise speaking TAGL consistently by treating parser, callback, and error-shape contracts as TAGL-owned truths, not as incidental shell transcripts.
* Concentrate change at the test-layer seam: decide which contracts belong to `tagd`, `tagl`, `tagsh` in-process tests, and which still genuinely require expect-driven spawned-shell tests.

## Scope

### Read
* `AGENTS.md`
* `docs/ai-assisted-dev-doctrine.md`
* `tagd/tagsh/tests/tester.exp`
* `tagd/tagsh/tests/log-tester.exp`
* `tagd/tagsh/tests/Makefile`
* `tagd/tagsh/src/`
* `tagd/tagl/tests/`
* `tagd/tagd/tests/LoggerTester.h`
* recent `tagd/` git history related to logger, parser, callback, and shell output behavior

### Write
* `tagd/tagsh/tests/`
* `tagd/tagsh/src/` only if required to expose an in-process test seam
* `tagd/tagl/tests/`
* `tagd/tagd/tests/`
* `tagd/tagsh/tests/Makefile`
* task notes or closely related docs only if the refactor requires explicit documentation updates

### Non-goals
* redesigning logger semantics, TAGL grammar, or shell UX unless a migration step exposes a real bug
* broad changes to `httagd` tests in the same iteration
* adding new third-party test dependencies
* rewriting every existing expect test in one pass
* changing external CLI behavior just to simplify test structure

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
* treat test ownership as a source-of-truth decision: logger mechanics belong to `tagd`, parser/callback semantics belong to `tagl`, shell/process behavior belongs to `tagsh` expect or in-process shell tests as appropriate

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
* expected verification commands for migration steps may include:
  * `make -C tagd/tagd tests`
  * `make -C tagd/tagl tests`
  * `make -C tagd/tagsh tests`

## Acceptance Criteria

* boundary: changes stay within the declared scope and non-goals
* behavior: the requested contract is preserved or improved as specified
* verification: named tests/build commands pass
* reviewability: resulting structure is easier to understand, extend, or swap at the stated seam
* consistency: the change reduces or avoids semantic, ontological, system, or documentation drift
* `tagd/tagsh/tests/tester.exp` is measurably more readable because lower-layer contracts no longer dominate it
* logger and parser ownership is clearer because tests for those behaviors live primarily in `tagd` and `tagl` respectively
* expect coverage remains only where spawned process or terminal behavior is the actual contract under test

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns, or interesting observations
4. suggested concise git commit message
