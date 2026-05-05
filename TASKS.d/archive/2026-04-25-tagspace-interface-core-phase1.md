# tagspace interface task - phase 1

## Goal

Define the initial pure abstract base class `tagspace` as a near drop-in replacement for `tagdb::tagdb`.

## Principles

- Start with Option A: strict drop-in compatibility so `tagl`, `tagsh`, and `httagd` can switch with minimal changes.
- `tagspace` is a pure abstract base class.
- `tagd` must not depend on `tagspace`.
- Keep the interface minimal but sufficient for current TAGL usage.

## What Success Looks Like

A clean `include/tagd/tagspace.h` with:

- Pure virtual methods mirroring the main `tagdb::tagdb` operations (`get`, `put`, `del`, `query`, `exists`, `pos`, etc.)
- Clear mathematical comments where appropriate
- No implementation — only the contract
- The design allows a thin shim for compatibility during integration

## Task

Create `include/tagd/tagspace.h` with the pure abstract base class `tagspace`.

Focus only on the core methods needed for existing TAGL code to compile after swapping `tagdb` → `tagspace`.

Do not implement `hard_tagspace` or advanced topological views yet.

## Acceptance Criteria

- The abstract interface compiles cleanly.
- It covers the main operations used by TAGL.
- `make clean && make tests` passes in the clean-room (with a minimal stub if needed).

Provide a concise report before starting implementation.

