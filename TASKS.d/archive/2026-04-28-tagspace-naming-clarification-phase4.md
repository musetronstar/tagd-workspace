# `tagspace` Naming Clarification

## Objective
Make the common case clean and intuitive:
- `mutable_tagspace`  →  `tagspace`          (normal mutable interface used everywhere)
- `tagspace`          →  `const_tagspace`    (read-only base class used only by hard_tagspace)

## Scope (clean-room only)
- Rename classes and update inheritance, references, and signatures in:
  - include/tagd/tagspace.h
  - include/tagd/hard-tagspace.h
  - include/tagd/tagd.h
  - src/hard-tagspace.cc
  - tests/HardTagTester.h
- `hard_tagspace` derives from `const_tagspace`
- Update all `new_session()` / `release_session()` calls and test code

## Acceptance Criteria
- Public code uses `tagd::tagspace` for mutable operations.
- `const_tagspace` appears only where read-only semantics are required.
- No remaining `mutable_tagspace` in the public interface.
- `make clean && make tests` passes cleanly.

## Verification
```bash
make clean && make tests
```

