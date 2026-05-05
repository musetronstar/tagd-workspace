# Task: tagspace Constructive Identity and Topology Enforcement

Refactor the clean-room `../tagspace` repository so `tagspace::memory::put()` and related APIs faithfully preserve the `tagd` values constructed by TAGL/tagd callers, enforce the Alexandrov topology constraints from the tagd math document, and eliminate hidden normalization or stringly-typed behavior that changes tag identity inside storage.

## Principles

* `docs/tagl/tagd-math/tagd-math-claude.pdf` is the source of truth for topology, constructive existence, rank, subordinate relation, predicate fiber, and hard-tag invariants.
* The owning contract is `tagspace`: storage may persist or retrieve structure, but it must not reinterpret a caller-constructed tag.
* A tag exists only by explicit subordinate relation. `put()` must reject incomplete or invalid constructive identity rather than silently filling it in.
* Identity is structural. Re-putting the same nominal id with a different subordinate relation or super-object must not preserve the old rank.
* Hard tag axioms project downward. Runtime user-tag behavior must use the same rank and topology rules as the constexpr hard tags.
* TAGL-facing behavior is owned by the TAGL parser and tagd value constructors. Do not move grammar or POS inference into tagspace.

## Scope

### Read

* `docs/tagl/tagd-math/tagd-math-claude.pdf`
* `docs/refactor-task-template.md`
* `docs/cpp23-excellence-guide.md`
* `../tagspace/docs/tagspace-architecture.md`
* `../tagspace/include/tagd/tagd.h`
* `../tagspace/include/tagd/tagspace.h`
* `../tagspace/include/tagd/hard-tags.h`
* `../tagspace/include/tagd/hard-tagspace.h`
* `../tagspace/include/tagd/rank.h`
* `../tagspace/src/hard-tagspace.cc`
* `../tagspace/src/gen-hard-tags-lookups.pl`
* `../tagspace/tests/HardTagTester.h`

### Write

* `../tagspace/include/tagd/tagd.h`
* `../tagspace/include/tagd/tagspace.h`
* `../tagspace/include/tagd/hard-tagspace.h`
* `../tagspace/include/tagd/rank.h`
* `../tagspace/src/hard-tagspace.cc`
* `../tagspace/src/gen-hard-tags-lookups.pl`
* `../tagspace/tests/HardTagTester.h`
* `../tagspace/docs/tagspace-architecture.md`
* New task notes in `../tagspace/TASKS.d/` if the implementation discovers follow-on work.

### Non-goals

* Do not change TAGL grammar.
* Do not change parser behavior to compensate for tagspace storage bugs.
* Do not introduce tagdb dependencies or shims.
* Do not implement sqlite.
* Do not broaden this into the main `tagd` integration unless explicitly requested after `../tagspace` is correct.
* Do not hard-code tag ids such as `_sub` or `_is_a`; use hard-tag constants such as `HARD_TAG_SUB`.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md` and `docs/cpp23-excellence-guide.md`.

## Constraints

* Remove hidden normalization from tagspace storage. Delete or replace `normalized_sub_relator`, `normalized_super_object`, and `normalized_pos` with explicit validation.
* `put()` must store `sub_relator`, `super_object`, and `pos` exactly as supplied by the constructed tag, unless it rejects the tag with a precise error.
* `put()` must validate that the subordinate relation is a valid sub-relator, not merely an existing id.
* Predicate relations must validate relators against the relator topology rather than storing arbitrary strings as relators.
* Re-putting an existing id must reject structural identity changes or perform an explicitly specified rank-safe operation. Silent rank preservation across parent changes is forbidden.
* Deleting a tag must not orphan descendants. Reject internal-node deletion unless an explicit subtree operation is introduced in this task.
* Query matching must respect sub-relator topology, not only raw `HARD_TAG_SUB`.
* User-tag rank allocation under `_entity` must be checked against hard-tag root-child rank encoding. There must be one rank dialect.
* `dump()` must either become faithful canonical serialization or return `TS_NOT_IMPLEMENTED`.
* Keep diffs scoped, reviewable, and local to the declared write scope.
* No new dependencies unless explicitly justified by the task.

## Tests

Write tests before implementation for these contracts:

* `_entity` remains rank `{0x00}`, non-root hard tags remain non-empty and start at `>= 0x01`.
* A tag constructed with explicit `sub_relator`, `super_object`, and `pos` round-trips through `put()` and `get()` unchanged.
* A tag with missing subordinate relation is rejected; tagspace does not synthesize `HARD_TAG_SUB`.
* A tag with `POS_UNKNOWN` is rejected or preserved according to the explicit constructor contract; tagspace does not silently convert it to `POS_TAG`.
* A tag using a non-sub-relator as its subordinate relation is rejected.
* Re-putting an existing id with a different super-object or sub-relator is rejected.
* Deleting a tag with children is rejected.
* Querying through a valid sub-relator works through the topology, not only by raw string equality on `HARD_TAG_SUB`.
* Predicate relators must be existing relator tags; arbitrary unranked strings are rejected as relators.
* Bootstrap-shaped TAGL structures such as `of -^ HARD_TAG_SUB`, `part_of of of`, `kind_of of _type_of`, and `comes_from of of` remain representable without parser changes.

Required commands:

* In `../tagspace`: `make clean && make tests`
* If imported into the main repo afterward: `make clean && make tests`

## Acceptance Criteria

* `../tagspace` no longer mutates caller-supplied constructive identity inside `put()`.
* The compiler-visible model and runtime behavior agree with the tagd math document.
* Invalid topology is rejected at the tagspace boundary with precise error codes.
* Hard-tag and user-tag rank allocation use one coherent rank model.
* Query, delete, dump, and predicate behavior no longer undermine rank or subordinate-relation invariants.
* All required tests pass.
* The resulting code is easier to audit for topology correctness than the current normalization-based implementation.

## Deliverable: Concise Report

1. Summary of changes.
2. Exact test commands and results.
3. Any remaining topology questions that require user decision.
4. Suggested concise git commit message.
