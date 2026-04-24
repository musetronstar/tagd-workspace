# Task

## Status

* COMPLETE: operator-only symbolic aliases `-^` and `->` are implemented in the parser model; the remaining note is only that this work is adjacent to the broader parser refactor, per `out/2026-04-06-scanner-parser-tagdurl-status-report.md`.

Add operator-only symbolic aliases for the foundational TAGL relators so that `-^` is accepted as the symbolic alias for `_sub` and `->` is accepted as the symbolic alias for `_rel`, while preserving the canonical hard-tag strings and existing hard-tag behavior. The symbols must be parsed only in operator positions; the canonical hard tags `_sub` and `_rel` must continue to work anywhere the current grammar allows them as tags or relators.

## Scope

- `tagl/src/scanner.re.cc`
- `tagl/src/parser.y`
- generated parser/scanner artifacts only if they are normally regenerated from the sources above
- focused tests that cover scanner/parser behavior for these symbolic aliases

## Constraints

* preserve existing behavior outside this feature
* keep diff small
* no new dependencies
* do not modify `hard-tags.h`
* do not redefine `HARD_TAG_SUB` or `HARD_TAG_RELATOR`
* scanner should emit distinct symbol tokens for the aliases, not normalize them into ordinary tag tokens
* parser should admit the symbols only in relation/operator grammar positions
* canonical hard tags `_sub` and `_rel` must remain valid wherever the current grammar already allows them
* symbols `-^` and `->` must not become valid operands simply because the canonical hard tags are valid operands

* follow priority
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
* add or update parser/scanner tests to prove:
  * `>> dog -^ mammal;` parses as `_sub` in operator position
  * `>> dog -> tail;` parses as `_rel` in operator position
  * `>> dog _sub mammal;` still works
  * `>> dog _rel tail;` still works
  * symbolic aliases are rejected in operand-only positions where ordinary hard tags remain legal

## Acceptance criteria

* boundary
  * implementation is confined to scanner/parser and necessary generated artifacts/tests
  * `hard-tags.h` is unchanged

* behavior
  * scanner emits dedicated symbol tokens for `-^` and `->`
  * parser maps those tokens to canonical `_sub` and `_rel` semantics only in operator positions
  * `_sub` and `_rel` continue to behave as canonical hard tags and may still act as operands where the existing grammar allows that
  * `-^` and `->` behave only as operators, not operands

* tests pass

## Deliverable: Concise Report

1. summary
2. test results
3. open issues, concerns or interesting observations
