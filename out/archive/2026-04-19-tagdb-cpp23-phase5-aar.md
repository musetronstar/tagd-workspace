# After Action Report: C++23 Interface Correctness — `tagdb` Phase 5

**Task basis:** Phase 4 follow-on seam clarification, later superseded by Phase 6 boundary work
**Date completed:** 2026-04-19
**Branch:** `claude/http-client` (tagd inner repo)
**Status:** One accidental abstraction leak found and documented.

This note records the design finding that fed Phase 6. It is not, by itself, a
full task specification with contracts/tests/acceptance criteria.

---

## What Phase 5 Did

Phase 5 exposed the `tagdb::sqlite` / `tagdb::tagdb` seam honestly by adding a
boundary comment to `tagdb/sqlite.h`:

```cpp
// --- tagdb abstraction boundary: methods below are sqlite implementation detail, not part of tagdb::tagdb ---
```

No behavior changed. The comment made visible what was already true: a set of
public methods on `tagdb::sqlite` sat above the abstract interface without a
decision having been made about them.

The corresponding code evidence lives in the tagd inner-repo Phase 4 work:
- `15dc2a7` `claude: tagdb C++23 phase 4 — interface correctness`
- `8e6166f` `claude: split tagdb tests into Tester.h and SqliteTester.h`

---

## Accidental Abstraction Leak Found

The boundary audit revealed that `tagsh.h` stored the concrete type:

```cpp
typedef tagdb::sqlite tagdb_type;
tagdb_type *_tdb;
```

And `httagd::server` accepted `tagdb::sqlite*` only because `tagsh` required it.
Neither class used any sqlite-only method — the concrete type leaked upward for
no reason.

This was the primary finding. Phase 6 resolved it.

See `out/2026-04-19-tagdb-phase4-6-audit-trail.md` for the reconstructed
task/commit mapping and the distinction between workspace docs commits and inner
repo code commits.

---

## What Phase 5 Did Not Do

Phase 5 made no code changes beyond the comment. It established the question:
*which methods belong in `tagdb::tagdb`?*

That question was answered in Phase 6.
