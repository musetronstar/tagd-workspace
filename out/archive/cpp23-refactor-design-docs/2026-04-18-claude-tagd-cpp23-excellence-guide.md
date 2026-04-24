# `tagd` C++23 Engineering Excellence — Refactoring Guide

**Type:** Living reference document. Read at session start when working on any
C++23 refactoring task in the `tagd` repository.

**Purpose:** Define the complete path from the current state of the `tagd`
codebase to C++23 Engineering Excellence, ordered by the mathematical structure
of the system itself. This document is the compass. Task files are the missions.

---

## The Razor

> *Imagine Stroustrup, the STL authors, and Meyers inspecting this code.
> What would they change, and in what order?*

Their answer would not be "modernize syntax." It would be:
**make the code say what it means.** Ownership, lifetimes, ordering contracts,
const boundaries — every invariant the system has should be visible in the type
system, not inferred from reading three files.

The `tagd` math document gives us something most codebases lack: a precise
formal model of what the system is. Tags are points in a topological space.
Ranks encode a partial order. The tagspace is its own specification. This is
not a metaphor — it is a theorem. C++23 gives us the tools to make the code
as honest as the math.

---

## The Mathematical Spine

The `tagd` math document identifies these structures, each of which has a
direct C++ correspondence:

| Mathematical structure | `tagd` realization | C++ concern |
| ---------------------- | ------------------ | ----------- |
| Set of tags T | `tagd::tag_set = std::set<abstract_tag>` | Value type correctness, `operator<` contract |
| Partial order (⊑) | `rank::contains()`, rank prefix | `operator<=>`, `std::strong_ordering` candidate |
| Lexicographic total order | `rank::operator<` | `noexcept`, `std::totally_ordered` concept |
| Rooted tree | subordinate relation, `_entity` root | Invariant enforcement, hard tag immutability |
| Fiber / predicate set | `predicate_set` at each tag | `operator<` on `predicate`, const correctness |
| Continuous map | `merge_containing_tags` | Move semantics, `tag_set` efficiency |
| Canonical serialization | `dump()` | Rank-aware ordering (planned, see TODO) |
| Hard tag universal base | `hard-tags.h` | `constexpr`, compile-time invariants |

The refactoring order follows this spine. Fix what the math says is foundational
before fixing what depends on it.

---

## Completed Work

### Phase 1 — `tagd/tagd/` (`abstract_tag`, `predicate`, `tag_set`) ✓

**Task:** `TASKS.d/2026-04-17-tagd-cpp-c23-phase1.md`
**AAR:** `out/2026-04-17-tagd-cpp23-phase1-aar.md`

Completed contracts:
* Rule of Five: `abstract_tag` now has explicit move constructor, move assignment,
  member `swap`, ADL free `swap`. `std::is_nothrow_move_constructible` is true.
* `operator<` / `operator==` divergence documented: `<` is identity ordering for
  `tag_set` membership; `==` is deep equality. Tested and commented.
* Const correctness: `tag_set_equal`, `errorable::last_error_relation`,
  `errorable::most_severe` corrected.
* Intent comments at all STL protocol sites.
* 141 tests passing across all modules.

Open (carried forward):
* `predicate::operator<` cannot be `noexcept` — `cmp_modifier_lt` calls
  `std::stold` which throws on malformed modifier strings. Documented in header.
* `merge_tags` copy/erase/reinsert not yet replaced with `extract()` — TODO in code.
* Rank-aware `operator<` and `operator==` — planned for activation feature.
  TODO comments placed above both operators.

### Phase 2b — `tagdb/sqlite/` (statement cache) ✓

**Task:** `TASKS.d/2026-04-17-tagdb-sqlite-stmt-cache.md`
**AAR:** `out/2026-04-17-tagdb-sqlite-stmt-cache-aar.md`

Completed contracts:
* 30 per-member `sqlite3_stmt*` handles replaced with
  `std::unordered_map<stmt_t, sqlite3_stmt*, stmt_t_hash> _stmts`.
* `enum class stmt_t` with `stmt_t_hash` using `std::to_underlying()`.
* `prepare(stmt_t, ...)` uses direct map reference (`sqlite3_stmt *&stmt = _stmts[k]`).
* All `bind_*` implementations null-guard `get_stmt()` return.
* Non-cached (one-shot) statements use `static` free functions in `sqlite.cc`.
* `finalize_stmt` signature updated to `sqlite3_stmt*&`.
* 52 tests passing.

---

## Current Work

### Phase 3 — `tagl/` (`driver`, `callback`, `scanner`, `token_store`)

**Task:** `TASKS.d/2026-04-18-tagl-cpp23-phase3.md`
**Status:** In progress.

Key findings:
* `driver` is silently non-movable (virtual destructor suppresses move).
  Ownership of five members is undocumented and mixed (owned/conditional/non-owning).
* `callback` and `scanner` have the same virtual destructor / deletion gap.
* `driver` const gaps: `tdb()`, `session_ptr()`, `callback_ptr()`, `is_setup()`.
* `token_store` uses `std::deque` for reference stability — correct but undocumented.
* `TokenText::z` is a non-owning pointer into `token_store` storage — undocumented.

---

## Planned Work — Ordered by Dependency

### Phase 4 — `tagdb/tagdb.h` / `tagdb.cc` (interface correctness)

**Not yet tasked.**

Priority findings from prior analysis:
* `tagdb::tagdb` abstract interface has no `swap`, no explicit move — same
  Rule of Five gap as `abstract_tag`. The virtual destructor suppresses both.
  Since `tagdb` is a pure virtual base, the correct resolution is to explicitly
  delete copy and move (same pattern as `TAGL::driver`).
* `tagdb::session` holds `std::atomic<uint64_t> _sequence` — `atomic` suppresses
  implicit copy/move. Explicit copy constructor and `operator=` are present and
  correct but undocumented. Requires intent comment (same pattern as `tagd::session`
  in Phase 1).
* `tagdb::tagdb` const gaps: `get_session()` returns `session` by value — correct.
  `new_session()` returns `session*` — raw pointer, no ownership documentation.
* The `TODO` in `sqlite.h`: *"all public members not defined as public in
  `tagdb::tagdb` — base class should be made private or protected"* — this is an
  interface boundary defect. `sqlite` exposes methods that bypass the abstract
  `tagdb` contract. Needs a dedicated task.

Suggested task structure:
* Contract 1: Explicit `= delete` on copy/move for `tagdb::tagdb`. Intent comments.
* Contract 2: `session` and `new_session()` ownership documentation.
* Contract 3: Interface boundary audit — which `sqlite` public methods violate the
  `tagdb` abstraction? Document; schedule follow-on.

### Phase 5 — `tagsh/` (shell driver, test layer)

**Not yet tasked.**

`tagsh` is the primary interactive consumer of `TAGL::driver` and `tagdb::tagdb`.
It will benefit from Phases 3 and 4 without code changes — but it may expose
const correctness violations in the driver interface that become visible only
through `tagsh`'s usage patterns.

Priority findings (from `tagsh/include/tagsh.h` and `tagsh/src/tagsh.cc`,
not yet reviewed in detail — agent must read before tasking):
* Audit all uses of `driver` through `tagsh` for const correctness violations
  that Phase 3 will expose.
* `tagsh` test layer was recently refactored (`TASKS.d/2026-04-12-tagsh-test-layer-refactor.md`).
  Confirm test coverage is adequate before Phase 5 begins.

### Phase 6 — `httagd/` (HTTP server)

**Not yet tasked.**

`httagd` is the HTTP interface to the tagspace. It sits at the top of the
dependency stack. Its correctness depends entirely on Phases 1–5.

Priority findings (not yet reviewed in detail):
* `httagd` uses `TAGL::driver` and `tagdb::sqlite` directly. Phase 3 and 4
  changes will cascade here.
* HTTP callback dispatch (`httagd::callback`) inherits from `TAGL::callback`.
  Phase 3's explicit deletion of copy/move on `TAGL::callback` must be verified
  to not break `httagd`'s callback subclass.

---

## Standing C++23 Improvement Targets

These apply across all modules and should be evaluated in each phase.

### 1. `std::set::extract()` in `merge_tags`

`merge_tags` and `merge_tags_erase_diffs` use copy/erase/reinsert because `std::set`
iterators are const. In C++17+, `std::set::extract()` allows in-place node mutation
without reallocation. This was deferred in Phase 1 with a TODO. It should be
addressed after Phase 1 is fully stable — it is a meaningful performance improvement
for `tag_set` operations.

### 2. Rank-aware ordering (activation feature)

Currently `abstract_tag::operator<` orders by `_id` (string comparison). The planned
activation feature will promote ordering to rank-based when both tags are activated.
This affects:
* `tag_set` membership and iteration order.
* `predicate_set` ordering (relator and object are tag ids; their ranks will define
  canonical predicate sequence).
* `dump()` canonical output.

TODO comments are placed in the code. This is a design task, not a C++23 task —
but it is the feature that will make the canonical serialization mathematically
correct. C++23 comparator types (`std::strong_ordering`, three-way `operator<=>`)
are the right tools when this is implemented.

### 3. `constexpr` hard tags

`hard-tags.h` defines hard tag ids as `#define` string literals. In C++23 these
can be `inline constexpr std::string_view`. This eliminates the preprocessor,
gives them type safety, and makes them usable in `constexpr` contexts.

This is a low-risk, high-value change. The `gen-hard-tags.gperf.pl` script
generates the gperf input from these definitions — the generator would need to
be updated to handle `string_view`. Scope it as a separate task.

### 4. `std::span` for buffer interfaces

`scanner` passes raw `const char*, size_t` pairs throughout. In C++23 these
should be `std::span<const char>`. This makes the size coupling explicit and
eliminates the class of bugs where pointer and size get out of sync.

Scope: after Phase 3, when `scanner`'s interface is stable.

### 5. `[[nodiscard]]` on `tagd::code` return values

Many methods return `tagd::code` and the caller is expected to check it.
`[[nodiscard]]` on the return type (or on individual methods) makes unchecked
error codes a compile-time warning. Phase 1 added `[[nodiscard]]` to the
`relation()` family — this pattern should be audited and extended across
`tagdb`, `tagl`, `tagsh`.

### 6. `std::unique_ptr` for `_parser` in `TAGL::driver`

`_parser` is a raw `void*` managed by `ParseAlloc`/`ParseFree`. A
`std::unique_ptr<void, decltype(&ParseFree)>` with a custom deleter would
give RAII without changing the lemon API contract. This was explicitly deferred
in Phase 3. It is the right long-term answer — scope as a follow-on task after
Phase 3 is complete.

### 7. `std::string_view` for id parameters

`tagd::id_type` is `std::string`. Many methods take `const id_type&` where
`std::string_view` would avoid a temporary string construction at call sites
that pass string literals. This is a broad, low-risk improvement — audit and
scope after the ownership and const correctness work is complete.

---

## Test Coverage Standard

The coverage bar is set by `tokr/tests/Tester.h` (for value types) and by
the `tagd` Phase 1 test additions (for the full value-type contract).

For each class refactored, the following test categories must be present:
* Default construction and `empty()`.
* Copy construction and copy assignment (or static assertion that they are deleted).
* Move construction and move assignment (or static assertion that they are deleted).
* Member `swap` and ADL `swap` (for value types).
* `operator==` and `operator!=` (for value types).
* `operator<` contract (especially the identity vs. deep equality divergence
  on `abstract_tag`).
* Const accessor coverage: each `const` method called through a `const&`.
* Ownership contracts: verify no double-free, no use-after-move.

---

## Process Notes

* Each phase produces a task file in `TASKS.d/` and an AAR in `out/`.
* This guide is updated after each phase AAR is complete.
* When a phase exposes a gap in a lower layer, stop and file a prerequisite task
  before proceeding. Do not silently broaden scope.
* The mathematical model is the source of truth for ordering semantics.
  When in doubt about whether a C++ design is correct, ask: does this match
  what the math says the system is?
