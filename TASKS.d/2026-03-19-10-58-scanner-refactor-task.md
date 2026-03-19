# Task

Refactor the `tagl` scanner into a modular re2c-based lexer that separates runtime control, reusable lexical definitions, and token emission while preserving current behavior.

## Scope

* `tagl/src/scanner.re.cc`
* `tagl/src/tagdurl.re.cc`
* `tagl/include/scanner.h`
* `tagl/src/scanner.cc`
* `tagl/include/tagl.h`
* `tagl/src/Makefile`

## Constraints

* preserve behavior
* keep diff small
* no new dependencies
* follow priority
  1. user prompts
  2. user specified task `.md` file
  3. `README.md` and `AGENTS.md`
  4. files references encountered when processing
     the files above should be folowed as needed
* do not modify `tagl/src/parser.y`
* do not change TAGL grammar or token names
* maintain compatibility with existing parser contract
* separate scanner runtime from re2c rule definitions
* centralize reusable lexical patterns
* make token emission explicit and consistent
* preserve streaming / refill behavior

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md`

## Tests

* update tests as needed
* modified code must be tested
* tests must pass before task is complete
* verify tokenization equivalence with current scanner
* verify handling of:
  + comments
  + quoted strings
  + line tracking
  + keyword classification
  + URI / file tokens

## Acceptance criteria

* clear separation between runtime, rules, and token emission
* no change in external scanner behavior
* parser integration unchanged
* tests pass

## Deliverable: Concise Report

1. summary
2. test results
3. open issues, concerns or interesting observations

