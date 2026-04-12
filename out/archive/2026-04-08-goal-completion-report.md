# Project Archive Assessment

Date: 2026-04-08

## After Action Report

### TAGL scanner and tagdurl integration

* The scanner refactor stream is complete enough to archive: `tagd/tagl` now has separated scanner runtime and re2c lexer sources in `tagl/include/scanner.h`, `tagl/src/scanner.cc`, `tagl/src/scanner.re.cc`, and `tagl/src/tagdurl.re.cc`.
* The continuation task goal to remove `scanner_mode` is complete: no remaining `scanner_mode` references were found under `tagd/tagl` or `tagd/httagd`.
* The tagdurl migration goal is complete at the parser seam: `httagd::scan_request_tagdurl()` now delegates to `TAGL::driver::scan_tagdurl(...)`, so handwritten request-path token emission is no longer the active architecture.
* Current verification supports archiving this stream: `make -C tagd/tagl/tests build` passed, including `87` TAGL tests and `26` tagdurl tests.

### tagr-c++ tokenizer stream

* Tasks 1-4 of `TASKS.d/2026-03-21-tagr-tokenizing.md` are functionally complete in the current tree: token TSV logging, trie offset tracking, reverse-frequency shell tooling, and tests are present and passing.
* This task file should remain active because Task 5 is still open: the re2c scanner work exists only as planning/report artifacts, not implementation.
* Verification supports keeping the file active but not archiving it yet: `make -C tagr/tagr-c++/tests tests` passed after fixing `tagr-c++/src/Makefile` to use the sibling worktree path `../../../tagd`.

### tagd-nlp resource mapping

* The PTB to UD mapping task is complete enough to archive: `tagd-nlp/assets/ptd-ud-map.tsv` exists, the canonical source files are present, and the mapping landed in commit `b49c266`.
* The broader `tagd-nlp` development task remains open because it describes an ongoing program of work rather than a single delivered artifact.

### Simple English TAGLization

* The Simple English conversion task is not complete and should remain active.
* `tagd-simple-english/simple-english.tagl` still contains a large number of `-->>` commented entries, so the requested end state has not been reached.

## Association Map

### Architecture to verification

* TAGL scanner modularization enabled native tagdurl parsing.
* Native tagdurl parsing enabled focused `TagdUrlTester` coverage.
* Passing `tagl` and tagdurl tests justify archiving the three scanner/tagdurl task files.

### Tokenization to future NLP

* `tagr-c++` token logging and trie reconstruction provide a working first-pass intake layer.
* That intake layer is a prerequisite for the still-open Task 5 re2c scanner replacement.
* The PTB to UD mapping resource strengthens future POS translation work but does not by itself complete the larger `tagd-nlp` mission.

### Corpus work to translator quality

* The Simple English TAGLization task depends on stable TAGL parsing and stronger `tagr` translation behavior.
* The remaining `tagr` re2c scanner task and the open `tagd-nlp` program both feed into that larger corpus-conversion objective.

## Actionable Intelligence

### Archived as complete

* `TASKS.d/archive/2026-03-19-11-36-scanner-refactor-task.md` is fully addressed by the current modular `tagl` scanner layout and passing tests.
* `TASKS.d/archive/2026-03-20-08-33-scanner-refactor-continue.md` is fully addressed by removal of `scanner_mode` and current polymorphic scanner structure.
* `TASKS.d/archive/2026-03-20-14-12-tagdurl-scanner.md` is fully addressed by native TAGL tagdurl scanning plus dedicated `TagdUrlTester` coverage.
* `TASKS.d/archive/2026-03-27-tagd-nlp-PTD-UD-tsv.md` is fully addressed by `tagd-nlp/assets/ptd-ud-map.tsv` and related UD resource additions.

### Archived as no longer relevant

* `out/archive/2026-03-20-httagd-tagdurl-flow.md` described the old handwritten `httagd` path-parsing seam and is obsolete after native TAGL tagdurl scanning replaced that seam.
* `out/archive/tagdurl-parsing-flow.md` documents the same superseded request-to-token flow and is now historical rather than operational.

### Still relevant generated documents

* `out/2026-03-26-claude-tagr-scanner-plan-5.md` remains relevant because Task 5 is still open and this plan maps directly to the remaining scanner work.
* `out/2026-03-26-claude-tagr-scanner-prompt.md` remains relevant because it records the Task 1-4 review and frames the still-open Task 5 plan.
* `out/2026-03-21-claude-tagr-c++-trie-design.md` and `out/2026-03-21-codex-tagr-trie-memo.md` remain design-direction documents, not completed deliverables.
* `out/2026-03-17-GPT-5.5-NLP.md` remains contextual background for the broader NLP mission, not a completed task artifact.

## Tasks Left To Complete

### Translator architecture

* `TASKS.d/2026-03-21-tagr-tokenizing.md` remains open because Task 5, the re2c scanner replacement, is still planning-only and not yet implemented.

### NLP program

* `TASKS.d/2026-03-24-tagd-nlp-tagr.md` remains open because it is a broader multi-repository development program and not a single finished change.

### Corpus conversion

* `TASKS.d/2026-03-19-08-33-simple-english-task.md` remains open because the Simple English `.tagl` corpus still contains many untranslated commented entries.
