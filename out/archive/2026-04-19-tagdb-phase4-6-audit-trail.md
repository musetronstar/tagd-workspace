# Audit Trail Supplement: `tagdb` Phase 4 to Phase 6

## Purpose

This supplement reconstructs the review trail for the recent `claude` tagdb
work across the outer `tagd-workspace` repo and the inner `tagd` repo.

It exists because the surviving history is uneven:
- Phase 4 has a proper task file and code commits, but the commits do not prove
  a test-first sequence on their own.
- The workspace Phase 6 task file is a draft prompt, not a full executable task
  specification, while the implementation landed as later code commits in the
  inner repo.

The goal here is not to rewrite that history. The goal is to make the evidence,
the inferences, and the gaps explicit for later review.

## Scope

Reviewed artifacts:
- `TASKS.d/2026-04-18-chatgpt-tagdb-cpp23-phase4-task.md`
- `TASKS.d/2026-04-18-chatgpt-tagdb-sqlite-phase6.md`
- `out/2026-04-19-tagdb-cpp23-phase4-aar.md`
- `out/2026-04-19-tagdb-cpp23-phase5-aar.md`
- `out/2026-04-19-tagdb-cpp23-phase6-aar.md`
- recent `claude` and adjacent code commits in `tagd`
- recent workspace docs commits referring to Phase 4 / Phase 6

## Assignment Chain

### Phase 4

Task source:
- `TASKS.d/2026-04-18-chatgpt-tagdb-cpp23-phase4-task.md`

This is a proper task spec. It defines:
- objective
- scope
- contracts 0 through 4
- tests
- acceptance criteria

Conclusion:
- Phase 4 is task-aligned and reviewable at the assignment level.

### Phase 5

Task source:
- no standalone task file was found in `TASKS.d` for a formal Phase 5 contract
  set

What survives:
- a design finding recorded in `out/2026-04-19-tagdb-cpp23-phase5-aar.md`
- the seam/boundary comment added during the Phase 4 code work

Conclusion:
- treat Phase 5 as an intermediate design note and seam-audit result, not as a
  fully specified task execution.

### Phase 6

Workspace task file:
- `TASKS.d/2026-04-18-chatgpt-tagdb-sqlite-phase6.md`

Important limitation:
- this file is a draft prompt, not a full task spec
- it says “A good Phase 6 task would be”
- it ends with “I can draft that task.”

Conclusion:
- the Phase 6 implementation objective is understandable from the draft and the
  later code, but the assignment trail is weaker than Phase 4 and does not meet
  the same task-spec standard on its own

## Commit Mapping

### Workspace repo docs commits

- `7e0498d` `claude tagdb C++ phase 4`
  - tightens the Phase 4 task markdown
- `fa172b2` `claude: finished task phase 6`
  - adds the Phase 6 draft task file
  - adds Phase 5 and Phase 6 AARs

These are documentation/provenance commits in the outer workspace repo, not the
implementation commits in the inner `tagd` repo.

### Inner `tagd` repo code commits

Phase 4 implementation:
- `15dc2a7` `claude: tagdb C++23 phase 4 — interface correctness`
  - updates `tagdb/include/tagdb.h`
  - updates `tagdb/sqlite/include/tagdb/sqlite.h`
  - adds Phase 4 contract tests in `tagdb/tests/Tester.h`
- `8e6166f` `claude: split tagdb tests into Tester.h and SqliteTester.h`
  - refactors the test layout
  - preserves and relocates the new Phase 4 contract tests

Phase 6 implementation objective:
- `d2574fa` `httagd: route server db access through tagdb abstraction`
  - promotes url/referent overloads to the abstract interface
  - narrows `tagsh` and `httagd::server` to `tagdb::tagdb*`
  - adds abstract-pointer dispatch tests in `tagdb/tests/SqliteTester.h`

Adjacent follow-up:
- `ca54659` `codex: httagd: route server db access through tagdb abstraction`
  - outer-facing companion commit touching `httagd/include/httagd.h`

## Contract-to-Commit Trace

### Phase 4 contracts

Contract 1:
- implemented in `15dc2a7`
- evidence:
  - deleted copy/move on `tagdb::tagdb`
  - deleted copy/move on `tagdb::sqlite`
  - static-assert tests

Contract 2:
- implemented in `15dc2a7`
- evidence:
  - ownership/copy-semantics comment on `tagdb::session`
  - `test_session_copy_preserves_state`

Contract 3:
- implemented in `15dc2a7`
- evidence:
  - `get_session()` and `new_session()` lifetime comments
  - `test_session_ownership_boundary`

Contract 4:
- implemented in `15dc2a7`
- evidence:
  - sqlite boundary comment replacing the older TODO block

Test organization follow-up:
- `8e6166f`
- moves the new session tests out of `Tester.h` into `SqliteTester.h`

### Phase 6 objective

The Phase 6 draft identifies the design question but does not define formal
contracts. The implementation objective can still be traced:

- objective inferred from draft:
  - choose what belongs in `tagdb::tagdb`
  - keep sqlite-only methods below the seam
  - narrow top-layer concrete-type storage where possible
- implementation commit:
  - `d2574fa`
- evidence:
  - non-pure virtual url/referent overloads added to `tagdb::tagdb`
  - `override` markers added in `tagdb::sqlite`
  - `tagsh` and `httagd::server` changed to `tagdb::tagdb*`
  - abstract-pointer dispatch test added

## TDD and Process Status

### What is directly evidenced

Directly evidenced by the surviving commits:
- Phase 4 had a proper task spec before implementation
- Phase 4 code changes were accompanied by contract tests
- current codebase verification succeeds:
  - `make -C tagd/tagdb/tests`
  - `make -C tagd`

### What is only an inference

Reasonable inference, but not proven by commit order alone:
- the Phase 4 tests may have been written before the final implementation was
  committed
- the Phase 6 work likely followed the design note in the draft task file even
  though that file was never expanded into a full contracts/tests/acceptance
  document

### What remains a process gap

Still not fully recoverable from history:
- no commit sequence proves strict test-first ordering for Phase 4
- no complete Phase 6 task spec exists in `TASKS.d`
- the workspace commit `fa172b2` says “finished task phase 6” even though the
  referenced task file is still a draft prompt

That means the code trail is now reviewable, but the process trail remains:
- strong for Phase 4 assignment
- partial for Phase 4 TDD chronology
- weak for Phase 6 assignment formality

## Verification Rerun

Rerun during audit on 2026-04-19:

```sh
$ make -C tagd/tagdb/tests
Running cxxtest tests (55 tests).......................................................OK!

$ make -C tagd
[make] tagd build
[make] tagdb build
[make] tagl build
[make] tagsh build
[make] httagd build
```

Result:
- current tree builds clean
- current tagdb test suite passes

## Reviewer Guidance

Use the records this way:
- for task intent and acceptance criteria, prefer the Phase 4 task file
- for the seam finding between Phase 4 and Phase 6, use the Phase 5 AAR
- for the boundary implementation outcome, use the Phase 6 AAR together with
  the commit mapping in this supplement
- for process rigor, do not overclaim a stronger TDD or assignment trail than
  the surviving commits actually show
