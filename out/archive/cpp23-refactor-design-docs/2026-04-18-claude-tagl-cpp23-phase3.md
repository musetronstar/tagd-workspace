# Task: C++23 Correctness — `tagl` Phase 3

Bring `TAGL::driver`, `TAGL::callback`, `TAGL::scanner`, and `TAGL::token_store`
into conformance with C++23 const correctness, Rule of Five, and STL alignment.
`tagl` sits above `tagd` and `tagdb` in the build order; correctness here propagates
into `tagsh` and `httagd`. Defects at this layer are amplified by every consumer.

Use `tokr::model` as the value-type reference pattern. Use the Phase 1 (`tagd`) and
Phase 2b (`tagdb/sqlite`) task files as structural and doctrine references.

## Principles

* Keep class interfaces minimal and abstract — push implementation mechanics into
  `static` free functions in `.cc` files, not into headers.
* TDD order is mandatory: each contract is tested first, then implemented.
* Each TDD iteration completes one contract end-to-end: write the test, implement
  the change, fix immediate cascading compile/test consequences, verify integration.
* Comment *why* at every STL protocol site — not *what*.
* Generated files (`parser.cc`, `scanner.out.cc`, `scanner.tagdurl.cc`) are
  out of scope — do not modify them.

## Scope

### Read
* `tagl/include/tagl.h`
* `tagl/include/scanner.h`
* `tagl/include/parser.h`
* `tagl/src/tagl.cc`
* `tagl/src/scanner.cc`
* `tagl/tests/Tester.h`
* `tagd/tagd/tests/Tester.h` — test coverage reference
* `hardF/tokr/include/model.h` — STL reference pattern

### Write
* `tagl/include/tagl.h`
* `tagl/include/scanner.h`
* `tagl/src/tagl.cc`
* `tagl/src/scanner.cc`
* `tagl/tests/Tester.h`
* Cascading caller fixes in `tagsh/` or `httagd/` required to keep the build green.

### Non-goals
* No changes to generated parser/scanner files.
* No changes to `parser.h` (generated token definitions).
* No behavioral changes to parsing, scanning, or callback dispatch.
* No opportunistic cleanup outside the stated contracts.
* If broader changes are required beyond immediate cascading fixes: stop and report.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md` and `AGENTS.md`.

---

## Findings

### `TAGL::driver` — SIGNIFICANTLY NOT ALIGNED

**Rule of Five violation — same defect as `tagd::abstract_tag` in Phase 1:**
`driver` declares `virtual ~driver()`. This suppresses compiler-generated move
constructor and move assignment. `driver` manages several owned resources
(`_scanner`, `_parser`, `_session`, `_tag`) via raw pointers with manual
delete logic in the destructor. Without explicit move operations, any context
that moves or copies a `driver` silently copies raw pointers — a double-free
waiting to happen.

**Ownership semantics are undocumented:**
* `_own_scanner` and `_own_session` flags gate deletion in the destructor —
  a manual ownership protocol that is invisible at the call site.
* `_tag` is always owned (deleted in destructor and `delete_tag()`) but nothing
  documents this.
* `_parser` is a raw `void*` (lemon parser context) managed by `ParseAlloc` /
  `ParseFree` — not deletable via `delete`. This must be documented and must
  not be touched by any compiler-generated copy/move.
* `_callback` is non-owning (not deleted in destructor) — undocumented.

**`driver` is not copyable or movable by design** — the combination of raw
`void* _parser`, conditional ownership flags, and lemon parser state makes
general copy/move semantics unsafe. The correct C++23 resolution is to
explicitly delete copy and move, document why, and ensure the destructor
handles all owned resources correctly.

**Const correctness gaps:**
* `tdb()` returns `tagdb::tagdb*` — should have a `const` overload returning
  `const tagdb::tagdb*`.
* `session_ptr()` getter returns `tagdb::session*` — should have a `const`
  overload.
* `callback_ptr()` getter returns `callback*` — should have a `const` overload.
* `tag_ptr()` getter returns `tagd::abstract_tag*` — `const` overload already
  present. ✓
* `is_setup()` — reads only; should be `const`.
* `lookup_pos()` — calls `_tdb->pos()` which may mutate errorable state;
  cannot be `const`. Document this explicitly.

### `TAGL::callback` — PARTIALLY ALIGNED

`callback` declares `virtual ~callback()` — same Rule of Five implication.
However, `callback` holds only a single raw `driver*` pointer that is
non-owning (set by `driver::bind_callback`, not deleted in destructor).
Copy/move would silently alias the pointer. Correct resolution: explicitly
delete copy and move, document the non-owning pointer.

Pure virtual interface is otherwise correctly designed. No further gaps.

### `TAGL::token_store` — PARTIALLY ALIGNED

`token_store` wraps `std::deque<std::string>` — compiler-generated
copy/move/swap are correct and sufficient. But:
* No explicit special members documenting that compiler-generated are intentional.
* `size()` and `empty()` are `const` ✓. `clear()` is non-const ✓.
* `store()` overloads take `const char*` and `const std::string&` — correct.
* `store_text()` overloads return `TokenText` by value — correct.
* No comment explaining why `std::deque` is used over `std::vector`
  (pointer stability on push — `deque` does not invalidate references on
  `push_back`, which matters because `TokenText::z` points into stored strings).

### `TAGL::scanner` — PARTIALLY ALIGNED

`scanner` declares `virtual ~scanner()` — same Rule of Five implication.
`scanner` owns `_buf` (raw `char*`, heap-allocated) and holds non-owning
pointers to the driver and evbuffer. Copy/move would silently alias `_buf`.
Correct resolution: explicitly delete copy and move.

`scanner::tagdurl` subclass adds no new data members — confirm and document.

### `TAGL::TokenText` — ALIGNED

Plain aggregate of `const char*` and `int`. Compiler-generated special members
are correct. `empty()` and `str()` are `const` ✓. No action needed beyond a
comment documenting that the pointer is non-owning and lifetime is managed by
`token_store`.

---

## Required Contracts

### Contract 1 — Explicitly delete copy and move on non-copyable types

**What must be true after this contract:**
* `driver`: copy constructor, copy assignment, move constructor, move assignment
  all explicitly `= delete`. Intent comment explaining why: `void* _parser` is a
  lemon context managed by `ParseAlloc`/`ParseFree`; conditional ownership flags
  make general copy/move unsafe.
* `callback`: copy and move explicitly `= delete`. Intent comment: non-owning
  `driver*` pointer; aliasing via copy is a latent bug.
* `scanner`: copy and move explicitly `= delete`. Intent comment: owns `_buf`
  (raw heap allocation); copy would double-free.

**TDD:** Write tests that assert `std::is_copy_constructible<T>` is false and
`std::is_move_constructible<T>` is false for each of the three types. Tests must
pass against existing code (the types are already non-copyable in practice;
this makes the contract explicit and guards against accidental re-enabling).

---

### Contract 2 — Const correctness on `driver`

**What must be true after this contract:**
* `tdb()` has a `const` overload returning `const tagdb::tagdb*`.
* `session_ptr()` getter has a `const` overload returning `const tagdb::session*`.
* `callback_ptr()` getter has a `const` overload returning `const callback*`.
* `is_setup()` is `const`.
* `lookup_pos()` carries an intent comment explaining why it cannot be `const`
  (mutates errorable state via `_tdb->pos()`).

Before changing each signature, audit all callers in `tagl/`, `tagsh/`,
`httagd/`. Apply cascading fixes where required. If a caller change is
non-trivial, stop and report.

**TDD:** Write tests that call each corrected accessor through a `const driver&`
reference. Tests must fail to compile before the fix and pass after.

---

### Contract 3 — Document `token_store` and `TokenText` design intent

**What must be true after this contract:**
* Comment above `token_store` explaining why `std::deque` is chosen:
  pointer stability on `push_back` — `TokenText::z` points into stored strings
  and must not be invalidated by subsequent stores.
* Comment above `TokenText` explaining that `z` is non-owning; lifetime is
  managed by the `token_store` that produced it.
* Comment on explicit special members of `token_store` stating that
  compiler-generated copy/move/swap are sufficient (all members are STL
  containers with correct value semantics).

**This contract is comment-only. Zero lines of code change.**

---

### Contract 4 — Intent comments at all STL protocol sites

**Prerequisite:** Contracts 1–3 complete and passing.

**What must be true after this contract:**

| Site | Comment needed |
| ---- | -------------- |
| `driver` deleted copy/move | why lemon `void*` and ownership flags make copy/move unsafe |
| `driver::~driver()` | which members are owned (`_scanner` conditionally, `_parser` via ParseFree, `_tag` always, `_session` conditionally) and which are non-owning (`_callback`) |
| `driver::_own_scanner` / `_own_session` | manual ownership protocol — why flags instead of `unique_ptr` (lemon context is `void*`, not deletable uniformly) |
| `callback` deleted copy/move | non-owning `driver*` — aliasing via copy is a latent bug |
| `scanner` deleted copy/move | owns `_buf` raw heap allocation |
| `token_store` struct | see Contract 3 |
| `TokenText` struct | see Contract 3 |

**Comment-only diff. Zero lines of code change.**

---

## Constraints

* Generated files (`parser.cc`, `scanner.out.cc`, `scanner.tagdurl.cc`,
  `parser.h`) must not be modified.
* `void* _parser` must not be touched by any new special member — it is managed
  exclusively by `ParseAlloc` / `ParseFree`.
* Do not introduce `std::unique_ptr` for `_parser` — the lemon API requires
  `void*` and `ParseFree` with a custom deleter; this is a follow-on redesign,
  not in scope here.
* Preserve all existing comments and TODOs unless factually wrong after the change.
* If a subclass audit reveals additional data members, stop and report before
  implementing subclass-specific operations.

## Tests

Verify after each contract:
```
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagl/tests
```

Full build verify after Contract 2:
```
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

## Acceptance Criteria

* `driver`, `callback`, `scanner` are explicitly non-copyable and non-movable.
* `std::is_copy_constructible` and `std::is_move_constructible` are false for
  all three types — verified by tests.
* `tdb()`, `session_ptr()`, `callback_ptr()`, `is_setup()` are const-correct.
* `token_store` and `TokenText` carry intent comments explaining `deque` choice
  and pointer lifetime.
* Every STL protocol site carries an intent comment.
* All tests pass. Full build clean. Diff is scoped and reviewable.

## Deliverable: Concise Report

1. Summary of changes per contract.
2. Test results: exact command and output after each contract.
3. Open issues — any subclass findings or caller changes requiring follow-on work.
4. Suggested git commit message per contract.
