# Task: C++23 Correctness — `tagl` Phase 3

## Status

* PENDING: there is a stronger rewritten task document in `out/2026-04-18-chatgpt-tagl-cpp23-phase3-experts-razor-v2.md`, but no non-archive AAR in `out/*.md` confirms this task is complete; what is left is either the implementation closeout or an explicit completion report.

## Task

Bring the `tagl` execution-context seam into clearer C++23 correctness without changing the truth the system produces in TAGL, `tagsh`, or `httagd`. This phase is not a redesign. It makes existing execution-context types honest about ownership, lifetime, mutability, and copy/move semantics, and proves the existing `TokenText` lifetime contract with tests.

## Principles

* Preserve the same truth in:
  * tagd design contracts
  * TAGL language behavior
  * `tagsh` usage
  * `httagd` usage
* Execution-context types are not value types.
* TDD order is mandatory: test first, then implementation, then immediate cascading fixes, then verification.
* Keep the diff scoped, reviewable, and local to the stated seam.
* Comment why at ownership and lifetime boundaries, not what.

## Scope

### Read
* `tagl/include/tagl.h`
* `tagl/include/scanner.h`
* `tagl/src/tagl.cc`
* `tagl/src/scanner.cc`
* `tagl/tests/Tester.h`
* `tagsh/tests/DriverTester.h`
* `httagd/tests/Tester.h`
* `TASKS.d/2026-04-17-tagd-cpp-c23-phase1.md`
* `TASKS.d/2026-04-17-tagdb-sqlite-stmt-cache.md`
* `AGENTS.md`
* `docs/ai-assisted-dev-doctrine.md`

### Write
* `tagl/include/tagl.h`
* `tagl/include/scanner.h`
* `tagl/src/tagl.cc`
* `tagl/src/scanner.cc`
* `tagl/tests/Tester.h`
* Minimal cascading caller fixes in `tagsh/` or `httagd/` only if required to keep the build green.

### Non-goals
* No grammar changes.
* No parser changes.
* No generated file changes (`parser.h`, lemon output, re2c output).
* No new public abstractions.
* No concept introduction in this phase.
* No token redesign in this phase.
* No opportunistic cleanup outside the stated contracts.
* If broader changes are required beyond immediate cascading fixes: stop and report.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md` and `AGENTS.md`.

## Type Classification

Classify the seam before changing it:

| Type | Category |
| ---- | -------- |
| `TAGL::driver` | execution-context type |
| `TAGL::scanner` | execution-context type |
| `TAGL::callback` | execution-context type |
| `TAGL::token_store` | value type |
| `TAGL::TokenText` | view type |

Rule:

> Do not apply value-type rules to execution-context types.

## Required Contracts

### Contract 0 — Caller Audit

Before changing any header declarations:

* audit `tagl/`, `tagsh/`, and `httagd/` for any code that copies or moves:
  * `TAGL::driver`
  * `TAGL::scanner`
  * `TAGL::callback`
* if any legitimate copy or move dependency exists, stop and report before continuing

**TDD / verification:** add or update tests only if needed to prove no supported caller contract is being removed silently.

---

### Contract 1 — Explicitly delete copy and move on execution-context types

Apply explicit deletion to:

* `TAGL::driver`
* `TAGL::scanner`
* `TAGL::callback`

Required form:

```cpp
Type(const Type&) = delete;
Type& operator=(const Type&) = delete;
Type(Type&&) = delete;
Type& operator=(Type&&) = delete;
```

**What must be true after this contract:**

* these three types are explicitly non-copyable and non-movable
* the code states this directly instead of relying on accidental suppression or unsafe raw-pointer behavior
* behavior is unchanged

**TDD:** add static assertion tests proving:

* `std::is_copy_constructible_v<T>` is false
* `std::is_move_constructible_v<T>` is false

for all three types.

---

### Contract 2 — Const correctness on `driver`

Fix read-only access paths:

* `tdb()` gains a `const` overload
* `session_ptr()` getter gains a `const` overload
* `callback_ptr()` getter gains a `const` overload
* `is_setup()` becomes `const`

Do **not** make `lookup_pos()` const. Instead, document why it is not const if it may mutate error or diagnostic state through downstream calls.

**What must be true after this contract:**

* read-only access through `const TAGL::driver&` is supported where semantically correct
* overload changes do not change external system truth

**TDD:** write tests that call the corrected read-only accessors through a `const TAGL::driver&`. These tests must fail before the change and pass after.

---

### Contract 3 — Prove `TokenText` lifetime

`TokenText` is a view type. `TokenText::z` is non-owning and points into storage managed by `token_store`.

**What must be true after this contract:**

* the lifetime guarantee is proven by test, not only explained in comments
* repeated stores do not invalidate previously emitted `TokenText::z` pointers
* the existing `std::deque` choice in `token_store` remains justified by behavior

**TDD:** add a focused test that:

* stores multiple token texts
* retains earlier `TokenText` values
* verifies earlier pointers/text remain valid after later stores

---

### Contract 4 — Ownership and lifetime comments

Comment-only diff for enduring truths at the seam.

Document:

* `driver` owned vs conditionally owned vs non-owning members
* `_parser` lifecycle via `ParseAlloc` / `ParseFree`
* `_buf` ownership in `scanner`
* `token_store` uses `std::deque` for pointer stability
* `TokenText` is non-owning and depends on `token_store` lifetime

**Rule:** comment ownership and lifetime boundaries only. Do not add broad STL commentary that restates signatures.

## Constraints

* Preserve all existing behavior unless this task explicitly says otherwise.
* Tests are the source of truth for unchanged behavior.
* If a test must change because a previously implicit contract becomes explicit, document that as the next chosen TDD iteration feature instead of silently broadening scope.
* Preserve existing comments and TODOs unless factually wrong after the change.
* No introduction of concepts, `concepts.h`, `token.h`, new token abstractions, or parser-facing redesign in this phase.

## Tests

After each contract:

```bash
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagl/tests
```

Full build verification after Contract 2 and again at task completion:

```bash
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

Downstream truth verification if any cascading caller fix is required:

```bash
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagsh/tests
cd ~/sandbox/codex/tagd-workspace && make -C tagd/httagd/tests
```

## Acceptance Criteria

* `TAGL::driver`, `TAGL::scanner`, and `TAGL::callback` are explicitly non-copyable and non-movable.
* `driver` read-only accessors are const-correct where semantically appropriate.
* `TokenText` lifetime is proven by test.
* Ownership and lifetime boundaries are documented at the seam.
* `tagl` tests pass.
* Full build passes.
* If touched, downstream `tagsh` / `httagd` tests pass.
* The resulting diff is scoped, reviewable, and does not redesign the subsystem.

## Deliverable: Concise Report

1. Summary of changes per contract.
2. Test results with exact commands and output.
3. Open issues, caller findings, or follow-on task recommendations.
4. Suggested concise git commit message.
