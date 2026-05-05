# Task: tagspace Remove Storage-Layer Identity Rewriting

Fix the clean-room `../tagspace` repository so `tagspace::memory::put()` no longer rewrites caller-constructed tag identity. Tagspace must store the `tagd` value it is given, validate topology explicitly, and reject invalid construction instead of inventing missing `sub_relator`, `super_object`, or `pos` values inside storage.

## Principles

* The source of truth for constructed tag identity is the caller-facing `tagd` value object produced by TAGL/parser/tagd constructors.
* `tagspace` owns topology validation and rank activation, not language interpretation.
* `docs/tagl/tagd-math/tagd-math-claude.pdf` has primacy for constructive identity: a tag exists by explicit subordinate relation.
* `tagd/tagdb/tests`, especially sqlite construction tests, are behavioral evidence for intent and error cases.
* `tagdb::sqlite` is not an implementation model for tagspace and must not creep into `../tagspace`.
* The `_is_a` versus `_sub` default-constructor policy is explicitly deferred. Do not change that semantic default in this task.

## Scope

### Read

* `docs/tagl/tagd-math/tagd-math-claude.pdf`
* `docs/cpp23-excellence-guide.md`
* `../tagspace/AGENTS.md`
* `../tagspace/docs/tagspace-architecture.md`
* `../tagspace/include/tagd/tagd.h`
* `../tagspace/include/tagd/hard-tagspace.h`
* `../tagspace/include/tagd/tagspace.h`
* `../tagspace/src/hard-tagspace.cc`
* `../tagspace/tests/HardTagTester.h`
* `tagd/tagd/include/tagd.h`
* `tagd/tagl/src/parser.y`
* `tagd/tagdb/tests/TestCommon.h`
* `tagd/tagdb/tests/Tester.h`

### Write

* `../tagspace/include/tagd/hard-tagspace.h`
* `../tagspace/src/hard-tagspace.cc`
* `../tagspace/tests/HardTagTester.h`
* `../tagspace/docs/tagspace-architecture.md` only if the public contract needs clarification.

### Non-goals

* Do not edit `tagd/tagspace`; it is an incomplete import and not the source of truth.
* Do not import changes back into the main repo.
* Do not change TAGL grammar or parser behavior.
* Do not implement `tagspace::sqlite`.
* Do not use, include, or depend on `tagdb`.
* Do not change the current `_is_a` versus `_sub` constructor-default policy.
* Do not broaden into query/delete/dump topology cleanup unless required to make the identity-storage tests pass.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`, `docs/cpp23-excellence-guide.md`, and `../tagspace/AGENTS.md`.

## Constraints

* Remove the `normaliz*` wording and helper API from `../tagspace` source.
* `store_user_tag()` must store `t.sub_relator()`, `t.super_object()`, and `t.pos()` as supplied, except for an explicitly documented rank-activation rule if `POS_UNKNOWN` must be derived from an existing super-object.
* If a tag lacks a usable subordinate relation, return `TS_SUB_UNK`.
* If a tag lacks a usable super-object, return `TS_OBJECT_UNK`.
* If the subordinate relation id is unknown or is not a sub-relator, return `TS_RELATOR_UNK`.
* If the super-object id is unknown, return `TS_OBJECT_UNK`.
* Do not silently convert `POS_UNKNOWN` to `POS_TAG`.
* Do not silently convert empty subordinate relation to `HARD_TAG_SUB`.
* Do not silently convert empty super-object to `HARD_TAG_URL`.
* Existing hard tags remain immutable through `tagspace::memory`.

## Tests

Write or update tests first in `../tagspace/tests/HardTagTester.h`:

* A full explicit tag identity round-trips through `put()` and `get()` unchanged.
* A tag constructed with `HARD_TAG_TYPE_OF` preserves `HARD_TAG_TYPE_OF` after retrieval.
* A tag with empty subordinate relation is rejected; storage does not fill in `HARD_TAG_SUB`.
* A tag with empty super-object is rejected unless it is an existing-tag relation-only update explicitly covered by current tagspace semantics.
* A tag with a non-sub-relator subordinate relation is rejected.
* A tag with `POS_UNKNOWN` is not silently stored as `POS_TAG`.
* Existing tests using `tagd::tag(id, parent)` continue to pass under the current constructor-default policy.
* `rg -n "normaliz|normalize|normalized" .` in `../tagspace` returns no source hits after the task.

Required command:

```bash
make clean && make tests
```

Run it from `../tagspace`.

## Acceptance Criteria

* `../tagspace` contains no storage-layer identity rewriting helpers.
* `tagspace::memory::put()` validates identity explicitly and stores caller-supplied identity faithfully.
* Tests prove the regression cannot return: no hidden `HARD_TAG_SUB`, no hidden `HARD_TAG_URL`, no hidden `POS_TAG`.
* No `tagdb` dependency or sqlite implementation detail is introduced.
* `make clean && make tests` passes in `../tagspace`.

## Deliverable: Concise Report

1. Summary of identity-boundary changes.
2. Exact test command and result.
3. Any deferred semantic question, especially `_is_a` versus `_sub`.
4. Suggested concise git commit message.
