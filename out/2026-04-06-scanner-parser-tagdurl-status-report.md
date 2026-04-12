# Scanner / Parser / tagdurl Status Report

Date: `2026-04-06`

## Summary

The scanner, parser, and tagdurl work achieved the main architectural shift
the task set was pushing toward:

* standalone tagdurl translation now lives in `tagd/tagl/`
* `httagd::scan_tagdurl_path` is retired
* the remaining HTTP-specific POST/PUT path-body composition seam is isolated
  in `httagd`
* Lemon/parser ownership is much cleaner than the broad `std::string *`
  destructor model described in the planning documents
* the scanner/parser boundary now uses stable `TokenText` slices backed by a
  parse-lifetime token store

The work is not "everything finished forever." A few task criteria remain
unfinished, and some earlier task statements were partially superseded by the
design decisions made during implementation. But the largest project goals in
these files are now materially complete.

## Complete Criteria

### `TASKS.d/2026-03-19-11-36-scanner-refactor-task.md`

Completed:

* scanner runtime and re2c rule definitions are separated across
  `scanner.h`, `scanner.cc`, `scanner.re.cc`, and `tagdurl.re.cc`
* reusable scanner runtime conventions exist for both TAGL and tagdurl scanner
  paths
* multiple scanner modes are represented by scanner classes, not the old
  `scanner_mode`
* streaming / refill behavior is preserved and now directly tested
* token continuation across buffer boundaries is tested for plain tags, quoted
  strings, URIs, and TAGL include-file tokens
* parser contract remained compatible while the internal token representation
  changed

### `TASKS.d/2026-03-20-08-33-scanner-refactor-continue.md`

Completed:

* `scanner_mode` was removed in favor of `TAGL::scanner` and
  `TAGL::scanner::tagdurl`
* scanner behavior stayed intact while scanner internals became more modular
* scanner implementation moved out of `tagl.cc` and is now centered in
  scanner-specific files

### `TASKS.d/2026-03-20-14-12-tagdurl-scanner.md`

Completed:

* `tagd/tagl/tests/TagdUrlTester.h` exists and covers portable tagdurl
  semantics derived from `httagd/tests/tester.exp`
* tagdurl behavior was ported incrementally with TDD slices
* system-level behavior remained green under `httagd/tests/tester.exp`
* current tagdurl processing in `httagd` was documented and then largely
  migrated out

Partially complete:

* the task originally said "find all places where we use tagdurls and use the
  TAGL tagdurl scanner instead"
* this is complete for standalone tagdurl translation
* it is intentionally incomplete for HTTP POST/PUT body composition, which was
  left in `httagd` as transport semantics rather than pushed into `tagl`

### `TASKS.d/2026-03-28-symbolic-sub-rel.md`

Completed:

* operator-only symbolic aliases `-^` and `->` are now part of the parser
  model and are reflected in the current parser naming/typing cleanup

Residual note:

* this task is adjacent to the parser refactor, but not central to the
  tagdurl migration

### `TASKS.d/2026-03-29-tagdurl-scanner-redo.md`

Completed:

* the critique and redesign objective were effectively carried out
* implementation followed ownership boundaries instead of copying old
  imperative `httagd` parsing logic verbatim
* the resulting work moved parsing into `tagl` while leaving only transport
  behavior in `httagd`

### `TASKS.d/2026-04-04-parser-bugs.md`

Completed:

* the parser teardown crash around syntax-error cleanup was fixed
* the suite no longer corrupts later parser executions
* `Tester` and `TagdUrlTester` both pass
* UTF-8 coverage stayed in place while fixing the bug

### `TASKS.d/2026-04-04-parser-refactor.md`

Completed:

* `parser.y` was substantially simplified
* parser-driver glue moved out of `parser.y`
* broad manual token ownership cleanup was removed from grammar actions
* `MDELETE` was eliminated
* `DELETE` is confined to Lemon destructors
* parser semantics moved closer to SQLite/Lemon style:
  * `NoValue` default type
  * explicit scalar/text types
  * `TokenText` at the parser boundary
  * clearer ownership semantics

Completed enough for the stated refactor intent:

* the parser is markedly cleaner, leaner, and less error-prone than the state
  described in the task

### `TASKS.d/2026-04-04-tagdurl-refactor.md`

Completed:

* standalone tagdurl semantics moved toward `tagl` ownership
* `TagdUrlTester` now covers the supported tagdurl contract
* no new manual parsing drift was introduced in `httagd`
* `httagd::scan_tagdurl_path` was retired
* `httagd` GET and DELETE routing now use `TAGL::driver::scan_tagdurl(...)`
* standalone PUT path semantics are owned by `tagl`

Completed at the project boundary actually chosen:

* `q` and `c` live in TAGL/tagdurl semantics
* `v` remains outside TAGL
* one tagdurl maps to one TAGL statement

### `TASKS.d/2026-04-05-token-backing-store.md`

Completed:

* parse-lifetime token backing store exists
* cross-refill token correctness is directly tested
* token lifetime after later scanner activity is directly tested
* parser token payloads are now stable lightweight `TokenText` slices
* scanner/parser contract is much closer to the stated design direction

Completed beyond the early acceptance target:

* the work did not stop at scaffolding; it reached actual Lemon token payload
  migration

### `out/2026-03-29-tagdurl-scanner-redo.md`

Completed:

* the report’s core recommendation was followed:
  * confirm behavior from `httagd`
  * port one category at a time
  * reduce `httagd` to routing/delegation

### `out/2026-04-04-codex-assessment.md`

Completed:

* both blocking bugs identified in the assessment were fixed
* the underspecified context-option tests were strengthened

### `out/2026-04-04-parser-type-guidance.md`

Completed:

* the suggested direction was largely realized:
  * `NoValue`
  * `TokenText`
  * scalar types preserved
  * broad pointer ownership reduced

### `out/2029-03-29-tagdurl-scanner-redo-claude.md`

Completed:

* ownership boundaries were implemented close to this plan
* `httagd` now delegates standalone tagdurl translation instead of owning the
  parser logic
* `TagdUrlTester` covers the main standalone categories

## Incomplete Criteria

### Global incomplete items across the task set

* not every task’s "final clean sweep" clause was taken literally
  * for example, no final repo-wide `make clean && make tests` result is
    recorded in this workstream
* some task files assumed `PUT`, `POST`, and `DELETE` path handling would all
  fully move into `tagl`
  * the final design intentionally left HTTP POST/PUT path-body composition in
    `httagd`
* some acceptance criteria were overtaken by better architecture decisions
  rather than fulfilled literally

### `TASKS.d/2026-03-19-11-36-scanner-refactor-task.md`

Incomplete or partially complete:

* reusable named re2c patterns are present, but not all lexical definitions
  were centralized into a single shared "all patterns in one place" structure
* the task’s "final - test all in tagd: make clean && make tests" is not
  evidenced here

### `TASKS.d/2026-03-20-14-12-tagdurl-scanner.md`

Incomplete or intentionally reinterpreted:

* not every historical tagdurl usage site now routes through the tagdurl
  scanner
* HTTP POST/PUT transport composition still lives in `httagd`
* this is by design, because that behavior is not standalone tagdurl syntax

### `TASKS.d/2026-04-04-parser-refactor.md`

Incomplete or still open:

* the parser is much cleaner, but this should not be read as "parser refactor
  is forever done"
* there is still room to:
  * move more support code out of `parser.y`
  * refine helper locations outside `tagl.cc`
  * continue narrowing any remaining broad parser assumptions

### `TASKS.d/2026-04-04-tagdurl-refactor.md`

Incomplete or deliberately bounded:

* `httagd` still owns the constrained POST/PUT body seam
* the task’s broad wording can sound like "all tagdurl behavior leaves httagd"
* in the implemented design, only standalone tagdurl translation left
  `httagd`; transport composition did not

### `TASKS.d/2026-04-05-token-backing-store.md`

Open ends:

* token backing store is working, but it is still a stepping stone rather than
  the final possible storage design
* there may still be future work to make token storage more compact or more
  elegant now that the parser boundary is stable

### `out/tagdurl-parsing-flow.md`

Outdated:

* this document still describes the old `httagd`-owned `scan_tagdurl_path`
  flow
* it is now background / historical reference, not the current architecture

## Notable Observations Important to Project Goals

### 1. The largest project goal was met

The biggest architectural objective across these files was to stop treating
tagdurl parsing as ad hoc `httagd` string logic and move standalone tagdurl
semantics into the TAGL scanner/parser stack.

That is now true.

### 2. The real remaining seam is HTTP transport, not tagdurl syntax

The unresolved work is no longer "finish tagdurl parsing." It is:

* how `HTTP_POST /id` and constrained `HTTP_PUT /id` compose a transport path
  with a TAGL body

That is an `httagd` design seam, not a `tagl` tagdurl gap.

### 3. The parser refactor paid off beyond cleanup

The parser/token work was not just internal polish. It removed real failure
conditions:

* syntax-error teardown corruption
* broad, ambiguous ownership behavior
* per-token heap ownership leaking through grammar actions

The resulting parser is a stronger foundation for future language evolution.

### 4. TDD worked best when the boundary was real

The most successful slices were the ones that respected clear ownership
boundaries:

* standalone tagdurl behavior in `TagdUrlTester`
* transport-only behavior in `httagd/tests/Tester.h`
* parser bug work in `tagl/tests/Tester.h`

That separation should continue in future work.

### 5. Some planning documents are now historical

Several artifacts were useful for direction but no longer describe the final
state exactly. In particular:

* `out/tagdurl-parsing-flow.md`
* early tagdurl-scanner task wording that assumed broader migration into
  `tagl`

Those should be treated as planning history, not current architecture docs.

### 6. The current risk profile is much better, but not zero

The largest correctness risks around parser teardown and tagdurl ownership
boundaries were reduced. Remaining risk is more likely to be:

* future drift between transport semantics and standalone tagdurl semantics
* stale documentation
* new parser features reintroducing overly broad ownership patterns

## Current Project-State Assessment

As of this report:

* scanner refactor: substantially complete
* token-backing-store/parser type refactor: substantially complete for the
  current objective
* parser bug task: complete for the identified crash/cleanup issues
* standalone tagdurl refactor: substantially complete
* remaining work: transport-layer design cleanup and documentation alignment

This is a strong stopping point for the current sprint.
