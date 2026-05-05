# context ownership

## Objective
Make `tagd::session` the canonical, owned session type inside `tagspace` and enforce that `tagdb` is completely invisible to the rest of the system.

## Scope (clean-room only)
- Move context stack (`push_context`, `pop_context`, `print_context`, `context()`) into `tagd::session` in the clean-room `include/tagd/tagd.h`.
- `tagspace` (and its concrete implementations) owns session lifetime via `new_session()` / `release_session()`.
- Update `tagspace::memory` (and `hard_tagspace` where applicable) to provide correct session creation.
- Higher layers inside this repo (`tests/`) must be updated to use the new model.
- **No shims. No `tagdb::` anywhere.** This is the enforcement point.

## Acceptance Criteria
- `tagd::session` contains the full context stack API.
- `tagspace::memory::new_session()` / `release_session()` work and return `tagd::session*`.
- All tests in `tests/HardTagTester.h` that use sessions pass, including new context-stack tests.
- `make clean && make tests` passes cleanly.
- No `tagdb::session`, `tagdb::tagdb`, or legacy wrappers remain visible.

## TDD Steps
1. Add failing context tests first (stack push/pop, print, top_context, interaction with lookup).
2. Implement `tagd::session` with context vector.
3. Wire `new_session()` / `release_session()` in `tagspace::memory`.
4. Update any test code that still used old session patterns.
5. Verify full test suite.

## Verification Command
```bash
make clean && make tests
```

## Suggested Commit Message
```
tagspace: Phase 4 — own session & context stack, eliminate tagdb visibility
```

