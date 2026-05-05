# Task: Generator-Based Constexpr Hard Tag Lookup

Replace the manual hash table with a Perl generator that reads `///` metadata
from `hard-tags.h` and produces `include/hard-tag-lookups.inc.h`.

## Objective
- Keep `hard-tags.h` as the **single source of truth** containing only
  `constexpr std::string_view HARD_TAG_*` definitions + `///` metadata.
- Generate fast constexpr lookup table + hierarchy validation at build time.
- Support future UTF-8 hard tag ids.

## Requirements
- Update `hard-tags.h` to use this comment style:
  ```cpp
  inline constexpr std::string_view HARD_TAG_ENTITY{"_entity"}; /// HARD_TAG_SUB HARD_TAG_ENTITY tagd::POS_TAG
  inline constexpr std::string_view HARD_TAG_IS_A{"_is_a"};     /// HARD_TAG_SUB HARD_TAG_SUB tagd::POS_SUB_RELATOR
  ```
- New generator: `src/gen-hard-tags-lookups.pl`
  modeled after the old files:
  `../tagd-workspace/tagd/tagdb/src/gen-hard-tags.gperf.pl`)
  `../tagd-workspace/tagd/tagd/include/tagd/hard-tags.h` # see the old style comments
- Output: `include/hard-tag-lookups.inc.h` (included at the bottom of `hard-tags.h`)
  This file contains all the tables, functions, arrays, etc and the `using` statements.
- Generated file must contain:
  - Fast O(1) hash table (`HARD_TAG_HASH_TABLE`)
  - `check_hierarchy()` + `static_assert`
  - `hard_tag_axiom_for_fast()` with `_` pre-filter
- `hard_tag_axiom_for()` delegates to the fast path.
- No string literals in generated code — only `HARD_TAG_*` constants.
- Preserve `sub_relator` field in the axiom struct.

## Build Integration (src/Makefile)

Model after the attached top-level Makefile:

```makefile
HARD_TAGS_H = ../include/tagd/hard-tags.h
HARD_TAG_LOOKUPS_INC = ../include/hard-tag-lookups.inc.h

build: $(OBJS) $(HARD_TAG_LOOKUPS_INC)

$(HARD_TAG_LOOKUPS_INC): $(HARD_TAGS_H) src/gen-hard-tags-lookups.pl
	./src/gen-hard-tags-lookups.pl $< > $@

-include $(DEPS)
```

## Acceptance Criteria
- Adding a new hard tag only requires editing `hard-tags.h` and re-running the generator.
- Compiler enforces hierarchy and rank prefixes via `static_assert`.
- Lookup is fast (O(1) hash table with bounded probes).
- `make clean && make tests` passes.
- Old gperf infrastructure is completely removed.

## Suggested Commit Message
```
hard-tagspace: introduce generator-based constexpr hard tag lookup

hard-tags.h is single source of truth using /// metadata.
Generator produces fast hash table + hierarchy validation.
```

