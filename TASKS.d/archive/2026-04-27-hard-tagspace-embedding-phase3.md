# Task: Phase 3 — Embed hard_tagspace in tagspace::memory (Composition)

## Objective
Refactor `tagspace::memory` to embed `hard_tagspace` as a member (composition) instead of inheritance.

`hard_tagspace` must remain strictly read-only and immutable.

## Requirements
- `tagspace::memory` should contain a `hard_tagspace _hard;` member.
- All hard tag lookups (`lookup_pos`, `lookup_rank`, `exists`, etc.) must delegate to `_hard`.
- Mutable operations (`put`, `del`, `merge`, etc.) operate only on user-defined tags.
- Keep `hard_tagspace` deriving only from `tagspace` (read-only base).
- No storage logic inside `hard_tagspace`.

Recommended Tests (add to HardTagTester.h) ; Suggestions Only - Use your best reasoning

```C++
// 1. Hard tag immutability (strongest compile + runtime check)
void test_hard_tagspace_rejects_mutation_at_compile_time() {
    tagd::hard_tagspace ts;
    tagd::tag t("test", "animal");
    TS_ASSERT_COMPILE_FAIL(ts.put(t));   // or use type trait if no compile-fail macro
}

// 2. Memory correctly delegates hard tags
void test_memory_delegates_hard_tag_lookups() {
    tagd::tagspace::memory ts;
    tagd::abstract_tag t;
    TS_ASSERT_EQUALS(ts.get(t, tagd::HARD_TAG_HAS), tagd::TAGD_OK);
    TS_ASSERT_EQUALS(t.sub_relator(), tagd::HARD_TAG_SUB);
    TS_ASSERT_EQUALS(t.super_object(), tagd::HARD_TAG_RELATOR);
}

// 3. User tags and hard tags coexist cleanly
void test_memory_mixes_hard_and_user_tags() {
    tagd::tagspace::memory ts;
    tagd::tag dog("dog", "mammal");
    TS_ASSERT_EQUALS(ts.put(tagd::tag("mammal", tagd::HARD_TAG_ENTITY)), tagd::TAGD_OK);
    TS_ASSERT_EQUALS(ts.put(dog), tagd::TAGD_OK);
    TS_ASSERT(ts.exists("dog"));
    TS_ASSERT(ts.exists(tagd::HARD_TAG_HAS));
}

// 4. Rank assignment for user tags
void test_memory_assigns_child_ranks_correctly() {
    tagd::tagspace::memory ts;
    tagd::tag parent("parent", tagd::HARD_TAG_ENTITY);
    tagd::tag child("child", "parent");
    TS_ASSERT_EQUALS(ts.put(parent), tagd::TAGD_OK);
    TS_ASSERT_EQUALS(ts.put(child), tagd::TAGD_OK);
    TS_ASSERT(child.rank().contains(parent.rank()));  // or similar check
}
```

These tests close the most important gaps: immutability enforcement, delegation correctness, and mixed usage.

## Acceptance Criteria
- `hard_tagspace` remains immutable (mutating methods = delete).
- `tagspace::memory` correctly routes hard tags to the embedded `_hard` instance.
- All existing tests pass.
- `make clean && make tests` passes.
- Clear separation: hard tags = immutable root, memory = mutable layer.

## Suggested Commit Message
tagspace: Phase 3 — embed hard_tagspace as member in tagspace::memory
Use composition for clean immutable root. hard_tagspace stays strictly read-only.

