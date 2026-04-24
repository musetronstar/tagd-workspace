# Task

## Status

* COMPLETE: the parser teardown crash and syntax-error cleanup regression were fixed; `Tester` and `TagdUrlTester` pass per `out/2026-04-06-scanner-parser-tagdurl-status-report.md`.

Find and fix parser cleanup and syntax-error bugs exposed by the expanded TAGL
and tagdurl tests, starting with the crash that appears after `test_query_tag`
and reproduces through `TAGL::driver::free_parser()`.

## Scope

* `tagd/tagl/src/parser.y`
* `tagd/tagl/src/tagl.cc`
* `tagd/tagl/src/scanner.re.cc`
* `tagd/tagl/tests/Tester.h`

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Design Principles

+ Interative & TDD - Think small
  1. add or isolate one regression at a time
  2. reproduce the failure with the smallest parser-level test possible
  3. fix ownership / destructor / parser-state behavior at the source
  4. pass the targeted regression, then the full suite
+ prefer parser-contract fixes over test weakening
+ preserve the author's design comments around destructor behavior and syntax errors
+ distinguish real scanner bugs from parser teardown bugs

## Constraints

+ preserve existing language behavior except for the bug being fixed
+ keep diff small
- no new dependencies
+ do not paper over parser corruption with manual resets that hide ownership bugs
+ treat `%syntax_error`, destructors, and parser teardown as the primary boundary
+ follow priority
  1. user prompts
  2. this task file
  3. `README.md`, `TAGL-README.md`, `AGENTS.md`

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md`

## Tests

* preserve the new UTF-8 coverage in `tagd/tagl/tests/Tester.h`
* add the smallest regression needed for parser cleanup if one is missing
* run `make -C tagd/tagl tests`
* task is not complete until the crashing parser path is stable under the suite

## Acceptance Criteria

* syntax-error teardown no longer corrupts later parser executions
* `Tester` and `TagdUrlTester` both pass
* the fix is localized and reviewable

## Deliverable: Concise Report

1. bug summary and root cause
2. test results
3. any remaining parser cleanup risks
