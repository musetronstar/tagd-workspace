# 2026-04-06 Refactor Closeout Audit

## Scope

This audit reviews the current `codex/dev` state after the scanner/parser/tagdurl
refactor and the two follow-up fixes:

- `dc93192` remove duplicate `get_statement TAGDURL` rule left by conflict resolution
- `eea7d70` build: add `parser.c` to clean; `parser.c` left on lemon failure for inspection

The goal is to identify:

- what is now in a good stopping state
- which TODOs should be addressed now vs later
- the most important remaining technical debt signals

## Post-refactor Fix Assessment

### 1. Duplicate `TAGDURL` parser rule

Status: complete and correct.

The duplicate `get_statement ::= CMD_GET TAGDURL(U)` production in
[`tagl/src/parser.y`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/src/parser.y)
was a merge artifact. The removed copy used the obsolete inline inner-driver path,
`*U`, and `MDELETE(U)`. The remaining rule uses the shared helper:

- `scan_tagdurl(tagl, U.str());`

This matches the current parser design and should not be reintroduced.

### 2. Lemon `parser.c` cleanup

Status: complete and appropriate.

[`tagl/src/Makefile`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/src/Makefile)
now removes both `parser.c` and `parser.cc` in `clean`. This is the right fix for
the observed stale generated-file case.

Note: the current rule still intentionally lists `parser.c` as an explicit target
to suppress make's built-in yacc fallback. That design is still justified.

## TODO Triage

### Address Later

These TODOs are real, but they are not blocking closure of this refactor.

- [`tagl/src/parser.y`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/src/parser.y)
  `not_found_context_dichotomy`
  - This is still an unresolved semantic/design issue.
  - It should be handled as a focused parser/query semantics task, not inside this refactor closeout.

- [`tagl/src/parser.y`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/src/parser.y)
  syntax-error cleanup follow-up
  - The parser is stable now, but the comment is fair: syntax-error cleanup still deserves a focused pass.
  - This belongs in a future parser-hardening task.

- [`tagl/include/tagl.h`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/include/tagl.h)
  and [`tagl/src/tagl.cc`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/src/tagl.cc)
  callback `_driver` side-effect TODOs
  - These are architectural debt around callback ownership/wiring.
  - They are not new, and should be handled when callback/session ownership is revisited.

- [`tagl/include/tagl.h`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/include/tagl.h)
  `relator` TODO
  - This is a parser/model ownership concern that should be addressed in a future parser semantic cleanup.

- [`httagd/src/httagd.cc`](/home/inc/sandbox/codex/tagd-workspace/tagd/httagd/src/httagd.cc)
  `TODO use tagd::error`
  - This aligns with the long-term goal of TAGL-shaped structured errors.
  - Worth doing, but not necessary to close the tagdurl migration task.

### Address Soon

These are small enough and close enough to the work just done that they deserve
near-term follow-up.

- [`tagl/tests/TagdUrlTester.h`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/tests/TagdUrlTester.h)
  `test_cmd_get_tag` has a stale `// TODO implement this`
  - The test is already implemented.
  - This comment should simply be removed.

- [`tagl/include/scanner.h`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/include/scanner.h)
  old tagdurl/scanner design block at end of file
  - This comment block is now historical scaffolding, not current guidance.
  - It should either be rewritten to match current design or removed.

### Already Effectively Resolved

These TODOs remain in comments/tests but are effectively now covered by the current implementation.

- Several parser/token-lifetime concerns that motivated the refactor are now resolved by:
  - `TokenText`
  - parse-lifetime token backing store
  - Lemon-owned cleanup
  - removal of `MDELETE`

The comments that still talk as if those issues are open should be reviewed case by case and pruned when touched next.

## Technical Debt Signals

### 1. `scanner.h` still carries outdated design commentary

The block comment after the include guard in
[`tagl/include/scanner.h`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/include/scanner.h)
describes an earlier planned tagdurl integration model. It no longer reflects the
current architecture well and could mislead future work.

This is the clearest documentation debt left by the sprint.

### 2. Parser/query semantics still have one known ambiguity seam

The `not_found_context_dichotomy` note in
[`tagl/src/parser.y`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/src/parser.y)
and its corresponding test TODOs in
[`tagl/tests/Tester.h`](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/tests/Tester.h)
remain the most visible known semantic gap.

This is not refactor fallout. It is a genuine language/lookup-model issue that is now easier to isolate because the parser is cleaner.

### 3. Callback ownership is still implicit and side-effectful

`callback_ptr()` and driver constructors still set `cb->_driver = this` directly.
That is legacy coupling, not a regression, but it is now more visible because the rest
of the parser/scanner ownership story was cleaned up.

### 4. Remaining `httagd` debt is transport-only, not tagdurl parsing

This refactor successfully moved standalone tagdurl translation into `tagl`.
The remaining complexity in `httagd` is now explicitly transport behavior:

- constrained `POST`/`PUT` path/body composition
- HTTP-specific error/reporting cleanup
- view/render response concerns

That is a good outcome. It means future work can target `httagd` transport semantics
without reopening the standalone tagdurl parser question.

## Closeout Assessment

The refactor is in a good stopping state.

Completed and stable:

- `TokenText` parser/scanner boundary
- parse-lifetime token storage
- Lemon cleanup/destructor model
- standalone tagdurl translation in `tagl`
- retirement of manual `httagd::scan_tagdurl_path`
- isolation of the remaining transport-only `httagd` seam
- post-refactor cleanup of the duplicate `TAGDURL` production
- build cleanup for stale generated `parser.c`

Incomplete but appropriately deferred:

- `not_found_context_dichotomy`
- callback ownership cleanup
- structured `tagd::error` normalization in all touched HTTP paths
- stale historical comments/TODO cleanup outside the files just fixed

## Recommended Next Small Tasks

1. Remove stale implemented TODO in [TagdUrlTester.h](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/tests/TagdUrlTester.h).
2. Rewrite or remove the outdated tagdurl/scanner design block in [scanner.h](/home/inc/sandbox/codex/tagd-workspace/tagd/tagl/include/scanner.h).
3. Open a dedicated task for `not_found_context_dichotomy` instead of letting it linger as incidental parser debt.
