# tagd / tagspace Changes Impact Log

Chronological impact statements derived from git commit logs and task files in
`./tagd-workspace/TASKS.d/` and `../tagspace/TASKS.d/` (including archive).
Final section covers uncommitted state in both repositories as of 2026-05-02.

---

## tagspace clean-room repository (`../tagspace`)

### 2026-04-25 — Foundation (Phase 1)

**Task:** `archive/2026-04-25-tagspace-interface-core-phase1.md`

- Created clean-room project with empty file placeholders.
- `include/tagd/tagspace.h`: defined pure abstract base class `tagspace` as a
  near drop-in for `tagdb::tagdb`, with virtual `get`, `put`, `del`, `query`,
  `exists`, `pos`, etc.
- Symlinks to `tagd` hard-tags headers for shared constants.
- Build system (`src/Makefile`) set up; `tests/HardTagTester.h` skeleton.

### 2026-04-25–26 — Constexpr Hard Tag Axioms & O(1) Lookup (Phase 1 cont.)

**Commits:** `1fc131d`, `c7c8344`, `8630123`, `4eb25a3`, `7219369`, `e814457`, `9991efd`, `289588e`
**Tasks:** `archive/2026-04-26-hard-tagspace-compile-time-constexpr-lookup.md`,
`archive/2026-04-26-generate-hard-tag-lookups.md`,
`archive/2026-04-26-hard-tagspace-constexpr-lookup-fix.md`

- `include/tagd/hard-tags.h`: defined `hard_tag_axiom` struct (5 fields: `id`,
  `sub_relator`, `super_object`, `pos`, `packed_rank`), `HARD_TAG_AXIOMS` array,
  `HARD_TAG_ID_INDEX` sorted projection, `hard_tag_axiom_for()` binary search.
- Added `hard_tag_fnv1a()`, `check_hierarchy()`, `HARD_TAG_HASH_TABLE`, and
  `hard_tag_axiom_for_fast()` — O(1) open-addressed hash with `_` pre-filter and
  compile-time verified collision bounds via `static_assert`. No "perfect hash"
  language; correct phrase: "open-addressed hash with compile-time verified
  collision bounds."
- `static_assert(check_hierarchy(), ...)` enforces the axiom tree at compile time.
- `src/gen-hard-tags-lookups.pl`: Perl generator reads `///` metadata from
  `hard-tags.h` and produces `include/hard-tag-lookups.inc.h`.
- Addendum: dual-view structure — `HARD_TAG_AXIOMS` in canonical declaration
  (rank/cardinality) order; `HARD_TAG_ID_INDEX` sorted for O(log n) lookup.
- `include/tagd/tagd.h`: `pos_lookup` added to `hard_tagspace`.

### 2026-04-26 — Rank Comparator & Predicate Ordering (Phase 2)

**Commit:** `74f1fe8`
**Task:** `archive/2026-04-26-hard-tagspace-rank-comparator-phase2.md`

- `include/tagd/tagspace.h`: added `rank_comparator()` pure virtual to `tagspace`
  abstract base.
- `include/tagd/hard-tagspace.h` / `src/hard-tagspace.cc`: implemented
  `hard_tagspace::rank_comparator()` using hard tag axioms; canonical ordering:
  rank(relator) → rank(object, MAX_RANK for literals) → object id → modifier.
- Ordering aligns with the Alexandrov topology from the tagd math document.

### 2026-04-26 — Mutable/Const Split

**Commit:** `68e531d`

- Separated `mutable_tagspace` (read-write) from `tagspace` (read-only base).
- `hard_tagspace` derives from `tagspace` (read-only); `mutable_tagspace`
  provides the write interface.

### 2026-04-27 — Memory Backend & Immutability Enforcement (Phase 3)

**Commits:** `794a4e8`, `8d2b145`, `833172c`, `fdbb43d`
**Task:** `archive/2026-04-27-hard-tagspace-embedding-phase3.md`

- `src/hard-tagspace.cc`: implemented `tagspace::memory` — in-memory mutable
  backend using `std::unordered_map<id_string, stored_tag>`.
- `tagspace::memory` embeds `hard_tagspace _hard` by composition; hard tag
  lookups delegate to `_hard`; mutable operations only touch user tags.
- `include/tagd/hard-tagspace.h`: added `= delete` on all mutating methods of
  `hard_tagspace` — immutability enforced both by hierarchy and interface.
- Symlinks unlinked.

### 2026-04-28 — Naming Clarification + Session Ownership (Phase 4)

**Commits:** `c05c689`, `b660006`, `a1cb885`, `4036919`
**Tasks:** `archive/2026-04-28-tagspace-naming-clarification-phase4.md`,
`archive/2026-04-28-tagspace-context-ownership-phase4.md`

- **Rename:** `mutable_tagspace` → `tagspace` (normal mutable interface everywhere);
  `tagspace` → `const_tagspace` (read-only base, used only by `hard_tagspace`).
  Affects: `tagspace.h`, `hard-tagspace.h`, `tagd.h`, `hard-tagspace.cc`,
  `HardTagTester.h`.
- `include/tagd/tagd.h`: `tagd::session` now owns the full context stack
  (`push_context`, `pop_context`, `print_context`, `context()`); `tagdb` no
  longer visible from session.
- `tagspace::memory::new_session()` / `release_session()` wired and tested.
- `src/hard-tagspace.cc`: added `const`-correct `dump_*` methods.
- Comments improved.

### 2026-04-28–29 — `_entity` Root Rank Fix (Phase 4 cont.)

**Commits:** `5e65768`, `87f0037`
**Task:** `archive/2026-04-28-rank-root-entity-test-phase4.md`

- `_entity` rank fixed to `{0x00}` (non-empty root). All other hard tags
  confirmed non-empty, starting at `>= 0x01`.
- Compile-time `static_assert` and runtime tests added in `HardTagTester.h`.
- Completed task files archived.

---

## tagspace — Current Uncommitted State

**Task driving this work:** `TASKS.d/2026-04-30-tagspace-remove-identity-rewriting.md`
(also foreshadowed by `TASKS.d/2026-04-29-tagspace-constructive-identity.md`)

**Status: INCOMPLETE** — implementation and tests are written; `make clean && make tests`
result unknown.

### Changed files and what changed

**`include/tagd/tagd.h`** (+2 lines changed)
- Added `#include "tagd/hard-tags.h"`.
- `tag` default constructor now explicitly initializes with `HARD_TAG_SUB` as
  `sub_relator` instead of leaving it empty.
- `tag(id_view id, id_view super_obj)` constructor now explicitly passes
  `HARD_TAG_SUB` as `sub_relator` (was passing empty `id_view{}`).

**`include/tagd/hard-tagspace.h`** (-3 lines)
- Removed private method declarations: `normalized_sub_relator()`,
  `normalized_super_object()`, `normalized_pos()`.

**`src/hard-tagspace.cc`** (-42 lines, +64 lines, net +22)
- Deleted all three `normalize*` method implementations.
- Rewrote `tagspace::memory::store_user_tag()`:
  - New: relation-only update path for an existing tag with empty identity
    fields (adds predicates, preserves existing identity).
  - Validates `sub_relator` not empty → `TS_SUB_UNK`.
  - Validates `super_object` not empty → `TS_OBJECT_UNK`.
  - Validates `sub_relator` has `POS_SUB_RELATOR` (not just existence) →
    `TS_RELATOR_UNK`.
  - Validates `super_object` exists and has non-empty rank → `TS_OBJECT_UNK`.
  - Stores caller-supplied `sub_relator`, `super_object`, `pos` faithfully.
  - Rejects reparenting (different `super_object` on re-put) → `TS_MISUSE`.

**`tests/HardTagTester.h`** (+103 lines — 7 new test methods)
- `test_memory_tagspace_round_trips_explicit_identity_unchanged`: full
  `abstract_tag` with `HARD_TAG_TYPE_OF`, `HARD_TAG_ENTITY`, `POS_INTERROGATOR`
  survives put/get unchanged.
- `test_memory_tagspace_preserves_type_of_subordinate_relation`: `HARD_TAG_TYPE_OF`
  not overwritten with `HARD_TAG_SUB` after storage.
- `test_memory_tagspace_rejects_empty_subordinate_relation_without_rewriting`:
  `TS_SUB_UNK` returned; tag not stored.
- `test_memory_tagspace_rejects_empty_super_object_without_rewriting`:
  `TS_OBJECT_UNK` returned.
- `test_memory_tagspace_allows_existing_tag_relation_only_updates`: delta put with
  only predicates (no identity fields) merges into existing tag.
- `test_memory_tagspace_rejects_non_sub_relator_identity_relation`:
  `HARD_TAG_HAS` as sub_relator → `TS_RELATOR_UNK`.
- `test_memory_tagspace_preserves_unknown_pos_without_promoting_to_tag`:
  `POS_UNKNOWN` stored as-is, not promoted to `POS_TAG`.

### Open question
`POS_UNKNOWN` is now stored faithfully. The old `normalized_pos()` promoted
`POS_UNKNOWN` → `POS_TAG`. Existing tests that relied on that promotion may
fail. The task explicitly defers the `_is_a` vs `_sub` default-constructor
policy; the same deferral applies to `POS_UNKNOWN` semantics.

---

## tagd-workspace repository (`./tagd`)

### 2026-04-19–24 — C++23 Phase 8 & 9 Refactoring

**Tasks:** `2026-04-19-tagd-cpp23-phase8.md`, `2026-04-19-tagd-cpp23-phase9.md`,
`2026-04-20-tagd-cpp23-phase9b.md`
**Commit:** `9d85d3e` (docs: designed and managed C++23 refactoring tasks)

- C++23 modernisation across `tagd/`, `tagdb/`, `tagl/`, `tagsh/`, `httagd/`;
  specific file/method details tracked in individual task and AAR files under
  `out/`.

### 2026-04-27 — Constructive Identity in Math Docs & TAGL Spec

**Commit:** `2157e7a`

- `docs/tagl/tagd-math/tagd-math-claude.{md,pdf,tex}`: extended to include
  constructive existence, rank, subordinate relation, predicate fiber, and
  Alexandrov topology. This is the authoritative math document referenced by
  all tagspace constructive-identity tasks.
- `docs/tagl/TAGL-Thesis.md`, `docs/tagl/TAGL-spec.md`: updated.
- `TASKS.d/2026-04-26-hard-tagspace-ranked-predicates.md`: task file added.
- `out/2026-04-26-grok-math-discussion.md`: math discussion record added.
- **No source code was changed** — documentation only.

### 2026-04-27 — `remove` Command Added

**Commits:** `481456c`, `43b642e`

- Two commits with identical message "added `remove` command". Exact files not
  expanded here but this is tagd/tagsh source (not tagspace).

### 2026-04-27 — Integration Task File Created

**Commit:** `9de8299`

- `TASKS.d/2026-04-27-hard-tagspace-integration-prep-phase4.md` added: Phase 4
  integration task — prepare `../tagspace` for integration into main `tagd`
  repo (build system update, compatibility shims, switch tests to
  `tagspace::memory`).

---

## tagd-workspace — Current Uncommitted State

**Status: INTEGRATION HAS NOT STARTED.** No tagd source files have been
modified for the tagspace integration. The Phase 4 task file exists but no
implementation has been done.

### Changed files

**`TASKS.d/2026-04-27-hard-tagspace-integration-prep-phase4.md`** (modified, 1 line)
- Objective text updated: "hard-tagspace" → "../tagspace" to correctly name
  the source repo.

### Untracked files

**`TASKS.d/2026-04-29-tagspace-constructive-identity.md`**
- Detailed constructive-identity refactor task targeting `../tagspace` — full
  topology enforcement: reject invalid `put()`, validate sub-relators, forbid
  silent rank preservation on reparent, restrict predicate relators, fix
  `dump()`, query topology. Broader than the follow-on removal task.

**`TASKS.d/2026-04-30-tagspace-remove-identity-rewriting.md`**
- Narrowed follow-on: remove `normalize*` helpers, make `store_user_tag()`
  store caller-supplied identity faithfully. This is the task whose
  implementation is currently in progress (uncommitted) in `../tagspace`.

**`out/2026-03-02-tagd-comprehension.md`**
- The comprehension/orientation document that spawned this impact log.

---

## Summary

| Repo | Last commit | Uncommitted work | Status |
|------|-------------|------------------|--------|
| `../tagspace` | `87f0037` 2026-04-29 (archive) | 4 files modified — identity-rewriting removal | **In progress; tests unknown** |
| `./tagd-workspace` | `9de8299` 2026-04-27 (task file) | 1 file modified + 3 untracked task/out files | **Integration not started** |

The next concrete step before integration can proceed is:
1. Verify `make clean && make tests` passes in `../tagspace` with the uncommitted changes.
2. Commit those changes in `../tagspace`.
3. Then begin the Phase 4 integration into `./tagd`.
