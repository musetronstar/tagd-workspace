# Task: Phase 2 — rank_comparator() and Rank-Aware Predicate Ordering

## Objective
Implement `rank_comparator()` on `hard_tagspace` and make predicate ordering rank-aware instead of lexicographic on `id`.

This is the first major mathematical feature built on top of the new hard tag foundation.

## Requirements
- Add `[[nodiscard]] std::function<bool(const predicate&, const predicate&)> rank_comparator() const` to `tagspace` abstract base class.
- Implement it in `hard_tagspace` using the hard tag axioms (via `lookup_rank` or direct access to `HARD_TAG_AXIOMS`).
- Canonical ordering rule:
  1. rank(relator)
  2. rank(object) — use MAX_RANK for literal (non-tag) objects
  3. object id (stable tie-breaker)
  4. modifier
- Predicate ordering must be consistent with the Alexandrov topology (rank prefix order).
- Update existing predicate comparison logic where appropriate.
- Add tests verifying rank-aware ordering (especially relators and objects with different ranks).

## Acceptance Criteria
- `hard_tagspace::rank_comparator()` returns a working rank-aware comparator.
- `std::ranges::sort` on predicate lists produces correct topological order.
- Static and runtime tests pass for both hard tags and mixed cases.
- `make clean && make tests` passes.
- No regression in existing behavior for unranked predicates.

## Suggested Commit Message
```
hard-tagspace: implement rank_comparator() and rank-aware predicate ordering

Phase 2: Use hard tag ranks for canonical predicate ordering. Aligns with Alexandrov topology.
```

