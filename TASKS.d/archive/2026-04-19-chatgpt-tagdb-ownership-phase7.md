# Task: Ownership Truth — `tagdb` / top-layer handles (Phase 7)

## Status

* PENDING: this is the current follow-on ownership task and no non-archive report in `out/*.md` establishes completion yet.

## Goal

Make database-handle and session ownership truthful, local, and reviewable across
the remaining top-layer seams:

* `tagdb`
* `tagl`
* `tagsh`
* `httagd`

This phase follows Phase 6 boundary classification. It does **not** redesign
persistence, sessions, or backend architecture. It makes the current ownership
model explicit and verifies it through tests.

Preserve all existing behavior across:
* `tagdb`
* TAGL execution
* `tagsh`
* `httagd`

> The question in this phase is not “what should own this in an ideal redesign?”
> It is “what owns this now, and does the code make that true and obvious?”

## Principles

* Ownership truth is the seam.
* Prefer the smallest possible change that makes ownership obvious.
* Preserve current behavior; this is not a redesign phase.
* Distinguish clearly between:
  * owned here
  * borrowed here
  * deleted elsewhere
* TDD order is mandatory: audit, then tests, then implementation, then full verification.
* Do not invent a new ownership model in this phase.

## Scope

### Read
* `tagdb/include/tagdb.h`
* `tagdb/src/tagdb.cc`
* `tagdb/sqlite/include/tagdb/sqlite.h`
* `tagdb/sqlite/src/sqlite.cc`
* `tagdb/tests/Tester.h`
* `tagdb/tests/SqliteTester.h`
* `tagl/include/tagl.h`
* `tagl/src/tagl.cc`
* `tagl/tests/Tester.h`
* `tagsh/include/tagsh.h`
* `tagsh/src/tagsh.cc`
* `tagsh/tests/DriverTester.h`
* `tagsh/tests/LogTester.h`
* `httagd/include/httagd.h`
* `httagd/src/httagd.cc`
* `httagd/tests/Tester.h`
* `out/2026-04-19-tagdb-cpp23-phase4-aar.md`
* `TASKS.d/2026-04-18-chatgpt-tagdb-cpp23-phase4-task.md`
* `TASKS.d/2026-04-18-chatgpt-tagdb-sqlite-phase6.md`

### Write
* `tagdb/include/tagdb.h`
* `tagl/include/tagl.h`
* `tagl/src/tagl.cc`
* `tagdb/tests/Tester.h`
* `tagdb/tests/SqliteTester.h`
* `tagl/tests/Tester.h`
* `tagsh/include/tagsh.h`
* `tagsh/src/tagsh.cc`
* `tagsh/tests/DriverTester.h`
* `httagd/include/httagd.h`
* `httagd/src/httagd.cc`
* `httagd/tests/Tester.h`

### Non-goals
* No schema changes
* No query changes
* No sqlite internal redesign
* No smart-pointer migration across the codebase
* No concept introduction
* No parser/scanner changes
* No opportunistic cleanup outside ownership seams
* No persistence abstraction redesign

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md` and `AGENTS.md`.

---

## Type Classification

| Type | Category |
| ---- | -------- |
| `tagdb::tagdb` | execution-context boundary |
| `tagdb::sqlite` | execution-context implementation |
| `tagdb::session` | stateful helper |
| `TAGL::driver` | execution-context consumer |
| `tagsh` db/session handles | top-layer ownership seam |
| `httagd` db/session handles | top-layer ownership seam |

Core rule:

> Ownership must be obvious from construction, storage, and destruction paths.

---

## Contract 0 — Ownership audit

Before changing code:

Audit the following seams and classify each as A / B / C:

| Class | Meaning |
| ----- | ------- |
| A | Ownership already explicit and correct |
| B | Ownership correct but implicit / muddy |
| C | Ownership ambiguous or fragile |

Audit:
* database handle construction
* database handle storage type
* database handle destruction responsibility
* session creation via:
  * `get_session()`
  * `new_session()`
  * `own_session()`
* `TAGL::driver` destructor and `own_session()` behavior
* `tagsh` callback ownership
* `httagd` database-handle and viewspace ownership seams

If any Class C seam cannot be resolved locally without redesign, stop and report.

**Deliverable for this contract:** ownership table in the report.

**TDD:** Only add tests where they prove one of the contracts below. Do not add speculative tests.

---

## Contract 1 — Database-handle ownership is explicit

**What must be true after this contract:**
* For each touched class, DB handle ownership is obvious:
  * owned here
  * borrowed here
  * deleted elsewhere
* Constructor parameters, stored member types, and destruction paths agree.
* No touched seam leaves the reader guessing whether a `tagdb*` / `sqlite*`
  is borrowed or owned.

Do not force one universal model. State the current truth and tighten only where
the existing code is muddy.

**TDD:** Add or extend tests only if needed to prove current creation/destruction
behavior at the seam.

---

## Contract 2 — Session lifetime usage is explicit and verified

**What must be true after this contract:**
* `get_session()` usage is clearly stack/frame scoped.
* `new_session()` usage is clearly heap/lifetime scoped.
* `own_session()` paths are explicit about destructor-managed ownership.
* No touched caller mixes stack-style and heap-style session usage ambiguously.

This contract is about honesty, not redesign.

**TDD:** Add or extend tests proving:
* stack-lifetime session usage remains valid
* heap-lifetime session usage remains valid
* destructor-managed session ownership behaves as documented

---

## Contract 3 — Top-layer callback / helper ownership is explicit

**What must be true after this contract:**
* `tagsh` callback ownership is explicit and locally documented.
* Any `own_callback` / similar ownership flag remains behaviorally unchanged but
  becomes understandable from the declaration and destruction path.
* `httagd` helper ownership that touches the DB/session seam is documented or
  tightened in the smallest safe way.

No broad callback redesign in this phase.

**TDD:** Add or extend tests only if a touched seam cannot otherwise be verified.

---

## Contract 4 — Ownership comments are narrowed to enduring truths

Comment-only unless a minimal declaration/storage tweak is required by Contracts 1–3.

**What must be true after this contract:**
* Each touched ownership seam has a concise why-comment.
* Comments explain only enduring truths:
  * owned here
  * borrowed here
  * deleted elsewhere
  * stack lifetime
  * heap lifetime
* Remove or replace any frustrated or misleading ownership comments in touched code.
* No speculative architecture comments.

This contract succeeds if the next developer can answer “who deletes this?” and
“how long does this live?” without reconstructing the control flow mentally.

---

## Constraints

* Preserve all observable behavior.
* Do not redesign `tagdb::session` ownership model in this phase.
* Do not introduce broad smart-pointer conversions.
* Do not broaden from ownership truth into persistence redesign.
* Preserve existing comments and TODOs unless they are factually wrong after the change.
* If a seam cannot be made honest without a larger redesign, stop and write the follow-on task.

## Tests

After each meaningful contract:
```bash
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagdb/tests
```

When `TAGL::driver`, shell, or HTTP ownership seams are touched:
```bash
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagl/tests
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagsh/tests
cd ~/sandbox/codex/tagd-workspace && make -C tagd/httagd/tests
```

Full build verify after Contract 3:
```bash
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

## Acceptance Criteria

* DB handle ownership is explicit at all touched seams.
* Session lifetime usage patterns are explicit and verified.
* Callback / helper ownership is explicit at all touched seams.
* No ambiguous ownership remains in touched code.
* All required tests pass unchanged unless this task explicitly adds ownership-boundary tests.
* Full build clean.
* Diff is scoped, reviewable, and contains no unrelated changes.

## Deliverable: Concise Report

1. Ownership classification table (A / B / C)
2. Summary of changes per contract
3. Test results: exact commands and outputs
4. Ambiguous seams or deferred follow-on work
5. Suggested concise git commit message

## Core Rule

> This phase does not redesign ownership.
> It makes current ownership truthful, local, and reviewable.

---

## Return-Contract Tightening Guidance

This phase exposed a broader C++23 correctness issue adjacent to ownership:
some `tagd` / `tagdb` APIs mix mutation, ambient error state, and returned
`tagd::code` in ways that make it too easy to ignore failure.

The codebase should tighten toward the following style:

1. Mark genuinely result-bearing functions `[[nodiscard]]`.
   This applies most strongly to pure or near-pure validators, parsers,
   builders, and mutation seams whose returned `tagd::code` is required for
   correct control flow.
2. Refactor call sites to consume the returned code immediately.
   Preferred shape:
   `const tagd::code rc = ...; if (rc != tagd::TAGD_OK) return rc;`
3. Shrink APIs that both mutate and report errors through side channels.
   Where feasible, split preflight / validation from mutation, and avoid
   contracts that require the caller to reconstruct truth from both a return
   code and ambient object/session state.
4. Reserve `(void)` discard only for explicitly documented best-effort paths.
   If a return value is intentionally ignored, the code should say why, ideally
   through a named helper or a concise intent comment.

### Follow-on implications

* Treat ignored `tagd::code` as technical debt, not as normal style.
* Prefer making “must-check” seams obvious and compiler-assisted.
* Keep best-effort error decoration explicit and local.
* Do not spray `[[nodiscard]]` blindly; use it where the contract truly requires
  the caller to inspect the result.

### Immediate audit targets

* `abstract_tag::relation(...)` and adjacent mutation helpers
* `not_relation(...)`
* `rank::init(...)`
* `url::init(...)`
* `event::init_evuri(...)`
* `tagdb` / `sqlite` helper calls that currently mutate plus return `tagd::code`
* current `(void)...relation(...)` sites in `tagdb/sqlite/src/sqlite.cc`
