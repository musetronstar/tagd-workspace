# Task: Phase 4 — Integration Preparation & Compatibility Layer

## Objective
Prepare `../tagspace` for integration back into the main `tagd` repository by adding build support and compatibility shims.

## Requirements
- Add `tagspace` module to the build system (update top-level Makefile).
- Create minimal compatibility shims so `tagl/`, `tagsh/`, and `httagd/` can use `tagspace` with minimal changes.
- Add `tagspace::memory` as the default backend for tests (no sqlite yet).
- Ensure `make clean && make tests` passes in the main repo using the new `tagspace` interface.
- Keep `hard_tagspace` strictly read-only.

## Acceptance Criteria
- Main `tagd` repo can build with `tagspace` instead of direct `tagdb`.
- `tagl`, `tagsh`, `httagd` compile and pass tests using `tagspace::memory`.
- No breakage of existing functionality.
- Clean separation maintained.

## Suggested Commit Message

hard-tagspace: Phase 4 — integration preparation and compatibility layer
Add build support and shims. Switch tests to use tagspace::memory.
