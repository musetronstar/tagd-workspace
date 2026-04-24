# Task: C++23 Interface Correctness — `tagdb` Phase 4

## Status

* COMPLETE: all four contracts complete, tests pass, and full build is clean per `out/2026-04-19-tagdb-cpp23-phase4-aar.md`.

Bring `tagdb::tagdb` and `tagdb::session` into conformance with the same C++23 honesty standard now established in `tagd` Phase 1 and `tagl` Phase 3: execution-context types must say so in the type system, ownership boundaries must be explicit, and the abstract `tagdb` interface must be clearly distinguished from `tagdb::sqlite` implementation detail. Preserve all existing tagdb, TAGL, tagsh, and httagd behavior. This phase tightens the interface contract; it does not redesign persistence.

## Principles

* Keep the seam narrow: `tagdb/include/tagdb.h` is the primary contract.
* Preserve existing behavior — this is interface correctness and documentation work, not a feature change.
* `tagdb::tagdb` is an execution-context type, not a value type.
* `tagdb::session` is a small stateful helper whose copy semantics are already explicit because of `std::atomic`; make that intent visible.
* Comment why at ownership and STL protocol sites — not what.
* TDD order is mandatory: each contract is tested first, then implemented, then verified through required downstream layers.

## Scope

### Read

* `tagdb/include/tagdb.h`
* `tagdb/src/tagdb.cc`
* `tagdb/sqlite/include/tagdb/sqlite.h`
* `tagdb/sqlite/src/sqlite.cc`
* `tagdb/tests/Tester.h`
* `tagl/include/tagl.h` — downstream consumer reference
* `tagsh/tests/DriverTester.h` — downstream usage reference
* `httagd/include/httagd.h` and `httagd/src/httagd.cc` — top-layer consumer reference
* `TASKS.d/2026-04-17-tagd-cpp-c23-phase1.md`
* `TASKS.d/2026-04-17-tagdb-sqlite-stmt-cache.md`
* `TASKS.d/2026-04-18-chatgpt-tagl-cpp23-phase3-task.md`

### Write

* `tagdb/include/tagdb.h`
* `tagdb/src/tagdb.cc`
* `tagdb/tests/Tester.h`
* Minimal cascading caller fixes in `tagl/`, `tagsh/`, or `httagd/` required to keep the build green.

### Non-goals

* No sqlite statement-cache changes — that work is already completed in Phase 2b.
* No redesign of the `tagdb::sqlite` class shape in this phase.
* No replacement of raw `session*` with smart pointers in this phase.
* No new persistence behavior, query behavior, or schema behavior.
* No opportunistic cleanup outside the stated contracts.
* If broader interface surgery is required beyond the contracts below: stop and report.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md` and `AGENTS.md`.

> Do not apply value-type expectations to `tagdb::tagdb` merely because it is a class with a virtual destructor.

---

## Contract 0 — Interface boundary audit — COMPLETE

Before changing signatures or special members:

* Audit `tagdb::tagdb` public API.
* Audit `tagdb::sqlite` public API against the abstract base.
* Identify which `sqlite` public methods are implementation-only and not part of the `tagdb` abstraction.
* Search downstream callers in `tagl/`, `tagsh/`, and `httagd/` for:

  * copies or moves of `tagdb::tagdb` or `tagdb::sqlite`
  * assumptions about `new_session()` ownership
  * direct use of `tagdb::sqlite` methods outside the abstract `tagdb` contract

If any legitimate copy/move caller exists, or if interface-boundary violations are non-trivial, stop and report before Contract 1.

---

## Contract 1 — Explicitly delete copy and move on `tagdb::tagdb` — COMPLETE

* `tagdb::tagdb` explicitly deletes:

  * copy constructor
  * copy assignment
  * move constructor
  * move assignment
* Intent comment explains why:

  * abstract interface
  * virtual destructor
  * execution-context semantics
  * open resource / database lifetime make general copy/move unsafe
* `tagdb::sqlite` is audited against this contract. If it needs explicit deletion for clarity, apply it in the smallest reviewable way required to keep the build honest.

**TDD:** Add static-assert tests proving `std::is_copy_constructible_v<tagdb::tagdb>` and `std::is_move_constructible_v<tagdb::tagdb>` are both false. If `tagdb::sqlite` is made explicit too, prove the same for `tagdb::sqlite`.

---

## Contract 2 — Make `session` intent visible — COMPLETE

* `tagdb::session` special members remain behaviorally unchanged.
* Intent comment explains why explicit copy constructor and assignment exist:

  * `std::atomic<uint64_t>` suppresses implicit copy/move
  * `_sequence.load()` / `_sequence.store()` preserve the intended state transfer
* If `session` has read-only accessors that should be `const`, correct them.
* No new ownership model is introduced in this contract.

**TDD:** Add or extend tests proving the current `session` copy behavior still works as designed. This is a preservation test, not a redesign test.

---

## Contract 3 — Document `new_session()` ownership and lifetime — COMPLETE

* The ownership expectation of `new_session()` is documented at the declaration site.
* The relationship between:

  * `get_session()`
  * `new_session()`
  * caller responsibility
  * stack/session-copy use versus raw pointer lifetime
    is made explicit in the interface comments.
* If a caller currently relies on undocumented ownership, document the current truth rather than redesigning it here.

**TDD:** Add tests at the boundary that prove the documented current usage pattern. If this cannot be proved without redesign, stop and report; do not guess.

---

## Contract 4 — Interface-boundary comments on `tagdb::sqlite` — COMPLETE

Comment-only unless a minimal signature visibility adjustment is required to keep the contract honest.

* The existing TODO / design concern in `sqlite.h` about public methods outside the abstract base is resolved into one of:

  * a concise intent comment plus follow-on note, if no safe local tightening can be done in this phase
  * or a minimal visibility tightening that does not broaden scope
* The task must clearly distinguish:

  * what belongs to the `tagdb` abstraction
  * what is sqlite implementation detail

This contract is successful if the boundary is clearer and future work can be tasked cleanly.

**TDD:** No new runtime behavior tests required unless a visibility change forces a caller adjustment.

---

## Constraints

* Preserve existing comments and TODOs unless they are factually wrong after the change.
* If a caller fix outside `tagdb/` is required, keep it minimal and directly tied to one contract.

## Tests

After each contract: `make -C tagd/tagdb/tests`

Full build verify after Contract 3: `make -C tagd`

If a contract changes a top-layer usage boundary: `make -C tagd/tagsh/tests` and/or `make -C tagd/httagd/tests`

## Acceptance Criteria

* `tagdb::tagdb` is explicitly non-copyable and non-movable.
* `tagdb::session` copy semantics are preserved and documented.
* `new_session()` ownership/lifetime expectation is documented at the interface boundary.
* The distinction between abstract `tagdb` contract and `sqlite` implementation detail is clearer than before.
* All required tests pass. Full build clean.
* Diff is scoped, reviewable, and contains no unrelated changes.

## Deliverable: Concise Report

1. Summary of changes per contract.
2. Test results: exact commands and outputs.
3. Open issues — especially any `sqlite` interface-boundary follow-on work.
4. Suggested concise git commit message.
