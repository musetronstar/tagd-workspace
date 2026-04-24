# Task: TAGL C++23 Phase 3 – Parser, Scanner, Driver Modernization

**Goal**: Bring the TAGL layer (`tagl/`) to C++23 Engineering Excellence while preserving exact semantic truth (identical TAGL output for identical input, verified by existing tests).

## Principles (C++ Experts Razor)
- Zero-overhead abstractions (Stroustrup).
- Strong, compile-time contracts via concepts and `std::expected` (STL authors).
- RAII + deterministic resource management (Meyers/Stroustrup).
- Mathematical alignment: rank/tree/partial-order semantics must be expressed directly in types.
- TAGL remains the single source of truth for contracts.

## Scope
**Read** (inspect only):
- `tagl/include/tagl.h`, `tagl/src/tagl.cc`
- `tagl/include/parser.h`, `tagl/src/parser.y`
- `tagl/include/scanner.h`, `tagl/src/scanner.re.cc`, `tagl/src/tagdurl.re.cc`
- All tests in `tagl/tests/`
- `tagd-math-claude.pdf` (mathematical truths)

**Write**:
- `tagl/include/tagl.h` (modern driver)
- `tagl/src/tagl.cc`
- `tagl/src/parser.y` (minimal grammar updates only)
- `tagl/src/scanner.re.cc` (C++23 scanner)
- New: `tagl/include/tagl/concepts.h`, `tagl/include/tagl/token.h`, `tagl/include/tagl/driver.h`
- Update `tagl/tests/` as needed (upstream TDD)

**Non-goals**:
- Changing TAGL grammar semantics
- Touching tagdb/tagsh/httagd this phase

## Doctrine & Constraints
- Preserve identical TAGL output (tests must pass unchanged unless explicitly updated in this task).
- Use C++23 features where they give zero-overhead + stronger contracts (concepts, `std::expected`, `std::mdspan` for rank, modules if GCC/Clang support is stable).
- Mathematical truths (rank as prefix partial order, structural identity) must be expressed in types.
- Incremental: one reviewable, testable batch per commit.

## Acceptance Criteria
- All existing TAGL tests pass with identical output.
- Driver uses RAII + concepts for token/relation handling.
- Scanner is C++23 idiomatic (no raw pointers where possible).
- Parser.y remains minimal; heavy lifting moved to type-safe C++ layer.
- No runtime overhead introduced.
- Documentation gaps vs. C++ Core Guidelines noted in commit message.

## Deliverable: Concise Report
1. Summary of changes
2. Test results (all TAGL tests)
3. Open issues / next-phase suggestions
4. Suggested commit message

