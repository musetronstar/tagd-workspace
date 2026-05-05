# Task: Pre-Import Cleanup — Kill tag/relator + Placeholders

## Objective
Comment out lines for hard tags HARD_TAG_IS_A and HARD_TAG_TYPE_OF in `tagd/include/tagd/hard-tags.h`.
HARD_TAG_SUB will be our only **subordinate relator** hard tag for now.

## Principles
* `tagd/tagd/src/gen-hard-tags.pl` must recognized commented (`//` prefixed) lines and ignore them.
* Hard tag literals `_is_a` and `_type_of` in tests must define and use user tags `is_a` or `type_of` instead.
  So they must be defined before hand with:
```tagl
>> is_a _sub _sub;
>> type_of _sub _sub;
```

## Scope

### Read
* ./tagd/

### Modify
* Edit whatever files contain `HARD_TAG_IS_A`, `HARD_TAG_TYPE_OF`, `_is_a` or `_type_of`
* If a hard tag edit is made put a comment above the modified line: `// TODO <hard tag name`, example: `// TODO HARD_TAG_IS_A`

### Non-goals
* **Do not regress**, removing these hard tags from hard-tags.h will produce cascading errors. Enforce the policy! Do not regress by trying to fix immediate errors by reintroducing the hard tags we are trying to remove.

## Constraints
- Preserve test behavior, but updated to accomodate the removed hard tags.

## Tests
```bash
make clean && make tests
```

## Acceptance Criteria
- HARD_TAG_IS_A / HARD_TAG_TYPE_OF commented in hard-tags.h and skipped by `tagd/tagd/src/gen-hard-tags.pl`
- All tests + bootstrap pass identically.

## Deliverable: Concise Report
1. Summary of changes
2. Test results
3. Open issues
4. Suggested git commit message

