# After Action Report: SQLite Statement Cache Redesign — `tagdb` Phase 2b

**Task:** `TASKS.d/2026-04-17-tagdb-sqlite-stmt-cache.md`
**Date completed:** 2026-04-18
**Branch:** `claude/http-client` (tagd inner repo)
**Status:** All three contracts complete. All tests pass. Full build clean.

---

## Contract 1 — Define `enum class stmt_t`

**Changes:**
- `sqlite.h`: All 30 per-member `sqlite3_stmt*` declarations removed. Replaced by a single `std::unordered_map<stmt_t, sqlite3_stmt*, stmt_t_hash> _stmts` with intent comment ("lazy cache — only statements actually used are prepared and held").
- `sqlite.h`: `enum class stmt_t` defined with all 30 enumerators (GET through GET_CHILDREN), with intent comment ("each enumerator names one prepared statement; cache key for lazy init").
- `sqlite.h`: `struct stmt_t_hash` defined alongside `enum class stmt_t`, using `std::to_underlying()` for the hash — required because `std::unordered_map` has no built-in hash for `enum class` keys.
- Build-only contract: no behavioral changes, compile confirmed.

**Commit:** `d72458f` (combined with Contract 2)

---

## Contract 2 — Update `prepare()`, `bind_*()`, and `get_stmt()`

**Changes:**
- `sqlite.h`: `prepare()` signature changed from `tagd::code prepare(sqlite3_stmt**, const char*, const char*)` to `tagd::code prepare(stmt_t, const char*, const char*)`. Internally uses `sqlite3_stmt *&stmt = _stmts[stmt_id]` — a direct reference into the map, avoiding a second lookup after insertion.
- `sqlite.h`: `sqlite3_stmt* get_stmt(stmt_t)` accessor added (protected); returns the cached pointer or `nullptr` if not yet prepared.
- `sqlite.h`: `bind_text()`, `bind_int()`, `bind_rowid()`, `bind_null()` signatures changed from `sqlite3_stmt**` to `stmt_t`. Each calls `get_stmt()` internally with a null guard: if `get_stmt()` returns `nullptr`, returns `ferror(TS_INTERNAL_ERR, ...)` rather than passing `nullptr` to SQLite (which would be undefined behavior).
- `sqlite.h`: `finalize()` updated to iterate `_stmts`, call `sqlite3_finalize()` on each value, then `_stmts.clear()`.
- `sqlite.cc`: All 30 call sites migrated: `&_foo_stmt` → `stmt_t::FOO`, and direct `sqlite3_step(_foo_stmt)` / `sqlite3_column_*(_foo_stmt, ...)` calls updated to use a local `sqlite3_stmt *stmt = this->get_stmt(stmt_t::FOO)` variable — assigned once, not called repeatedly per column access.
- `sqlite.cc`: `_term_pos_occurence_stmt` manual reset/rebind pattern preserved exactly via `get_stmt(stmt_t::TERM_POS_OCCURENCE)`.
- `sqlite.cc`: `finalize_stmt` signature changed from `sqlite3_stmt**` to `sqlite3_stmt*&` — more idiomatic C++23, avoids double-dereference noise.

**Non-cached (one-shot) statements:** `_init` and dump functions use local `sqlite3_stmt*` variables scoped to the function — these were not migrated to `stmt_t`. Instead, `static` free functions were extracted in `sqlite.cc`: `prepare_stmt`, `bind_text_stmt`, `bind_int_stmt`, `bind_rowid_stmt`, `bind_null_stmt`, `finalize_stmt`. All marked `static` — translation-unit implementation details that must not leak external linkage. This approach was mandated by the task addendum to avoid widening the class header unnecessarily.

**`RELATED_MODIFIER` coverage confirmed:** The original per-member macro list omitted `_related_modifier_stmt`. Confirmed present in `enum class stmt_t` as `RELATED_MODIFIER` and covered by the map-based `finalize()` loop. No special action required.

**Commits:** `d72458f` (main refactor), `4669415` (restore missing `stmt_t::` prefix), `48bcac3` (addendum improvements: static free functions, null guards, local variable for step/column loops, new tests)

---

## Contract 3 — Intent Comments

**Comment-only diff applied after Contracts 1 and 2 passed:**

| Site | Comment |
| ---- | ------- |
| `enum class stmt_t` | each enumerator names one prepared statement; cache key for lazy init |
| `_stmts` member | lazy cache — only statements actually used are prepared and held |
| `prepare(stmt_t, ...)` | prepares on first call; idempotent (reset+rebind) on subsequent calls for same key |
| `get_stmt()` | raw pointer accessor for bind/step/column calls after prepare |
| `finalize()` | finalizes all cached statements; called by close() and destructor |
| TODO above finalize | per-query finalization is a future optimization; current policy is connection-lifetime hold |

**Commits:** `48bcac3` (included with addendum improvements)

---

## Verification

### Contract 2 — Feature tests

```sh
$ make -C tagdb/tests
make: Entering directory '/home/inc/sandbox/claude/tagd-workspace/tagd/tagdb/tests'
cxxtestgen --error-printer Tester.h -o tester.cc
g++ -std=c++23 -Wall -Wextra -Wno-unused-result -O3 -o ./tester tester.cc -I../include -I../../tagd/include -I../sqlite/include -L../lib -ltagdb-sqlite -L../../tagd/lib -ltagd -lsqlite3
./tester
Running cxxtest tests (52 tests)....................................................OK!
make: Leaving directory '/home/inc/sandbox/claude/tagd-workspace/tagd/tagdb/tests'
```

### Full build

```sh
$ make -C .
make: Entering directory '/home/inc/sandbox/claude/tagd-workspace/tagd'
[make] tagd build
[build] tagd/src
make[2]: Nothing to be done for 'all'.
[build] tagd/src/domain
make[2]: Nothing to be done for 'all'.
[make] tagdb build
[build] tagdb/src
make[2]: Nothing to be done for 'all'.
[build] tagdb/sqlite
make[3]: Nothing to be done for 'all'.
[make] tagl build
[build] tagl/src
make[2]: Nothing to be done for 'all'.
[make] tagsh build
[build] tagsh/src
make[2]: Nothing to be done for 'all'.
[make] httagd build
[build] httagd/src
make[2]: Nothing to be done for 'all'.
[build] httagd/app
make[2]: Nothing to be done for 'all'.
make: Leaving directory '/home/inc/sandbox/claude/tagd-workspace/tagd'
```

---

## Non-Mechanical Call Sites

None. The migration from `&_foo_stmt` → `stmt_t::FOO` was mechanical across all 30 call sites. The `TERM_POS_OCCURENCE` reset/rebind pattern was the only structurally special case, and it was preserved without modification.

---

## Acceptance Criteria Checklist

- [x] All 30 `sqlite3_stmt*` member declarations replaced by `_stmts` map
- [x] `enum class stmt_t` covers all 30 statement handles (including `RELATED_MODIFIER`)
- [x] `prepare()` and `bind_*()` accept `stmt_t`; no `sqlite3_stmt**` in public or protected interface
- [x] `get_stmt()` null-guards all `bind_*` implementations
- [x] `finalize()` clears the map cleanly
- [x] Non-cached statements use `static` free functions in `sqlite.cc`, not class overloads
- [x] `finalize_stmt` uses `sqlite3_stmt*&` (reference form)
- [x] All existing tests pass (52 tests). Full build clean.
- [x] Diff is mechanical and reviewable — no behavioral changes
