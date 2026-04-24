# Task: C++23 Stage 2 — Clean Slate Pass · Phase 9

Close three deferred correctness gaps before moving into vocabulary-type
modernization (`std::string_view`, `std::span`). All three are self-contained
and low-risk. Complete each task fully before beginning the next.

## Principles

* Comment *why* at every new design site — not *what*.
* Keep each task's diff scoped and reviewable independently.
* Stop and report if any task reveals a non-trivial cascading change.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md` and `AGENTS.md`.

## Scope

### Read
* `httagd/include/httagd.h` (Task 1)
* `tagd/include/tagd/hard-tags.h` (Task 3)
* `tagdb/src/gen-hard-tags.gperf.pl` (Task 3)
* `tagdb/src/hard-tag.cc` (Task 3)
* All test files across modules — for verification

### Write
* `httagd/include/httagd.h` (Task 1)
* `tagd/include/tagd/hard-tags.h` (Task 3)
* `tagdb/src/gen-hard-tags.gperf.pl` (Task 3)
* `tagdb/src/hard-tag.cc` (Task 3 — regenerated output)
* All modules — for Task 2 caller fixes

### Non-goals
* No behavioral changes.
* No changes to TAGL grammar or parser.
* No opportunistic cleanup outside the stated tasks.
* If a task exposes a non-trivial prerequisite gap: stop and report.

---

## Task 1 — `tagd_template` ownership comment pass

### Background

Phase 7 deferred `tagd_template::_dict` / `_output` / `_owner` in
`httagd/include/httagd.h`. An `_owner` bool is present but its semantics
are undocumented — the same B-class seam pattern closed everywhere else in
Phase 7.

### What must be true after this task

* `_owner` carries a comment stating what it gates — which member it governs
  and what happens when it is true vs false.
* `_dict` and `_output` carry ownership class comments consistent with the
  Phase 7 pattern: "owned here", "borrowed", or "conditionally owned".
* Comment-only diff. Zero lines of code change.

### Verify

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd/httagd/tests
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

---

## Task 2 — Remove GCC `-Wno-unused-result` and fix surfaced violations

### Background

Phase 8 added `[[nodiscard]]` across `tagdb::tagdb`, `tagdb::sqlite`, and
`TAGL::driver`. The project builds with `-Wno-unused-result` which suppresses
GCC's mapping of `[[nodiscard]]` to `-Wunused-result`. The annotations are
present but silent at build time. Removing the flag makes the enforcement real.

### What must be true after this task

* `-Wno-unused-result` is removed from the build flags in every `Makefile`
  that carries it. Audit all `Makefile` files across `tagd`, `tagdb`, `tagl`,
  `tagsh`, `httagd`.
* The full build produces no new warnings after the flag is removed.
* Any call site that produces a warning must be resolved by one of:
  * Fixing the caller to actually check the return value — preferred.
  * Adding a `(void)` cast with a comment explaining why the discard is
    intentional — acceptable where a fix would change behavior.
* No `[[nodiscard]]` annotation is removed to silence a warning. The
  annotation is the contract; the caller must adapt.
* If removing the flag surfaces a warning in generated code that cannot be
  fixed without regenerating (lemon, re2c), document it and add a targeted
  suppression scoped to that file only — not a blanket flag.

### Constraints

* Do not remove `[[nodiscard]]` from any method to silence a warning.
* If a surfaced violation requires a non-trivial behavior change to fix,
  stop and report before proceeding.

### Verify

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd 2>&1 | grep -i warning
```

Must produce no `unused-result` or `nodiscard` warnings.

---

## Task 3 — `constexpr` hard tags

### Background

`tagd/include/tagd/hard-tags.h` defines all hard tag ids as preprocessor
`#define` string literals. In C++23 these can be `inline constexpr
std::string_view` — typed, namespaced, usable in `constexpr` contexts, and
visible to the debugger. The preprocessor definitions are invisible to the
type system and cannot be distinguished from arbitrary string literals.

`tagdb/src/gen-hard-tags.gperf.pl` is the only tool that reads `hard-tags.h`
directly — it parses the `#define` lines via regex to generate gperf input.
It must be updated before `hard-tags.h` is changed.

### What must be true after this task

**Generator (`gen-hard-tags.gperf.pl`):**
* Updated to parse `inline constexpr std::string_view HARD_TAG_FOO{"_foo"};`
  instead of `#define HARD_TAG_FOO "_foo"`.
* The generated gperf output is byte-for-byte identical to the current output
  for the same set of hard tags. Verify by diffing generator output before
  and after the `hard-tags.h` change.
* The generator must still correctly extract the tag id string, the gperf
  sub-relation, and the `tagd::part_of_speech` from the comment — the comment
  format on each line is unchanged.

**`hard-tags.h`:**
* All `#define HARD_TAG_*` definitions replaced with:
  ```cpp
  inline constexpr std::string_view HARD_TAG_FOO{"_foo"};
  ```
  in `namespace tagd` (or a nested namespace if that fits the existing
  structure better — agent decides and documents the choice).
* The `//gperf` comment format on each line is preserved exactly — the
  generator depends on it.
* All C++ call sites that use `HARD_TAG_*` as `const char*` (e.g. passed to
  functions taking `const std::string&` or `const char*`) must be audited.
  `std::string_view` constructs implicitly from string literals and converts
  to `std::string`, but does not decay to `const char*`. Any site passing a
  hard tag to a `const char*` parameter needs `.data()` or a local conversion.
  Audit all such sites before changing the header.

**Rebuild sequence (order matters):**
1. Update the generator.
2. Verify generator output matches current gperf input (diff).
3. Change `hard-tags.h`.
4. Run the generator to regenerate `hard-tag.cc` gperf input.
5. Run gperf to rebuild `hard-tag.cc` (slow — allow time).
6. Full build and test.

**`hard-tag.cc`:**
* Regenerated from the updated generator and gperf. No hand edits.

### Constraints

* The gperf comment format (`//gperf SUB_REL, tagd::POS_*`) on each line
  in `hard-tags.h` must not change — it is the generator's input protocol.
* Do not change the string values of any hard tag — these are semantic
  constants of the tagspace and must be identical before and after.
* If any call site requires a non-trivial fix beyond `.data()` or implicit
  conversion, stop and report before proceeding.
* The generator update and `hard-tags.h` change are one atomic commit —
  do not commit `hard-tags.h` without the updated generator.

### Verify

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

Full build and all test suites must pass clean after gperf regeneration.

---

## Tests — Completion Command

All three tasks must pass before this phase is complete:

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

## Acceptance Criteria

* `tagd_template` ownership comments match Phase 7 pattern. Comment-only diff.
* `-Wno-unused-result` removed from all Makefiles. Full build clean with no
  nodiscard warnings. All violations resolved by caller fix or documented
  intentional `(void)` cast.
* `hard-tags.h` uses `inline constexpr std::string_view`. Generator updated
  and produces identical gperf output. Full build and all tests pass after
  gperf regeneration.
* Each task's diff is independently reviewable.

## Deliverable: Concise Report

For each task:
1. Summary of changes.
2. Test results: exact command and output.
3. Open issues or non-trivial findings requiring follow-on work.
4. Suggested git commit message.
