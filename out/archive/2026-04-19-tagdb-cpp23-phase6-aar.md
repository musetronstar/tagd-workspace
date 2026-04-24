# After Action Report: C++23 Interface Correctness — `tagdb` Phase 6

**Task:** `TASKS.d/2026-04-18-chatgpt-tagdb-sqlite-phase6.md`
**Date completed:** 2026-04-19
**Branch:** `claude/http-client` (tagd inner repo)
**Status:** All deliverables complete. 55 tagdb tests pass. Full build clean.

Audit note:
- the referenced `TASKS.d` file is a draft Phase 6 prompt, not a full task spec
- this AAR records the implementation objective that was actually carried out
- see `out/2026-04-19-tagdb-phase4-6-audit-trail.md` for commit mapping,
  provenance limits, and the remaining process gaps

---

## Objective

Formalize the `tagdb::tagdb` vs `tagdb::sqlite` interface boundary:
- promote url/referent overloads to the abstract interface
- narrow `tagsh` and `httagd::server` to use `tagdb::tagdb*`
- document sqlite-only methods explicitly

Primary implementation commit in the inner `tagd` repo:
- `d2574fa` `httagd: route server db access through tagdb abstraction`

---

## Method Classification

### Promoted to `tagdb::tagdb`

Five overloads added as non-pure virtual with default dispatch to the
`abstract_tag` base overload. Backends with type-specific storage override them;
the `httagd::tagdb_tester` mock inherits the defaults without change.

| Method | Rationale |
|---|---|
| `get(url&, ...)` | Called by `tagsh_callback::cmd_get`; required for abstract-pointer dispatch |
| `put(url&, ...)` | Symmetric with `get`; cross-backend contract |
| `put(referent&, ...)` | Referent storage is a first-class operation |
| `del(url&, ...)` | Mirrors put symmetry |
| `del(referent&, ...)` | Mirrors put symmetry |

### Kept sqlite-only

`init()`, `open()`, `close()`, `refers_to()`, `refers()`, `related()`,
`search()`, `get_children()`, `query_referents()`, `term_pos()` — none
of these are called above the seam.

---

## Concrete Type Narrowing

**`tagsh.h`**:
- Removed `typedef tagdb::sqlite tagdb_type` and `#include "tagdb/sqlite.h"`
- Changed `_tdb`, `tagsh_callback`, and both `tagsh` constructors to `tagdb::tagdb*`

**`httagd.h`** (`httagd::server`):
- Constructor changed from `tagdb::sqlite*` to `tagdb::tagdb*`
- Removed stale comment that explained the sqlite dependency

**Concrete type stays in the right layer:**
- `tagsh/src/main.cc` — `tagdb::sqlite tdb` (entry point, owns the concrete object)
- `httagd/app/main.cc` — already `tagdb::sqlite tdb`, no change needed
- `tagsh/tests/DriverTester.h` and `LogTester.h` — added local `typedef tagdb::sqlite tagdb_type`

**`httagd/src/client-main.cc`**: Removed unused `#include "tagdb/sqlite.h"`.

---

## sqlite `override` annotations

Added `override` to `tagdb::sqlite`'s url/referent overloads to make the
vtable relationship explicit and grep-able.

---

## Contract Test Added

`SqliteTester::test_url_referent_overloads_dispatch_through_abstract_pointer` —
verifies that calling `put(url)`, `get(url)`, `del(url)`, `put(referent)`, and
`del(referent)` through a `tagdb::tagdb*` dispatches to the sqlite implementation.

---

## Pre-existing Segfaults

The `tagsh/tests` and `httagd/tests` suites segfault at runtime — confirmed
pre-existing before this branch. Not introduced or worsened by Phase 6 changes.

## Audit Trail Limits

This document should be read as an implementation closeout, not as proof that
Phase 6 had the same task-spec and test-first audit trail quality as Phase 4.

What is solid:
- the implementation objective is clear
- the code changes are identifiable
- current verification passes for `tagdb/tests` and full `make -C tagd`

What is weaker:
- the referenced Phase 6 task file remained a draft prompt
- the surviving history does not provide a formal contract-by-contract Phase 6
  task record in `TASKS.d`
