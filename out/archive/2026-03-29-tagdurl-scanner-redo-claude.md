# tagdurl Scanner Refactor

## Critique of Prior Artifacts

### `TASKS.d/2026-03-20-14-12-tagdurl-scanner.md`

* correctness: directionally correct; the target files and TDD intent are sound
* completeness: missing an explicit statement of ownership boundary between `httagd`
  and the `TAGL` scanner layer
* feasibility: weakened by prescribing implementation steps rather than design
  constraints; task grows too long to act on decisively

### `out/tagdurl-parsing-flow.md`

* correctness: accurate runtime flow; token-emission sequence matches source
* completeness: does not say what logic must leave `httagd`; useful as background,
  not as a task spec
* feasibility: suitable reference material, not actionable on its own

### `out/tagdurl-test-examples.md`

* correctness: examples reflect observed behavior but are not yet verified as tests
* completeness: representative categories are present; coverage of error paths is thin
* feasibility: workable if introduced as small TDD slices, not all at once

## Plan

### Task

`tagdurl` path parsing belongs in the `TAGL` scanner, not in `httagd`.
The `httagd` layer is responsible for HTTP routing and delegation only.
This refactor moves `tagdurl` path interpretation into `tagd/tagl/` and
establishes unit test coverage there.
The external HTTP contract must be preserved.

### Scope

* `tagd/tagl/src/` — scanner implementation; new `tagdurl` scanner source
* `tagd/tagl/include/` — scanner interface
* `tagd/tagl/tests/TagdUrlTester.h` — new unit test suite
* `tagd/tagl/tests/Makefile` — test registration
* `httagd/src/httagd.cc` — reduce to routing and delegation; remove duplicated parsing

Read only:
* `httagd/include/httagd.h`
* `httagd/tests/Tester.h`
* `httagd/tests/tester.exp`

### Constraints

* preserve the external `tagdurl` HTTP contract in all categories
* keep each diff small and reviewable; one scanner category per iteration
* no new dependencies
* TDD sequencing: unit tests precede implementation; system tests close each iteration
* user interruptions to code become design imperatives; do not reverse them

### Acceptance Criteria

* `tagdurl` path parsing is owned by `tagd/tagl/`, not `httagd/`
* `httagd` retains only HTTP routing and scanner delegation
* `TagdUrlTester.h` covers all categories below with passing tests
* `make tests` passes in `tagd/`

### Scanner Test Categories

* root tag lookup: `GET /tag`
* child query: `GET /tag/`
* relation-filter query: `GET /tag/rel1,rel2`
* wildcard query: `GET /*/rel`
* search query: `GET /tag/?q=terms`
* context query: `GET /tag?c=context`
* `PUT`, `POST`, `DELETE` path handling
* invalid-path and invalid-method error cases

### Deliverables

1. summary of changes
2. test results
3. open concerns
4. suggested commit message
