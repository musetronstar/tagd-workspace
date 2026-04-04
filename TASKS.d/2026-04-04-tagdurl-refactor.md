# Task

Refactor tagdurl handling out of `httagd` manual path parsing and into the
`tagl` scanner/parser pipeline so tagdurls are TAGLized by `re2c`/Lemon rather
than by ad hoc transport-side parsing.

## Scope

* `tagd/tagl/src/tagdurl.re.cc`
* `tagd/tagl/src/parser.y`
* `tagd/tagl/include/scanner.h`
* `tagd/tagl/tests/TagdUrlTester.h`
* `tagd/httagd/src/httagd.cc`
* `tagd/httagd/include/httagd.h`

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Design Principles

+ Interative & TDD - Think small
  1. Port one portable `httagd/tests/tester.exp` tagdurl case at a time
  2. Implement the missing scanner/parser behavior in `tagl`
  3. Pass the smallest relevant test slice
  4. Report and stop before the next slice unless told to proceed
+ deterministic translation from tagdurl to TAGL
+ structural parsing belongs in `re2c`/Lemon, not manual C++ string parsing
+ semantic query opts `q` and `c` belong in TAGL mapping
+ `v` remains outside TAGL for now as a view/rendering concern

## Constraints

+ preserve behavior while moving responsibility
+ keep diff small
- no new dependencies
+ do not add workaround manual parsers just to pass tests
+ do not hard code query-opt semantics in multiple layers
+ use shared query-opt definitions from `tagl/include/scanner.h`
+ follow priority
  1. user prompts
  2. this task file
  3. `README.md`, `TAGL-README.md`, `AGENTS.md`

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md`

## Tests

* grow `tagd/tagl/tests/TagdUrlTester.h` from portable `httagd/tests/tester.exp` cases
* run `make -C tagd/tagl tests` after each small step
* keep `Tester.h` green while expanding tagdurl support

## Acceptance Criteria

* tagdurl semantics move toward `tagl` scanner/parser ownership
* `TagdUrlTester` covers the supported tagdurl contract
* no new manual parsing drift is introduced in `httagd`
* tests pass for the completed step

## Deliverable: Concise Report

1. summary of change for the current tagdurl slice
2. test results
3. next missing scanner/parser feature or open concern
