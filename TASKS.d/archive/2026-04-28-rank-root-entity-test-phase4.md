# Rank Root Entity Test

## Objective
Make the rank semantics for `_entity` explicit, intentional, and well-tested.

## Requirements
- `_entity` must have a rank containing a single byte `0x00` (the root).
- `rank.empty()` must return `true` **only** for unactivated/scratch tags.
- All other hard tags must have non-empty ranks starting ≥ `0x01`.
- Both compile-time static_asserts and runtime tests must enforce this.

## Scope (clean-room)
- Add / update tests in `tests/HardTagTester.h`
- Test both `dotted_str()` representation and internal byte content
- Verify `hard_tag_axiom_for(HARD_TAG_ENTITY)` and all other axioms

## Acceptance Criteria
- `_entity` rank is **not** empty and represents the root (`0x00`).
- `rank.empty()` is false for every hard tag axiom.
- All other hard tags have non-empty ranks.
- `make clean && make tests` passes.

## Suggested Commit Message

