# Task: C++23 Stage 1 Correctness — Phase 8

Close the three remaining correctness gaps identified in the excellence guide
and deferred from earlier phases. These are independent of each other and
ordered by dependency: complete each task fully before beginning the next.
All existing behavior is preserved. This is a correctness and RAII task,
not a feature change.

## Principles

* TDD order is mandatory for each task: test first, then implement.
* Keep each task's diff scoped and reviewable independently.
* Stop and report if any task reveals a non-trivial cascading change.
* Comment *why* at every new STL or RAII protocol site.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md` and `AGENTS.md`.

## Scope

### Read
* `tagd/include/tagd.h`
* `tagd/src/tagd.cc`
* `tagdb/include/tagdb.h`
* `tagdb/sqlite/include/tagdb/sqlite.h`
* `tagdb/src/tagdb.cc`
* `tagl/include/tagl.h`
* `tagl/src/tagl.cc`
* `tagsh/include/tagsh.h`
* `tagsh/src/tagsh.cc`
* All test files across modules — for caller audit

### Write
* `tagd/include/tagd.h` (Task 1, Task 2)
* `tagd/src/tagd.cc` (Task 2)
* `tagdb/include/tagdb.h` (Task 1)
* `tagdb/sqlite/include/tagdb/sqlite.h` (Task 1)
* `tagl/include/tagl.h` (Task 1, Task 3)
* `tagl/src/tagl.cc` (Task 3)
* Test files as required by each task
* Cascading caller fixes to keep the build green

### Non-goals
* No behavioral changes to any query, parse, or error path.
* No changes to generated parser/scanner files.
* No opportunistic cleanup outside the stated tasks.
* If a task exposes a non-trivial prerequisite gap: stop and report.

---

## Task 1 — `[[nodiscard]]` expansion across `tagd`, `tagdb`, `tagl`, `tagsh`

### Background

Phase 1 added `[[nodiscard]]` to the `relation()` family on `abstract_tag`.
Many other methods across the codebase return `tagd::code` where the caller
is expected to check the result — unchecked error codes are silent correctness
holes. `[[nodiscard]]` promotes them to compile-time warnings.

### What must be true after this task

* Every method that returns `tagd::code` where an unchecked return is a
  likely programming error is marked `[[nodiscard]]`.
* Priority sites (audit in this order):
  * `tagdb::tagdb` virtual interface — `get`, `put`, `del`, `query`
  * `tagdb::sqlite` — all public methods returning `tagd::code`
  * `TAGL::driver` — `parseln`, `execute`, `scan_tagdurl`, `include_file`,
    `push_context`, `new_url`
  * `tagsh` — public methods returning `tagd::code`
* Methods where ignoring the return is intentional (fire-and-forget patterns)
  must be explicitly documented with a comment explaining why `[[nodiscard]]`
  is not applied.
* No existing call site may be silently broken — audit all callers and fix
  any that discard a now-nodiscard return without `(void)` cast.

### Constraints

* Do not mark `[[nodiscard]]` on methods where callers legitimately ignore
  the return — document those sites instead.
* If a caller fix is non-trivial, stop and report before proceeding.

### TDD

Write a compile-time test (static assertion or a test that must fail to
compile before the fix) for at least one representative site per module.
After the fix, confirm the full build produces no new warnings treated
as errors and no suppressed `[[nodiscard]]` violations.

### Verify

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

Must build clean with no new warnings.

---

## Task 2 — `std::set::extract()` in `merge_tags` and `merge_tags_erase_diffs`

### Background

`merge_tags` and `merge_tags_erase_diffs` in `tagd.cc` use a copy/erase/reinsert
pattern when merging relations into an existing tag in a `tag_set`. This is
required because `std::set` iterators are `const` — elements cannot be mutated
in place. In C++17, `std::set::extract()` was introduced to allow node extraction,
mutation, and reinsertion without copying the element. This was deferred in Phase 1
with a TODO comment in the code.

### What must be true after this task

* The copy/erase/reinsert pattern in `merge_tags` is replaced with
  `extract()` / mutate / `insert()`.
* The same replacement is applied in `merge_tags_erase_diffs` wherever
  the same pattern appears.
* Behavior is identical — same tag relations produced for the same inputs.
* The TODO comment placed in Phase 1 is removed and replaced with an intent
  comment explaining the `extract()` approach.
* `merge_containing_tags` is audited: if it uses the same pattern, apply
  the same fix; if not, document why.

### Constraints

* Do not change the semantics of any merge operation.
* `extract()` invalidates the extracted node's iterator — ensure no iterator
  is used after extraction.

### TDD

The existing `merge_tags` tests in `tagd/tests/Tester.h` are the contract.
They must pass unchanged. Add one new test that exercises the merge path
specifically on a tag with existing relations being merged — proving the
extract/mutate/reinsert path produces correct output.

### Verify

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagd/tests
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

---

## Task 3 — `std::unique_ptr` for `_parser` in `TAGL::driver`

### Background

`TAGL::driver::_parser` is a raw `void*` managed by `ParseAlloc` and `ParseFree`
from the lemon parser API. Phase 7 documented this ownership explicitly with a
comment. The natural next step is to give it RAII via `std::unique_ptr` with a
custom deleter — this eliminates the manual `ParseFree` call in `free_parser()`
and makes the ownership unambiguous in the type system.

### What must be true after this task

* `_parser` is declared as:
  ```cpp
  std::unique_ptr<void, decltype(&ParseFree)> _parser{nullptr, ParseFree};
  ```
  or equivalent — the exact form is left to the agent; the contract is that
  `ParseFree` is called automatically when `_parser` is reset or destroyed.
* `free_parser()` no longer calls `ParseFree` directly — it resets or
  releases the `unique_ptr` instead.
* The copy/move `= delete` declarations on `driver` remain unchanged —
  `unique_ptr` members reinforce this naturally but the explicit deletions
  stay as documentation.
* The Phase 7 ownership comment on `_parser` is updated to reflect that
  ownership is now expressed in the type, not just in prose.
* `init()` and `free_parser()` are audited: all paths that previously set
  `_parser = nullptr` after `ParseFree` are replaced with the `unique_ptr`
  equivalent.

### Constraints

* The lemon `ParseAlloc` / `Parse` / `ParseFree` / `ParseTrace` API is C —
  do not change its call signatures.
* `ParseAlloc` returns `void*` — the `unique_ptr` must be typed accordingly.
* Do not introduce `unique_ptr` for `_scanner`, `_session`, or `_tag` in
  this task — those are separate ownership redesigns with their own
  conditional-flag complexity. This task is scoped to `_parser` only.
* If the `unique_ptr` approach reveals a lemon API incompatibility, stop
  and report before implementing a workaround.

### TDD

The existing `TAGL::driver` tests are the contract — they must pass unchanged.
Add one test that constructs a `driver`, calls `finish()` (which resets the
parser), then re-uses the driver via `execute()` — proving the
init/free/reinit cycle works correctly under the new RAII ownership.

### Verify

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagl/tests
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

---

## Tests — Completion Command

All three tasks must pass before this phase is complete:

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

## Acceptance Criteria

* `[[nodiscard]]` applied to all `tagd::code`-returning methods where
  unchecked return is a programming error; intentional exceptions documented.
* Full build produces no new warnings. No suppressed nodiscard violations.
* `merge_tags` and `merge_tags_erase_diffs` use `extract()` — verified by
  existing tests plus one new merge-with-relations test.
* `TAGL::driver::_parser` is a `unique_ptr` with `ParseFree` deleter —
  verified by existing tests plus one new init/free/reinit cycle test.
* All existing tests pass. Full build clean. Each task's diff is independently
  reviewable.

## Deliverable: Concise Report

For each task:
1. Summary of changes.
2. Test results: exact command and output.
3. Open issues or non-trivial findings requiring follow-on work.
4. Suggested git commit message.
