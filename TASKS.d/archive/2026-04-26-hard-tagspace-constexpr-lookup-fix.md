# Task: Fix Constexpr Lookup Table (No Linear Search, No String Literals)

## Objective
Replace the current linear search ("loop until id matches") over the axioms array with a proper, efficient, fully `constexpr` lookup mechanism.

## Critical Requirements
- **MUST NOT** contain any hard-coded string literals (`"_entity"`, `"_sub"`, etc.).
- **MUST** use only `HARD_TAG_*` constants for every `id`, `sub_relator`, and `super_object`.
- Replace linear search (`O(n)`) with binary search (`O(log n)`) using `std::lower_bound` on a sorted `constexpr std::array`.
- Keep `hard_tagspace` as a thin, zero-overhead wrapper.

## Design
```cpp
struct hard_tag_entry {
    std::string_view id;
    std::string_view sub_relator;
    std::string_view super_object;
    part_of_speech   pos;
    rank             default_rank;
};

inline constexpr hard_tag_entry hard_tags[] = {
    { HARD_TAG_ENTITY,     HARD_TAG_SUB, HARD_TAG_ENTITY,     POS_TAG,          {} },
    { HARD_TAG_SUB,        HARD_TAG_SUB, HARD_TAG_ENTITY,     POS_SUB_RELATOR,  {1} },
    { HARD_TAG_IS_A,       HARD_TAG_SUB, HARD_TAG_SUB,        POS_SUB_RELATOR,  {1,1} },
    // ... all other entries using ONLY HARD_TAG_* constants
};

constexpr const hard_tag_entry* find_hard_tag(std::string_view id);
```

## Acceptance Criteria
- All lookups (`lookup_pos`, `lookup_rank`, etc.) use binary search.
- Zero raw string literals appear in the table.
- `hard_tagspace` remains clean and minimal.
- `make clean && make tests` passes cleanly.
- Static assertions verify key hard tags (`_entity`, `_sub`, `_is_a`, `_type_of`, etc.).

---

## Addendum Task: Dual-View Hard Tag Structure (Cardinality Order + Fast Lookup)

### Objective
Evolve the structure so we preserve **semantic declaration order** in the main array while still having fast ID lookup.

### Requirements
- The primary `HARD_TAG_AXIOMS` array **MUST** remain in the exact declaration order you choose (this is the canonical rank/cardinality traversal order used for dumps, tree walking, etc.).
- Add a secondary **sorted reverse index** (`id → array index`) to enable fast lookup.
- No string literals allowed in either structure.
- Use `std::lower_bound` on the index for O(log n) lookup.

### Target Design

```cpp
// 1. Canonical array — declaration order = rank / cardinality order (sacred)
inline constexpr std::array<hard_tag_axiom, N> HARD_TAG_AXIOMS = {{ ... }};

// 2. Fast lookup index — sorted by id
struct hard_tag_id_index {
    std::string_view id;
    size_t           axiom_index;   // index into HARD_TAG_AXIOMS
};

inline constexpr std::array<hard_tag_id_index, N> HARD_TAG_ID_INDEX = {{ ... }};

constexpr const hard_tag_axiom* hard_tag_axiom_for(std::string_view id);
```

### Future Caching/Memoization

Comment where caching/memoization will be needed in the future:

```c++
// TODO: future caching/memoization (hot path)
[[nodiscard]] part_of_speech lookup_pos(id_view id) const;

// TODO: caching/future memoization (hot path)
[[nodiscard]] rank lookup_rank(id_view id) const;

// TODO: future caching/memoization (hot path)
[[nodiscard]] const hard_tag_axiom* hard_tag_axiom_for(std::string_view id);
```
### Acceptance Criteria (Addendum)
- `HARD_TAG_AXIOMS` stays in your chosen declaration order.
- `hard_tag_axiom_for()` uses the index (no linear scan in hot path).
- Zero string literals in either array.
- Static assertions verify consistency between both views.
- `make clean && make tests` passes.

### Suggested Commit Message (Addendum)

hard-tagspace: add sorted id index for fast lookup while preserving canonical axiom order

