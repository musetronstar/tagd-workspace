# Task

## Status

* COMPLETE: parse-lifetime token storage and stable `TokenText` slices were delivered and directly tested, per `out/2026-04-06-scanner-parser-tagdurl-status-report.md`.

Refactor TAGL scanner token storage so parser token text can be represented as
stable slices rather than heap-allocated `std::string*` values for every token.

Date: `2026-04-05`

The goal is to introduce a parse-lifetime token backing store that supports the
stream-oriented push architecture already used by the scanner:

* buffer -> scanner -> parser -> callback

This refactor is a foundation step toward using Lemon more effectively with
lightweight token text types such as `TokenText { z, n }`, while preserving the
scanner's current refill behavior and token-boundary correctness.

## Task/Planning Files

Related parser refactor work:
* `TASKS.d/2026-04-04-parser-refactor.md`

Related parser bug work:
* `TASKS.d/2026-04-04-parser-bugs.md`

## Refactor Direction

The new direction is to make the scanner/parser contract more honest and easier
to reason about.

Today, parser token text is usually turned into a heap-allocated `std::string*`
before it reaches Lemon. That has kept token lifetime safe, but it also mixes
several concerns together:

* lexical token text
* parser semantic payload
* ownership and deletion policy
* the old convention that a `NULL` string pointer can mean "no value"

The refactor direction is to separate those concerns:

* scanner recognizes token boundaries
* token storage owns parse-lifetime text backing
* Lemon carries lightweight token text values
* semantic/model code copies only when ownership is actually needed

This is not only an allocation or performance refactor. It is also a parser
comprehension refactor. The grammar and scanner should become easier to read
once token text, parser control symbols, and owned semantic objects are no
longer conflated.

## Design Notes

The scanner currently uses:

* `_buf` as the active scan buffer
* `_val` as scratch storage when token text spans buffer refill boundaries
* heap-allocated `std::string*` token values to give Lemon stable text

That makes parser token lifetime safe, but it obscures scanner/parser ownership
and allocates for every emitted token.

The desired direction is:

* keep scanner refill logic stream-oriented
* keep token-boundary behavior correct across contiguous input buffers
* give emitted tokens stable parse-lifetime backing storage
* allow Lemon semantic values to carry lightweight token slices instead of owned
  strings where appropriate

Use SQLite's Lemon/token style as a model for the direction of travel:

* `/home/inc/src/sqlite-src-3510300/src/parse.y`

SQLite is useful here not because TAGL should copy SQLite literally, but
because it shows a disciplined Lemon design:

* lightweight token text at the parser boundary
* explicit ownership only for symbols that truly own data
* a clearer separation between lexical text and semantic objects

The token backing store should be treated as a separation-of-concerns boundary:

* scanner recognizes token boundaries
* token store owns stable token text for parser lifetime
* parser consumes lightweight token text values
* semantic/model code copies to owning strings only when needed

This matches the existing stream-oriented push architecture and the original
intent behind the scanner fill-buffer design:

* the scanner should behave as if it is reading a continuous stream
* token boundaries may span contiguous fills
* backing storage should absorb that complexity so the parser does not need to
  care about refill mechanics

## Design Philosophy

This task should follow a few design ideas that have become clearer during the
parser refactor:

* prefer first-principles parser design over patching symptoms
* use Lemon in a way closer to its design assumptions
* make ownership explicit instead of encoding it indirectly in pointer
  conventions
* reduce hidden heap allocation and hidden lifetime coupling
* preserve the streaming architecture rather than replacing it with a batch
  parser mindset

The token backing store is therefore not a side utility. It is a structural
boundary that supports the larger parser refactor:

* fewer ad hoc manual deletes
* clearer semantic types
* more reliable scanner/parser lifetime rules
* eventual removal of the broad "everything is `std::string*`" model

## TDD Iteration Path

### Iteration 1
* add one focused test that forces a token across scanner refill boundaries
* prove current behavior before refactoring storage

### Iteration 2
* introduce a small token backing store abstraction with parse-lifetime reset
* wire it into scanner lifecycle without changing emitted token types yet

### Iteration 3
* route one narrow scanner token path through the backing store
* preserve existing behavior and tests

### Iteration 4
* add lifetime-focused tests ensuring earlier token text remains valid after
  later refill/reuse activity

### Iteration 5
* only after stable backing is proven, migrate one tiny parser alias cluster to
  lightweight token text types

### Iteration 6
* use the new stable token representation to guide further parser type cleanup
* continue toward explicit Lemon types and narrower destructors

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
