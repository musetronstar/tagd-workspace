# Task: O(1) Hard Tag Lookup — Compile-Time Verified Hash Table with Hierarchy Validation

Replace the `lower_bound` binary search in `hard_tag_axiom_for()` with a
`constexpr` open-addressed hash table that provides O(1) lookup for the hard
tag basis with compile-time verified collision bounds. Add a leading-`_`
structural pre-filter that rejects all non-hard-tag strings before any hashing
occurs. Add a compile-time hierarchy validator that proves the `HARD_TAG_AXIOMS`
tree is structurally correct — parent-child `super_object` links and
`packed_rank` prefix relationships verified by `static_assert`.

## Principles

* `hard-tags.h` is the single source of truth. `HARD_TAG_AXIOMS`,
  `HARD_TAG_ID_INDEX`, and all `HARD_TAG_*` `string_view` constants remain
  unchanged. This task adds a fast lookup path and compile-time verification.
* The leading `_` prefix on every hard tag id is a **structural invariant**.
  It enforces `hard tags ∈ H ⊂ all tags` and enables O(1) rejection of
  user-defined tag strings before hashing. Document and enforce with
  `static_assert`.
* `HARD_TAG_AXIOMS` is the canonical generated hard-tag basis. The hash table
  is generated from that full basis, not from an ad hoc subset.
* **Collision bounds are proven by `static_assert`, not by hash properties.**
  This is not a perfect hash — it is an open-addressed hash with bounded
  probe depth. The guarantee comes from compile-time slot verification, not
  from the hash function itself.
* **No caching. Hard tags are already the cache.** The table is `.rodata`.
  Caching belongs to user-defined tag lookups that hit the storage layer.
* `HARD_TAG_ID_INDEX` is the canonical sorted projection of the axiom set H.
  It is not an implementation artifact and must not be removed. It serves as
  the compile-time verified reference for sort order and axiom membership.

## Background

The current `hard_tag_axiom_for(id)` uses `std::lower_bound` over
`HARD_TAG_ID_INDEX`. This is correct and
`constexpr`, but is called on every token the scanner emits. An
open-addressed hash table gives a single array read with at most one probe,
and the `_` pre-filter gives immediate O(1) rejection for the common case
of user-defined tag ids.

**Hash parameters — authoritative, proven by `static_assert`:**

| Parameter       | Value                                                    |
|-----------------|----------------------------------------------------------|
| Hash function   | FNV-1a 32-bit (byte hash over raw UTF-8 bytes)          |
| Table size N    | generated power-of-two size                             |
| Probe strategy  | Open addressing, linear probe                            |
| Max probe depth | compile-time proven by generated `static_assert`        |
| Verification    | `static_assert` on every slot, not hash-function proof  |
| Load factor     | derived from the generated table                         |

The reference implementation `docs/hard-tag-lookup.h` contains the
pre-computed table and all `static_assert` blocks. Use it as the starting
point. The table MUST be validated against `HARD_TAG_AXIOMS` via
`static_assert` — do not assume the reference file is correct, verify it.

## Scope

### Read
- `tagd/include/tagd/hard-tags.h` — read in full. Understand
  `hard_tag_axiom` (five fields: `id`, `sub_relator`, `super_object`, `pos`,
  `packed_rank`), `HARD_TAG_AXIOMS`, `HARD_TAG_ID_INDEX`,
  `hard_tag_axiom_for()`.
- `hard-tagspace/include/tagd/hard-tagspace.h` — call sites for
  `hard_tag_axiom_for()`, `lookup_pos()`, `lookup_rank()`. Remove or rewrite
  any "future caching/memoization" comments on hard-tag lookup paths.
  Hard tags resolve from `.rodata`; no cache is needed or appropriate.
  Replace with: `// Hard tag lookup: O(1) via constexpr table. No cache needed.`
- `hard-tagspace/tests/` — existing tests for hard tag lookup behavior
- `docs/hard-tag-lookup.h` — reference implementation; use as starting point
  but verify every `static_assert` independently

### Write
- `tagd/include/tagd/hard-tags.h` — add:
  1. Leading-`_` invariant comment before the first `string_view` constant
  2. `constexpr` FNV-1a hash function `hard_tag_fnv1a()`
  3. `constexpr bool rank_prefix_of(uint64_t parent, uint64_t child)` helper
  4. `constexpr bool check_hierarchy()` — validates all parent-child
     `super_object` links and `packed_rank` prefix relationships
  5. `static_assert(check_hierarchy(), "invalid hard-tag tree")`
  6. `HARD_TAG_HASH_TABLE` — generated open-addressed array of
     `const hard_tag_axiom*`
  7. `hard_tag_axiom_for_fast()` — O(1) with `_` pre-filter and bounded probe
  8. `static_assert` block: slot placements, `sub_relator` access,
     pre-filter correctness, round-trip agreement with `hard_tag_axiom_for()`
  9. Update `hard_tag_axiom_for()` to delegate to `hard_tag_axiom_for_fast()`
- `hard-tagspace/include/tagd/hard-tagspace.h` — fix caching comments
- `hard-tagspace/tests/` — add or extend tests (see TDD section)

### Non-goals
- Do not change `HARD_TAG_AXIOMS`, `HARD_TAG_ID_INDEX`, or any
  `HARD_TAG_*` `string_view` constant.
- Do not change the `hard_tag_axiom` struct layout. All five fields —
  including `sub_relator` — must be preserved. `sub_relator` is `HARD_TAG_SUB`
  for all current axioms but is reserved for future non-`_sub` identity
  relators. Removing it is a regression.
- No raw string literals in `HARD_TAG_HASH_TABLE` or any axiom structure.
  Every `id`, `sub_relator`, and `super_object` reference in live code MUST
  use a `HARD_TAG_*` constant. String literals in comments are fine; in live
  code they are not. This is what makes the compiler enforce correctness —
  if a string value changes, the constant changes and the compiler catches
  every use site.
- `HARD_TAG_ID_INDEX` and the `lower_bound` path remain. After this task,
  `hard_tag_axiom_for()` delegates to `hard_tag_axiom_for_fast()`, but
  `HARD_TAG_ID_INDEX` stays as the canonical sorted projection of H — not
  an implementation artifact, not a runtime fallback.
- No changes to TAGL grammar, parser, or scanner.
- No new dependencies.

## Doctrine

Follow `docs/cpp23-excellence-guide.md` and `AGENTS.md`.

## Implementation Notes

### Hash function

```cpp
[[nodiscard]] constexpr uint32_t hard_tag_fnv1a(std::string_view s) noexcept {
    uint32_t h = 2166136261u;
    for (unsigned char c : s)    // byte hash over raw UTF-8 — correct
        h = (h ^ c) * 16777619u;
    return h;
}
```

This is a byte hash, not a semantic hash. That is correct and intentional —
hard tag ids are ASCII strings and byte identity equals semantic identity.
For `HARD_TAG_*` compile-time `string_view` constants, the compiler evaluates
this entirely at compile time.

### Hierarchy validator

```cpp
[[nodiscard]] constexpr bool rank_prefix_of(uint64_t parent, uint64_t child) noexcept {
    // A packed_rank is big-endian; a parent rank is a prefix of a child rank.
    // The root (_entity) has rank 0x0000000000000000 which prefixes everything.
    if (parent == child) return true;
    // Find the first non-zero byte of the child not covered by parent.
    // parent bytes must equal child bytes in every position parent is non-zero.
    for (int byte = 7; byte >= 0; --byte) {
        uint8_t pb = (parent >> (byte * 8)) & 0xFF;
        uint8_t cb = (child  >> (byte * 8)) & 0xFF;
        if (pb != 0 && pb != cb) return false;
    }
    return true;
}

[[nodiscard]] constexpr bool check_hierarchy() noexcept {
    for (const auto& t : HARD_TAG_AXIOMS) {
        if (t.id == HARD_TAG_ENTITY) continue;  // root is self-referencing

        bool found = false;
        for (const auto& p : HARD_TAG_AXIOMS) {
            if (p.id == t.super_object) {
                found = true;
                if (!rank_prefix_of(p.packed_rank, t.packed_rank))
                    return false;
            }
        }
        if (!found) return false;  // super_object not in axiom set
    }
    return true;
}

static_assert(check_hierarchy(), "hard-tag axiom tree is structurally invalid");
```

This is the most important addition. It makes the compiler enforce the
tagspace tree — not just lookup correctness. Every `super_object` link is
verified to exist in `HARD_TAG_AXIOMS`, and every parent `packed_rank` is
verified to be a prefix of its child's `packed_rank`.

### Lookup shape

```cpp
[[nodiscard]] constexpr const hard_tag_axiom*
hard_tag_axiom_for_fast(std::string_view id) noexcept {
    // Structural invariant: hard tags ∈ H ⊂ all tags.
    // Every hard tag id begins with '_'; user tags never do.
    if (id.empty() || id[0] != '_') return nullptr;

    const std::size_t slot = hard_tag_fnv1a(id) & HARD_TAG_TABLE_MASK;

    if (const hard_tag_axiom* e = HARD_TAG_HASH_TABLE[slot])
        if (e->id == id) return e;

    for (std::size_t probe = 0; probe <= HARD_TAG_MAX_PROBE_DEPTH; ++probe) {
        if (const hard_tag_axiom* e = HARD_TAG_HASH_TABLE[(slot + probe) & HARD_TAG_TABLE_MASK])
            if (e->id == id) return e;
    }

    return nullptr;
}
```

### Wording requirement

Do NOT use the phrase "perfect hash" anywhere in comments or documentation.
The correct description is: **"open-addressed hash with compile-time verified
collision bounds."** The guarantee is provided by `static_assert`, not by
hash-function properties.

### Table validation requirement

The table MUST be validated against `HARD_TAG_AXIOMS` via `static_assert`
for every slot. The reference file provides a starting point but the
`static_assert` block is the proof — do not treat the pre-computed slots
as axiomatic.

## TDD

```cpp
// Hierarchy — the most important assertion
static_assert(check_hierarchy(), "hard-tag axiom tree is structurally invalid");

// Representative hard tags reachable
static_assert(hard_tag_axiom_for_fast(HARD_TAG_ENTITY)       != nullptr);
static_assert(hard_tag_axiom_for_fast(HARD_TAG_ENTITY)->pos  == POS_TAG);
static_assert(hard_tag_axiom_for_fast(HARD_TAG_SUB)->pos     == POS_SUB_RELATOR);
static_assert(hard_tag_axiom_for_fast(HARD_TAG_HAS)->pos     == POS_RELATOR);
static_assert(hard_tag_axiom_for_fast(HARD_TAG_FLOAT)->pos   == POS_TAG);

// sub_relator preserved
static_assert(hard_tag_axiom_for_fast(HARD_TAG_SUB)->sub_relator == HARD_TAG_SUB);

// Pre-filter — structural gating
static_assert(hard_tag_axiom_for_fast("")       == nullptr);
static_assert(hard_tag_axiom_for_fast("dog")    == nullptr);
static_assert(hard_tag_axiom_for_fast("_ghost") == nullptr);

// Round-trip with lower_bound path — whole generated basis
static_assert(hard_tag_axiom_for_fast(HARD_TAG_ENTITY) == hard_tag_axiom_for(HARD_TAG_ENTITY));
// ... all generated hard tags
```

### Verify

```bash
make clean && make tests
```

## Acceptance Criteria

- `check_hierarchy()` passes as `static_assert` — compiler enforces the tree.
- `hard_tag_axiom_for_fast()` is `constexpr`, `noexcept`, returns
  `const hard_tag_axiom*`.
- Table size and max probe depth are generated and proven by `static_assert`
  on every slot — not documented as assumptions.
- The `_` pre-filter structurally gates `H ⊂ all tags`.
- All generated hard tags round-trip through `hard_tag_axiom_for_fast()`.
- Fast and `lower_bound` paths agree on the generated hard-tag basis (proven by
  `static_assert`).
- `hard_tag_axiom_for()` delegates to `hard_tag_axiom_for_fast()`.
- `HARD_TAG_ID_INDEX`, `HARD_TAG_AXIOMS`, and all `HARD_TAG_*` constants
  are unchanged.
- `sub_relator` field is preserved and accessible via the hash table pointer.
- No "perfect hash" language anywhere. Correct phrase used throughout:
  "open-addressed hash with compile-time verified collision bounds."
- Caching TODO comments on hard-tag paths in `hard-tagspace.h` removed.
- Full test suite passes: `make clean && make tests`.

## Deliverable: Concise Report

1. Summary of changes.
2. Test results (`make clean && make tests` output).
3. Open issues or observations.
4. Suggested git commit message.
