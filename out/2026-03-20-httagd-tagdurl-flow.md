# Task

Document the current `httagd` `tagdurl` parsing flow concisely so later work can replace handwritten `httagd` path parsing with the `tagl` `tagdurl` scanner.

## Scope

* inspect current `httagd` request-to-token flow
* inspect current `httagd` tests that exercise `tagdurl` behavior
* write one concise document in `out/`
* do not change `tagd/` code or tests

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

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

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md`
* keep the document short

## Tests

* no code changes required
* no test updates required

## Acceptance criteria

* boundary
  + only documents current behavior
  + does not begin Task 2 or Task 3
* behavior
  + identifies where `httagd` currently parses `tagdurl`
  + identifies how requests flow into `TAGL` parser tokens today
  + identifies the main coupling point to replace later
* tests pass
  + not applicable for this documentation-only task

## Deliverable: Concise Report

1. summary
2. test results
3. open issues, concerns or interesting observations

## Current flow

* `evhtp` routes the HTTP request into `httagd::main_cb`
* `main_cb` builds `request`, `response`, `transaction`, `callback`, and `httagl`
* `httagl::execute(...)` maps HTTP methods to:
  + `tagdurl_get`
  + `tagdurl_put`
  + `tagdurl_del`
* those methods call `htscanner::scan_tagdurl_path(...)`
* `scan_tagdurl_path(...)` parses the HTTP path and selected query options itself
* it emits `TAGL` parser tokens directly via `_driver->parse_tok(...)`
* request body TAGL, when present, is parsed separately through normal `TAGL::driver::execute(evbuffer*)`
* `TAGL` callback methods then perform `tagdb` operations and render the response

## Main files

* `tagd/httagd/src/httagd.cc`
* `tagd/httagd/include/httagd.h`
* `tagd/httagd/tests/Tester.h`
* `tagd/httagd/tests/tester.exp`
* `tagd/httagd/architecture.md`

## Main observation

`httagd` does not currently use the `tagl` `tagdurl` scanner as the primary parser for request paths.

The current coupling point is:

* `httagd::htscanner::scan_tagdurl_path(...)`

It currently owns:

* HTTP path splitting
* HDURI-aware segment handling
* command/query interpretation
* direct parser token emission

That is the boundary later tasks should replace.
