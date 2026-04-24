# Task: Boundary Correctness — `httagd` vs `tagdb::sqlite` (Phase 5)

## Status

* COMPLETE: the boundary problem was resolved through the later Phase 6 implementation path; the only remaining gap was task-record reconciliation, which is archival/reporting work rather than unfinished implementation.

## Goal

Make the boundary between `httagd` (top-layer service) and `tagdb` (persistence abstraction) **honest and explicit**, without changing any observable HTTP behavior.

> `httagd` must not accidentally depend on sqlite implementation detail unless that dependency is explicitly named and justified.

Preserve identical behavior across:

* HTTP responses
* TAGL execution
* tagsh usage
* all existing tests

---

## Principles

* One seam only: `httagd` ↔ `tagdb::sqlite`
* Preserve truth — no behavior changes
* Prefer abstract `tagdb::tagdb` interface where possible
* Where sqlite-specific behavior is required:

  * make it explicit
  * document why it cannot be abstracted (yet)
* No premature abstraction or redesign

---

## Scope

### Read

* `httagd/include/httagd.h`
* `httagd/src/httagd.cc`
* `httagd/src/httagd-client.cc`
* `httagd/tests/Tester.h`
* `tagdb/include/tagdb.h`
* `tagdb/sqlite/include/tagdb/sqlite.h`
* `tagdb/sqlite/src/sqlite.cc`
* `tagsh/tests/DriverTester.h`

### Write

* `httagd/src/httagd.cc`
* `httagd/include/httagd.h`
* `httagd/tests/Tester.h`
* Minimal interface comments in `tagdb/sqlite/include/tagdb/sqlite.h` if needed

---

## Non-goals

* No sqlite redesign
* No schema or query changes
* No introduction of new abstraction layers
* No conversion to smart pointers
* No performance optimization
* No concept introduction
* No changes to TAGL parsing or semantics

---

## Type Classification

| Type             | Category                              |
| ---------------- | ------------------------------------- |
| `httagd` service | execution-context                     |
| `tagdb::tagdb`   | execution-context (abstract boundary) |
| `tagdb::sqlite`  | execution-context (implementation)    |

---

## Contract 0 — Usage Audit

Before any changes:

* Identify all uses of `tagdb::sqlite` in `httagd`
* For each call, classify:

| Category | Meaning                                       |
| -------- | --------------------------------------------- |
| A        | Can be expressed via `tagdb::tagdb` interface |
| B        | Requires sqlite-specific behavior             |
| C        | Ambiguous / unclear                           |

If any case is unclear → stop and report

**Deliverable (internal):**
A simple list of call sites with A/B/C classification

---

## Contract 1 — Eliminate accidental sqlite coupling

For all Category A call sites:

**What must be true after this contract:**

* Calls go through `tagdb::tagdb` interface
* No direct dependency on `tagdb::sqlite` methods
* No change in behavior

**TDD:**

* Existing `httagd/tests` must pass unchanged
* Add targeted tests only if necessary to prove boundary correctness

---

## Contract 2 — Make sqlite dependency explicit

For all Category B call sites:

**What must be true after this contract:**

* Each sqlite-specific call is:

  * clearly marked with a one-line comment:

    > "sqlite-specific: not part of tagdb abstraction — required for X"
* No hidden or accidental use of sqlite-only methods remains

Do NOT abstract these yet — only make them visible.

---

## Contract 3 — Boundary clarity in types

**What must be true after this contract:**

* Any `tagdb::sqlite*` or concrete usage in `httagd` is intentional and obvious
* Where possible without redesign:

  * prefer `tagdb::tagdb&` or `tagdb::tagdb*`
* If concrete type is required:

  * document why

No forced refactoring — only correctness and clarity

---

## Contract 4 — Test truth preservation

**What must be true after this contract:**

* All `httagd` tests pass unchanged
* All `tagsh` tests pass unchanged
* All `tagl` tests pass unchanged
* Full system build is clean

If any test fails:

* treat as regression
* stop and investigate

---

## Constraints

* Zero behavior change
* No hidden abstraction
* No widening of `tagdb` interface in this phase
* No changes to sqlite implementation logic
* No opportunistic cleanup
* If a change affects more than one seam → stop

---

## Tests

After each contract:

```bash
make -C tagd/httagd/tests
```

Full system verification:

```bash
make -C tagd
make -C tagd/tagl/tests
make -C tagd/tagsh/tests
```

---

## Acceptance Criteria

* All accidental sqlite coupling removed
* All intentional sqlite usage explicitly documented
* `httagd` clearly expresses dependency on `tagdb` abstraction
* No behavior changes
* All tests pass
* Diff is small, mechanical, and reviewable

---

## Deliverable: Concise Report

1. List of all sqlite call sites with classification (A/B)
2. Summary of changes per contract
3. Test results (commands + output)
4. Any ambiguous cases (Category C)
5. Suggested commit message

---

## Core Rule

> Do not redesign persistence. Make the boundary truthful.

This phase succeeds if:

* nothing behaves differently
* but it is now obvious where abstraction ends and implementation begins
