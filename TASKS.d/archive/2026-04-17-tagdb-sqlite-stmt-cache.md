# Task: SQLite Statement Cache Redesign — `tagdb` Phase 2b

## Status

* COMPLETE: all three contracts complete, all tests pass, full build clean per `out/2026-04-17-tagdb-sqlite-stmt-cache-aar.md`.

Replace the 30 per-member `sqlite3_stmt*` handles in `tagdb::sqlite` with an
`enum class`-keyed lazy statement cache. Statements are prepared on first use,
held for the connection lifetime, and finalized together at close/destruction.
This eliminates unused statement allocation, localizes RAII to the cache, and
leaves the door open for per-query finalization later without further restructuring.

## Principles

* Simple and correct now; optimize later.
* Preserve all existing behavior — this is a structural refactor, not a feature change.
* Keep the class interface minimal and abstract. Push SQLite-specific mechanics into
  `static` free functions in `sqlite.cc` — not into the class header.
* The existing `prepare()`, `bind_*()` abstraction is the leverage point; localize
  changes there rather than touching every call site directly.
* TDD order: tests first, then implementation.

## Scope

### Read
* `tagdb/sqlite/include/tagdb/sqlite.h`
* `tagdb/sqlite/src/sqlite.cc`
* `tagdb/sqlite/tests/Tester.h` (if present) — current test coverage baseline
* `tagd/tagd/tests/Tester.h` — style reference

### Write
* `tagdb/sqlite/include/tagdb/sqlite.h`
* `tagdb/sqlite/src/sqlite.cc`
* `tagdb/sqlite/tests/Tester.h` — add or extend tests

### Non-goals
* No per-query finalization — cache holds statements for connection lifetime. Note
  as TODO for future optimization.
* No changes to `tagdb.h`, `tagdb.cc`, or any module outside `tagdb/sqlite/`.
* No behavioral changes to any query, insert, update, or delete operation.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md` and `AGENTS.md`.

---

## Required Contracts

### Contract 1 — Define `enum class stmt_t` — COMPLETE

Define in `sqlite.h` (private section or just before the class):

```
enum class stmt_t {
    GET,
    EXISTS,
    TERM_POS,
    TERM_ID_POS,
    POS,
    REFERS_TO,
    REFERS,
    INSERT_TERM,
    UPDATE_TERM,
    DELETE_TERM,
    INSERT_FTS_TAG,
    UPDATE_FTS_TAG,
    DELETE_FTS_TAG,
    SEARCH,
    INSERT,
    UPDATE_TAG,
    UPDATE_RANKS,
    CHILD_RANKS,
    MAX_CHILD_RANK,
    INSERT_RELATIONS,
    INSERT_REFERENTS,
    DELETE_TAG,
    DELETE_SUBJECT_RELATIONS,
    DELETE_RELATION,
    DELETE_REFERS_TO,
    TERM_POS_OCCURENCE,
    GET_RELATIONS,
    RELATED,
    RELATED_MODIFIER,
    GET_CHILDREN
};
```

**What must be true after this contract:**
* All 30 per-member `sqlite3_stmt*` declarations in `sqlite.h` are removed.
* Replaced by a single: `std::unordered_map<stmt_t, sqlite3_stmt*, stmt_t_hash> _stmts;`
* Define `struct stmt_t_hash` alongside `enum class stmt_t` using `std::to_underlying()` —
  `std::unordered_map` requires an explicit hash for `enum class` keys; without one the
  code will fail to compile on some standard library implementations.
* `enum class stmt_t` is defined using `std::to_underlying()` where integer
  conversion is needed — no C-style casts.

**TDD:** No runtime behavior changes yet — this contract is header-only structural.
Confirm the build compiles (tests may fail until Contract 2 is complete).

---

### Contract 2 — Update `prepare()`, `bind_*()`, and `get_stmt()` — COMPLETE

**What must be true after this contract:**

* `prepare()` signature changes from `tagd::code prepare(sqlite3_stmt**, const char*, const char*)` to `tagd::code prepare(stmt_t, const char*, const char*)`. Internally it looks up or inserts into `_stmts` and prepares if not already present.
* A protected `sqlite3_stmt* get_stmt(stmt_t)` accessor returns the cached pointer for a given enum value. Returns `nullptr` if not yet prepared — callers must call `prepare()` first. All `bind_*` implementations must null-check the result and return a proper error rather than passing `nullptr` to SQLite.
* `bind_text()`, `bind_int()`, `bind_rowid()`, `bind_null()` signatures change from `sqlite3_stmt**` to `stmt_t`. Internally each calls `get_stmt()`.
* All 30 call sites in `sqlite.cc` updated: `&_foo_stmt` → `stmt_t::FOO`, and direct `sqlite3_step(_foo_stmt)` / `sqlite3_column_*(_foo_stmt, ...)` calls updated to use `get_stmt(stmt_t::FOO)`.
* `finalize()` iterates `_stmts`, calls `sqlite3_finalize()` on each value, and clears the map.
* `_term_pos_occurence_stmt` has a special pattern (manual `sqlite3_reset` / `sqlite3_clear_bindings` before rebind on repeated calls) — preserve this behavior via `get_stmt(stmt_t::TERM_POS_OCCURENCE)`.

**TDD:** All existing tests must pass after this contract.
Confirm with:
```
# feature test
cd tagd/ && make -C tagdb/sqlite/tests

# and full build:
-C tagd
```

---

### Contract 3 — Intent comments — COMPLETE

Comment-only diff after Contracts 1 and 2 pass.

| Site | Comment |
| ---- | ------- |
| `enum class stmt_t` | each enumerator names one prepared statement; cache key for lazy init |
| `_stmts` member | lazy cache — only statements actually used are prepared and held |
| `prepare(stmt_t, ...)` | prepares on first call; idempotent on subsequent calls for same key |
| `get_stmt()` | raw pointer accessor for bind/step/column calls after prepare |
| `finalize()` | finalizes all cached statements; called by close() and destructor |
| TODO above finalize | per-query finalization is a future optimization; current policy is connection-lifetime hold |

---

## Constraints

* Preserve all existing behavior — no query, result, or error path may change.
* `_term_pos_occurence_stmt` reset/rebind pattern must be preserved exactly.
* Do not add `noexcept` to `prepare()` or `get_stmt()` — SQLite calls can fail.
* State the source of truth explicitly if any call site behavior is uncertain.
* If a call site is ambiguous or the migration is non-mechanical at any point:
  stop and report before proceeding.

## Tests

After Contract 2:
```
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagdb/sqlite/tests
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

## Acceptance Criteria

* All 30 `sqlite3_stmt*` member declarations replaced by `_stmts` map.
* `enum class stmt_t` covers all 30 statement handles.
* `prepare()` and `bind_*()` accept `stmt_t`; no `sqlite3_stmt**` in public or protected interface.
* `finalize()` clears the map cleanly.
* All existing tests pass. Full build clean.
* Diff is mechanical and reviewable — no behavioral changes.

## Deliverable: Concise Report

1. Summary of changes per contract.
2. Test results: exact command and output.
3. Any non-mechanical call sites found — describe and await instruction.
4. Suggested git commit message per contract.

---

## Addendum: Implementation Guidance (from patch review)

Two patches were reviewed against this task. The following decisions reflect the
strongest elements of each and must be followed where they conflict with a naive reading
of the contracts above.

### `prepare()` — use reference into map

Inside `prepare(stmt_t stmt_id, ...)`, obtain a reference directly into the map:

```cpp
sqlite3_stmt *&stmt = _stmts[stmt_id];
```

This avoids a second lookup after insertion and is the correct C++23 idiom.
Do not use `find()` + separate insert.

### `bind_*()` — null guard required

Every `bind_text`, `bind_int`, `bind_rowid`, `bind_null` implementation must
null-check the pointer returned by `get_stmt()` before calling into SQLite:

```cpp
sqlite3_stmt *stmt = this->get_stmt(stmt_id);
if (stmt == nullptr)
    return this->ferror(tagd::TS_INTERNAL_ERR, "bind missing statement: %s", label);
```

Passing `nullptr` to `sqlite3_bind_*` is undefined behavior.

### `get_stmt()` in step/column loops — use a local variable

Where `sqlite3_step()` and `sqlite3_column_*()` are called in sequence or in a loop,
assign `get_stmt()` to a local variable once rather than calling it repeatedly:

```cpp
sqlite3_stmt *stmt = this->get_stmt(stmt_t::FOO);
while ((s_rc = sqlite3_step(stmt)) == SQLITE_ROW) {
    auto val = sqlite3_column_text(stmt, F_COL);
    ...
}
```

Repeated inline `get_stmt()` calls at every column access are noisy and do redundant
map lookups.

### Non-cached statements (`_init`, `dump` functions) — use `static` free functions

`_init` and several `dump` functions use local `sqlite3_stmt*` variables that are not
candidates for the cache (they are one-shot, scoped to the function). These must not
be migrated to `stmt_t`. Instead, extract `static` free functions in `sqlite.cc` for
the prepare/bind pattern they use:

```cpp
static tagd::code prepare_stmt(tagdb::sqlite*, sqlite3*, sqlite3_stmt**, const char*, const char*);
static tagd::code bind_text_stmt(tagdb::sqlite*, sqlite3_stmt**, int, const char*, const char*);
// etc.
```

`static` is required — these are translation-unit implementation details and must not
leak external linkage. This is the required approach; do not use private class overloads,
which would widen the header unnecessarily.

### `finalize_stmt` — update signature

Change `finalize_stmt` from `sqlite3_stmt**` to `sqlite3_stmt*&`:

```cpp
static void finalize_stmt(sqlite3_stmt *&stmt) {
    sqlite3_finalize(stmt);
    stmt = nullptr;
}
```

The reference form is more idiomatic C++23 and avoids double-dereference noise at call sites.

### `_related_modifier_stmt` — verify presence in enum and finalize

The original `finalize()` macro list omitted `_related_modifier_stmt`. Confirm it is
present in `enum class stmt_t` as `RELATED_MODIFIER` (it is listed) and that it is
covered by the map-based `finalize()` loop. No special action needed beyond confirming
coverage.
