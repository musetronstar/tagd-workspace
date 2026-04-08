# Task

Refactor the `tagl` scanner into a modular re2c-based lexer architecture that separates runtime control, reusable lexical definitions, and token emission, while preserving current behavior and enabling reuse of lexical patterns and multiple scanner modes.

## Scope

In the `tagd` repository directory:

### Current `tagl` Scanner Layout

* `tagl/src/scanner.re.cc`
* `tagl/include/tagl.h`
* `tagl/src/Makefile`

### Refactored `tagl` Scanner Layout

* `tagl/src/scanner.re.cc`
   + re2c scanner for TAGL language input
   + emits parser tokens
   + no function defs
   + any processing blocks, put in function, move to `scanner.cc`
   + TODO: output to file named `scanner.out.cc`
   + TODO: put the `/*!re2c` block of named re patterns into `scanner.h`
   + TODO: put macros and function in to `scanner.h` and `scanner.cc`
* `tagl/src/tagdurl.re.cc`
   + re2c scanner for a **tagdurl** as input
   + emit parser tokens
   + emits same tokens as `scanner.re.cc`
   + TODO: output to file named `scanner.tagdurl.cc`
* `tagl/include/scanner.h` 
* `tagl/src/scanner.cc`
   + `scanner.h` funtions implemented in `scanner.cc`
   + function with good names
   + reuasble blocks of code useful for any scanner
* `tagl/include/tagl.h`
* `tagl/src/Makefile`


The parser contract in `tagl/src/parser.y` must be respected, but the refactor plan should reduce direct coupling between lexer rules and parser-facing actions.

### Support Incremental Input

The current scanner handles streamed input via `evbuffer`. The refactor plan must preserve support for:

* bounded internal buffering
* refill-driven scanning
* correct token continuation across buffer boundaries
* correct handling of partial quoted strings or partial tokens

Any modularization must keep streaming input as a supported mode, not a secondary afterthought.

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
* centralize reusable lexical patterns (e.g. `NAME = pattern`)
* make token emission explicit and consistent
* support multiple lexical states and scanner modes
* preserve streaming / refill behavior
* reduce coupling between lexer rules and parser-facing actions
* do not remove user comments that serve as documentation

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
* run `make tests` in module as being developed (e.g. `tagl` / `tagsh` / `httagd`)
* final - test all in `tagd`: `make clean && make tests`

## Acceptance criteria

* clear module boundaries between runtime, re2c rules, and token emission
* reusable named re2c patterns defined in a shared location
* support for multiple scanner modes (e.g. TAGL, tagdurl) using consistent runtime conventions
* reduced coupling between lexer and parser integration
* no change in external scanner behavior
* parser integration unchanged
* tests pass

## Deliverable: Concise Report

1. summary
2. test results
3. open issues, concerns or interesting observations

