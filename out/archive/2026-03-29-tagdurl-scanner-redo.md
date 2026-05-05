# tagdurl scanner redo

## Summary

Claude's `tagdurl` scanner material establishes the main design fact: current
`tagdurl` parsing behavior lives in `httagd`, emits `TAGL` tokens, and should be
moved into the `TAGL` scanner layer without changing the external contract.

The strongest Claude artifacts are the path-shape notes and the inventory of
observed `tagdurl` examples. The weak point is that the original task draft is
too imperative and too detailed about local code moves. It should state
restraints and end state, then let the coding agent choose the implementation.

## Critique

### `TASKS.d/2026-03-20-14-12-tagdurl-scanner.md`

* correctness: directionally correct
* completeness: missing a clear statement of final ownership boundaries between
  `httagd` and the `TAGL` scanner
* feasibility: weakened by verbosity and by prescribing implementation steps
  instead of design constraints

### `out/tagdurl-parsing-flow.md`

* correctness: useful high-level runtime flow
* completeness: does not say clearly enough what logic must leave `httagd`
* feasibility: good background note, not a task spec

### `out/task1-tagdurl-parsing.md`

* correctness: most useful source for current `tagdurl` path behavior, including
  `PUT` versus `POST`
* completeness: should be paired with explicit refactor boundaries
* feasibility: useful as observed behavior and scanner requirements

### `out/tagdurl-test-examples.md`

* correctness: useful behavior inventory, but examples should be verified
  against current code and tests before becoming contract
* completeness: broad enough for representative categories
* feasibility: workable if reduced to small TDD slices rather than added all at
  once

## Refactor Plan

1. confirm the current `tagdurl` contract from existing `httagd` code and tests
2. choose one small `tagdurl` category for the first scanner test
3. add `TagdUrlTester` coverage for that category
4. move only the corresponding path parsing into
   `tagd/tagl/src/tagdurl.re.cc`
5. reduce `httagd/src/httagd.cc` to routing and scanner delegation
6. run the focused tests
7. repeat category by category until duplicated parser logic is removed or
   clearly minimized
8. run the broader relevant test targets before completion

## Suggested task rewrite

The original task should be rewritten as a short mission with these properties:

* scope limited to scanner, scanner tests, and `httagd` delegation code
* constraints focused on behavior preservation, small diffs, no new
  dependencies, and TDD sequencing
* acceptance criteria focused on ownership transfer, representative scanner
  coverage, and passing tests
* deliverables limited to summary, test results, open concerns, and a commit
  message

## Initial scanner test categories

* root and simple tag lookup
* child query and relation-filter query
* wildcard query
* search query forms
* `PUT`, `POST`, and `DELETE` path handling
* `HDURI` path handling
* invalid-path and invalid-method combinations
