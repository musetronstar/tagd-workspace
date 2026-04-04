# Task

Our lemon parser implementation in `tagd/tagl/src/parser.y` is a mess and is error prone in freeing tokens.

We need to refactor the TAGL parser. I want to first pull out any code that can be out of parser.y so that is is clean and minimal. The obvious target to put the code is `tagl.cc`, but it is already crowded. Propose other existing or new files to puth that code other that `tagl.cc` when appropriate.

## Task/Planning Files

Before we can finish this task:
* `TASKS.d/2026-04-04-tagdurl-refactor.md`

We must fix bugs:
* `TASKS.d/2026-04-04-parser-bugs.md`

But before fixing the bugs, we should refactor, consolodate and simplifly. Sometimes bugs just go away after a refactor.

During this refactor I want to **slice-and-dice** the current parser so that it is simplified and lean ane mean.
* `TASKS.d/2026-04-04-parser-refactor.md`

## Scope

Files which can be changed:

`tagd/tagl/*`

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Design Principles

+ Interative & TDD - Think small
  1. Write test according to user requirements
  2. Implement code according to user desired change of behaviour or constrainsts
     Write deep code according to specification, not shallow code just to pass a test
  3. Pass test
  4. Report back to user
  5. Ask to proceed with next iteration (unless already instructino to proceed).
+ small pure functions
+ deterministic translation
+ composable pipeline
+ clear error behavior

## Constraints

+ preserve behavior
+ keep diff small
- no new dependencies
+ follow priority
  1. user prompts
  2. user specified task `.md` file
  3. `README.md` and `AGENTS.md`
  4. files references encountered when processing
     the files above should be folowed as needed

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md`

## Tests

* update tests as needed
* modified code must be tested
* tests must pass before task is complete

## Acceptance criteria

* within set boundaries
* correct behavior
* tests pass

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns or interesting observations

