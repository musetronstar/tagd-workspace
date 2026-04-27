Markdown# Task: C++23 Stage 2 — Clean Slate Pass · Phase 10 — Constexpr Hard Tagspace & Ranked Predicates

Make the hard tag vocabulary a true mathematical root: a constexpr singleton `hard_tagspace` that is superordinate to all other tagspaces. Remove gperf entirely and make predicate ordering rank-aware while keeping predicates lightweight and context-independent.

## Principles

* The `hard_tagspace` is the **initial object** / root of the category of tagspaces — it must be constexpr, singleton, and structurally superordinate.
* Predicates are semantic accumulators. Rank is structural identity resolved at evaluation time, never stored in the predicate.
* Keep each task’s diff scoped and reviewable independently.
* Stop and report if any task reveals a non-trivial cascading change.

## Doctrine

Follow `docs/cpp23-excellence-guide.md` and `AGENTS.md`. Prioritize mathematical truth and const-correctness.

## Scope

### Read
* `tagd/include/tagd/hard-tags.h`
* `tagdb/src/gen-hard-tags.gperf.pl`
* `tagdb/src/hard-tag.cc`
* `tagd/include/tagd.h` (predicate, predicate_set, abstract_tag)
* All call sites using hard tag lookups
* Relevant tests

### Write
* `tagd/include/tagd/hard-tags.h` (new `hard_tagspace`)
* `tagd/include/tagd.h` (predicate ordering, supporting changes)
* `tagdb/src/hard-tag.cc` (remove gperf)
* Any remaining hard tag usage sites
* Tests as required

### Non-goals
* No changes to TAGL grammar or parser.
* No embedding of rank or pos into predicate storage.
* No behavior change to existing query results (only internal ordering).

---

## Task 1 — Constexpr `hard_tagspace` Singleton (Remove gperf)

### Background

gperf is the last runtime string lookup for hard tags. With immutable identity and constexpr hard tags, we can replace it with a compile-time root tagspace.

### What must be true after this task

* `hard_tagspace` exists as a constexpr singleton containing all hard tags.
* All `HARD_TAG_*` symbols remain, but are now served from the singleton.
* `hard_tag::pos()` and `hard_tag::get()` are replaced by `hard_tagspace::instance().pos(id)` etc.
* gperf generator, generated files, and runtime hash are completely removed.
* The hard tagspace is documented as the superordinate root of all tagspaces.

### Constraints

* No raw string literals for hard tags anywhere.
* Keep existing `HARD_TAG_*` names for compatibility during transition.

### TDD

Add constexpr tests verifying all hard tags are accessible with correct pos and default rank at compile time.

### Verify

```bash
make clean && make tests

Task 2 — Ranked Predicate Ordering
Background
Predicate sets are currently ordered lexicographically on _id. This lies about the horizontal fiber shape in the Alexandrov topology.
What must be true after this task

predicate_set uses a rank-aware comparator: rank(relator), rank(object), modifier.
Rank is resolved lazily via hard_tagspace (or current tagspace context) — never stored in predicate.
Canonical ordering (dumps, set comparison) now reflects topological structure.
Parsing still produces lightweight, rank-free predicates.

Constraints

Predicates remain lightweight and context-independent.
No behavior change to existing query results — only internal ordering for canonical forms.

TDD
Add tests verifying predicates sort by topological rank (not string order) when ranks are known.
Verify
Bashmake clean && make tests

Tests — Completion Command
Bashmake clean && make tests
Acceptance Criteria

gperf and all related files are gone.
hard_tagspace exists as constexpr singleton and mathematical root.
Predicate ordering is rank-aware with lazy resolution via tagspace.
Full test suite passes cleanly.
Each task’s diff is independently reviewable.

Deliverable: Concise Report
For each task:

Summary of changes.
Test results (make clean && make tests output).
Open issues or follow-on work.
Suggested git commit message.

