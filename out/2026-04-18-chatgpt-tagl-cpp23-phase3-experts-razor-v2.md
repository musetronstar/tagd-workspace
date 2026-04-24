# Task: C++23 Correctness — `tagl` Phase 3 (Experts Razor)

## Goal

Make `tagl` execution-context types honest about:

* ownership
* lifetime
* mutability

without changing system truth.

> Output must remain identical for all inputs.

---

## Principles

* Preserve system truth (TAGL, tagsh, httagd)
* TDD: tests first
* No redesign — only contract enforcement
* Execution-context types are NOT value types

---

## Scope

### Read

* `tagl/include/tagl.h`
* `tagl/include/scanner.h`
* `tagl/src/tagl.cc`
* `tagl/src/scanner.cc`
* `tagl/tests/Tester.h`

### Write

* same files
* minimal downstream fixes only if required

---

## Non-goals

* No grammar changes
* No parser changes
* No new abstractions
* No concepts
* No token redesign

---

## Type Classification

| Type          | Category          |
| ------------- | ----------------- |
| `driver`      | execution-context |
| `scanner`     | execution-context |
| `callback`    | execution-context |
| `token_store` | value type        |
| `TokenText`   | view type         |

---

## Contract 0 — Caller Audit

Before changes:

* verify no code relies on copying `driver`, `scanner`, `callback`
* search all modules
* if found → stop and report

---

## Contract 1 — Delete copy/move

Apply:

* `driver`
* `scanner`
* `callback`

```cpp
driver(const driver&) = delete;
driver& operator=(const driver&) = delete;
driver(driver&&) = delete;
driver& operator=(driver&&) = delete;
```

### Requirement

Types must already behave as non-copyable in practice.

---

## Contract 2 — Const correctness

Fix:

* `tdb()` → const overload
* `session_ptr()` → const overload
* `callback_ptr()` → const overload
* `is_setup()` → const

### Constraint

No change to behavior.

### Test

Must compile through `const driver&`.

---

## Contract 3 — Token lifetime proof

`TokenText::z` must remain valid.

### Add test:

* store multiple tokens
* verify earlier tokens still valid
* prove no invalidation

### Reason

`token_store` uses `std::deque` for pointer stability.

---

## Contract 4 — Ownership clarity (comments only)

Document:

* owned vs conditional vs non-owning
* `_parser` lifecycle (ParseAlloc / ParseFree)
* `_buf` ownership in scanner
* `TokenText` is non-owning

---

## Constraints

* no change to output
* no change to behavior
* no abstraction changes
* no concept introduction

---

## Tests

After each contract:

```bash
make -C tagd/tagl/tests
```

Full build:

```bash
make -C tagd
```

---

## Acceptance Criteria

* execution-context types explicitly non-copyable
* const-correct driver interface
* token lifetime proven by test
* ownership documented
* all tests pass unchanged

---

## Deliverable

1. summary of changes
2. test results
3. open issues
4. commit message

---

## Core Rule

> Do not redesign the system. Make the current system truthful.

