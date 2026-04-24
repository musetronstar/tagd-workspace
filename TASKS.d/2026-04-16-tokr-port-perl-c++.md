# Task: Port Perl code to Modern C++

## Status

* PENDING: `tokr` is not port-complete; Phases 2-9 remain substantially unimplemented.
* COMPLETED: Phase 1 `model` foundation is implemented in `/home/inc/sandbox/hardF/tokr` and covered by CxxTest.
* COMPLETED: initial C++23 build/test scaffolding exists (`tokr/Makefile`, `tokr/tests/Makefile`).
* PENDING: update the remaining phases to follow the stronger C++23 doctrine established by the `tagd` Phase 1 refactor and summarized in `out/archive/2026-04-17-tagd-cpp23-phase1-aar.md` and `out/2026-04-18-tagd-c++-23-refactoring-history-progress-future.md`.

Port the `tokr/` application from Perl to modern C++. Follow the **Subtasks** and user prompts.

---

## Files

### Read

Only these files/directories may be accessed recursively with read permissions:

    docs/
    TASKS.d/
    ./*.md
    tagd/

### Read/Write

#### `hardF/` base directory

Go to `../../hardF/` — base directory for the following sub-directories:

    klasyfyr/
    tokr/

#### Perl Archives (Do Not Modify)

    tokr/TOKR
    tokr/TOKR_models

#### Write (Create or Modify)

    tokr/include/            # include files
    tokr/src/                # implementation files
    tokr/src/Makefile        # make source file
    tokr/tests/              # unit test and other test files
    tokr/tests/Makefile      # make source file
    tokr/Makefile            # orchestrate entire project build targets
    tokr/data/models/        # built models after training process
    tokr/data/train/         # training assets
    tokr/bin/tokr            # main executable (public facing)
    tokr/utils/              # tools and utilities for building, maintaining, analyzing tokr models, databases, etc.

---

## Subtasks

Source of truth for features: `tokr/docs/architecture.md`.

Build order is dependency-first: each phase must have passing tests before the next begins.

### Caveats (apply to all phases)

* Eat our own dogfood:
  * Reuse `tagd/` components wherever possible.
  * Speak and use TAGL; use `.tagl` config files.
  * Use `tagdb` as the storage layer — **not** BerkeleyDB.
* C++23 correctness doctrine:
  * Prefer ordinary value types with explicit ownership boundaries; no hidden shared mutable state unless a task explicitly justifies it.
  * Treat Rule of Zero as the default; when a type must spell special members, prove the reason in tests first and document the STL protocol seam with a concise intent comment.
  * Prefer `const`-correct APIs, cheap `const&` parameters for non-trivial inputs, and `noexcept` only where it is semantically defensible.
  * Keep data-model types free of DB/session handles; persistence and external tools belong behind explicit interfaces.
  * Add tests as contract specifications before implementation changes; each phase should leave behind a reusable verification seam, not only feature code.

---

### Phase 0 — C++23 foundation and doctrine alignment

**Status:** PARTIALLY COMPLETED

**Deliverable:** `tokr` proceeds as a modern C++23 codebase, not a line-for-line Perl transliteration.

* COMPLETED: project makefiles switched to C++23 (`e6dc2f6`, `8d6bbc4`, `ffd411d`).
* COMPLETED: the initial `model` type now follows explicit STL-friendly value semantics with `swap`, copy assignment, move operations, equality, and intent comments (`2dcc2ff`, `8a24cdf`, `9a3bb6c`, `415ee37`, `47fb87f`, `7dac470`).
* COMPLETED: tests prove the current foundation rather than assuming it (`89afe8d`, `e9cdae4`, `81e1b94`, `7ed3de0`, `7f907cb`, `2aa76bf`).
* PENDING: apply the same C++23 review standard to every future `tokr` type introduced in Phases 2-9.
* PENDING: require each new module to state its ownership model, protocol seams, and exception/`noexcept` posture where non-obvious.
* PENDING: prefer adapting `tagd` design lessons directly instead of reproducing Perl-era coupling, mutability, or persistence assumptions.

**Key contract proven by test:** foundational value-semantic types behave correctly under copy, move, swap, equality, and storage-snapshot workflows before higher layers depend on them.

---

### Phase 1 — `Model` struct

**Status:** COMPLETED in `/home/inc/sandbox/hardF/tokr`

**Deliverable:** Pure in-memory data type. No DB wiring.

* COMPLETED: define `Model` with fields: `tokes`, `normalize`, `samples`, `id`, `categories`, `must_haves`, `supplemental`, `distilled`.
* COMPLETED: `clear_state` strips transient fields before serialization.
* COMPLETED: `clone` provides a deep value copy without DB references.
* COMPLETED: `empty`, `num_tokes`, and `num_samples` give basic query seams for later phases.
* COMPLETED: `clean` and `clone_for_storage` establish the storage-snapshot seam earlier than originally planned because the C++23 refactor made the distinction explicit.
* COMPLETED: whole-model equality plus explicit copy/move/swap semantics are already part of the Phase 1 contract.

**Key contract proven by test:** `clear_state` and `clone` round-trip correctly.

---

### Phase 2 — Tokenizer

**Status:** PENDING

**Depends on:** Phase 1

* PENDING: `html` handler: walk the HTML parse tree, emit `html:tag:attr:value` tokens, deduplicate within document.
* PENDING: `http` handler: emit `http:header-name:value` tokens.
* PENDING: populate the `normalize` map at tokenization time for eligible tokens.
* PENDING: MIME-type dispatch table (minimum: `text/html`, `http`).
* PENDING: `intersect(a, b)` — set intersection of two `Model` token sets with normalization applied.
* PENDING: `normalize` step inside `intersect`:
  * Text normalization: word-set intersection for titles/headings/comments.
  * Link normalization: strip protocol, TLD, `www`; intersect path segments.
* PENDING: `is_feasible(unk, candidate, threshold)` — optimistic upper-bound pre-filter; skip intersection when max possible score cannot reach threshold.
* PENDING: tokenizer and intersection APIs should be reviewed with the same C++23 standard as `model`: value semantics by default, explicit intent comments only at non-obvious protocol seams, and tests first.

**Key contract proven by test:** Token output matches known fixtures; `intersect` correctness; normalization merges variants correctly; `is_feasible` rejects known-infeasible pairs.

---

### Phase 3 — Persistence layer

**Status:** PENDING

**Depends on:** Phase 1

Replace BerkeleyDB with `tagdb`. All DB access goes through an abstract interface.

* PENDING: abstract `DB` interface: `get`, `put`, `del`, `iterate`, tokes index (one key → many model IDs).
* PENDING: `tagdb`-backed implementations for:
  * Tokes index — maps `token → [model_id, ...]` (Btree with dup-sort semantics).
  * Models store — maps `model_id → Model` (serialized).
  * URL-ID bidirectional map — `url ↔ integer_id`.
  * Checkout store — `model_id → client_id` (pessimistic lock).
  * Discovered-matches store — `discovered_model_id → [url_id, ...]`.
* PENDING: named DB pairs: `url-tokes/url-models`, `tokr-tokes/tokr-models`, `discovered-tokes/discovered-models`.
* PENDING: `HashDB` — same interface as above, backed by `std::unordered_map`; used for transient work (anomaly detection) and unit tests.
* PENDING: no persistence object may leak DB ownership into `model`; keep serialization and storage concerns at the boundary.

**Key contract proven by test:** Put/get/iterate on tokes index; bidirectional URL-ID lookup; `HashDB` passes same interface tests.

---

### Phase 4 — Model operations

**Status:** PENDING

**Depends on:** Phases 1, 2, 3

* PENDING: `similarity_hits(model, tokes_db)` — reverse-lookup tokens → `{url_id: hit_count}`.
* PENDING: `norm_similarity_hits` — same, but normalize hit counts by stored model size to avoid bias toward large models.
* PENDING: `uniquify(model, url_tokes_db)` — remove tokens too common across the corpus to be discriminating.
* PENDING: `distill(seed, urls_db)` — iterative set-intersection algorithm:
  * Find candidates via `similarity_hits`, sorted descending by hit count.
  * Iterate up to `MAX_INTRSCT = 500` candidates:
    * Fetch candidate model; enforce `must_haves`.
    * Intersect running model with candidate.
    * On first successful intersection: record `min_overlaps = floor(num_tokes / 2)` (or user-specified floor).
    * On subsequent steps: skip if intersection would fall below `min_overlaps`.
    * Accept intersection → replace running model; add candidate URL to `samples`; reset `countdown` to current `num_tokes`.
    * Skip → decrement `countdown`; stop when `countdown` reaches zero.
  * Finalize: inherit `id`, `categories`, `must_haves`, `supplemental`, `samples` from seed; call `clean` to remove stale `normalize` entries.
* COMPLETED EARLY: `clean` — remove `normalize` entries whose tokens were dropped by intersection.
* PENDING: anomaly detection — pairwise similarity across samples; flag hosts whose pairs fall >1 std dev below mean.

**Key contract proven by test:** Distillation convergence on a toy corpus; `uniquify` removes high-frequency tokens; `min_overlaps` decay halts correctly.

---

### Phase 5 — Scoring (`Score`)

**Status:** PENDING

**Depends on:** Phases 2, 3, 4

* `Score` — holds references to a tokes DB, models DB, and a configurable threshold (default 80%).
* `score(unk_model)` pipeline:
  1. `norm_similarity_hits` — reverse toke lookup, normalize by model size.
  2. Feasibility pre-filter — skip candidates whose optimistic upper bound is below threshold.
  3. `intersect` with normalization — compute actual intersection.
  4. `must_haves` check — discard if required tokens dropped.
  5. Similarity calculation: `intersect.num_tokes / model.num_tokes × 100`.
  6. Supplemental vs. primary split — supplemental matches collected separately, capped at 2.
  7. Threshold gate — return `{id, categories, score}` or null.
* `MAX_INTRSCT = 15` — consider only the top 15 candidates by pre-filter hit count.
* Optional intersection tracking — record every model intersected and its score (debug mode).

**Key contract proven by test:** Score pipeline returns correct winner on fixtures; supplemental capping; threshold gate returns null when below threshold.

---

### Phase 6 — External integration (`ExtTools`)

**Status:** PENDING

**Depends on:** nothing internal (wraps `klasyfyr`)

* HTTP fetch wrapper around `klasyfyr::Krawler` — returns headers + HTML body.
* URL parsing wrapper around `klasyfyr::ContentStore::url_parts`.
* Category validation wrapper around `klasyfyr::Categories`.
* **All `klasyfyr` imports isolated here** — no other module imports `klasyfyr` directly.

**Key contract proven by test:** Fetch + tokenize a mocked URL; URL parsing produces correct parts; category validation rejects invalid input.

---

### Phase 7 — Discovery (`Discover::feed`)

**Status:** PENDING

**Depends on:** Phases 2, 3, 4, 5, 6

* `feed(url)` pipeline:
  1. Deduplication gate via URL-ID store — return early if URL seen (unless `add_exists`).
  2. Allocate URL ID immediately (marks URL as attempted even if tokenization fails).
  3. Fetch + tokenize via `ExtTools`.
  4. If no tokens produced, return without storing.
  5. Frame-link following — extract `<frame src>` links, feed recursively one level; disable frame-following during recursion.
  6. Score against curated `tokr` models — match at >= 90% → return (unless `add_scored`).
  7. Score against `discovered` models — match at >= 95% → record in `discovered-matches`, store URL tokes/model, return.
  8. `process_similarities`:
     * `uniquify` → `distill`.
     * If distilled and meets `num_samples >= threshold` and `num_tokes >= threshold`:
       * Uniqueness gate: discard if uniqueness < 0.8.
       * `better_discovery`: if new model is smaller, covers same URLs, scores >= 80% vs. existing → delete old, reprocess matched URLs, store new.
       * Else store new discovered model.
  9. Store original URL tokes/model in `urls_db` regardless of discovery outcome.
* `add_exists` / `add_scored` flags — control reprocessing behavior.
* Model checkout — pessimistic lock via checkout store; uncheckout on process exit.
* Reprocessing — when a discovered model is deleted, re-feed all matched URLs through `feed`.

**Key contract proven by test:** End-to-end feed on toy corpus; deduplication gate; frame-link one-level limit; `add_exists` / `add_scored` flag behavior.

---

### Phase 8 — Configuration

**Status:** PENDING

**Depends on:** nothing (pure config)

* Config struct: DB paths, file names, thresholds (`min_samples`, `min_tokes`, score thresholds, debug level, CDS flag).
* Load from `.tagl` config file (replaces `LocalConfig.pm` and `~/.tokrrc`).
* Per-session preferences (skip list) — load and save as TAGL.

**Key contract proven by test:** Config loads from `.tagl`; missing keys fall back to defaults; unknown keys are rejected.

---

### Phase 9 — Interactive REPL (`tokr`)

**Status:** PENDING

**Depends on:** Phases 1–8

* `readline`-based REPL with tab completion and persistent history (`~/.tokr_history`).
* Commands: `url`, `html`, `model`, `next`, `int`, `score`, `show`, `list`, `edit`, `filter`, `overlaps`, `must_haves`, `name`, `cats`, `sup`, `save`, `remove`, `uniquify`, `skip`, `checkouts`, `quit`.
* `SIGINT` handling: return to prompt on first signal; exit cleanly on second.
* `END` block equivalent: uncheckout any checked-out model on exit.
* Archive-mode guard: warn and prompt if `ARCHIVE_MODE` or `ARCHIVE_DIR` unset before model creation.
* Rerun file: after `save`, write all URLs that score against the saved model to `tokrseter-reruns.txt`.

**Key contract proven by test:** Smoke test — `url`, `score`, `save`, `quit` complete without error.

---

### Phase 10 — Testing infrastructure

**Status:** PARTIALLY COMPLETED

**Spans all phases — write incrementally alongside each phase.**

* COMPLETED: Phase 0/1 unit tests exist in `tokr/tests/Tester.h`.
* PENDING: unit tests per later phase (see "Key contract" in each phase above).
* PENDING: `Tester` — regression harness: run a sample URL set, verify scores against expected categories.
* PENDING: `QuickTest` — pre-save reciprocal check: warn if a model-to-be-saved matches a known test URL from a different category.
* COMPLETED: `tests/Makefile` and top-level `Makefile` are wired for the current foundation.
* PENDING: extend top-level and phase-local targets as new layers land.
* COMPLETED: explicit current verification command is `make -C /home/inc/sandbox/hardF/tokr tests`.
* PENDING: add explicit verification commands for each later deliverable; the task is not complete until all required tests pass.

---

### Build Order Summary

| Phase | Deliverable | Depends on |
| ----- | ----------- | ---------- |
| 0 | C++23 foundation and doctrine alignment | — |
| 1 | `Model` struct | — |
| 2 | Tokenizer + `intersect` + `is_feasible` | 0, 1 |
| 3 | Persistence (`tagdb` + `HashDB`) | 0, 1 |
| 4 | `distill` + `uniquify` + model ops | 0, 1, 2, 3 |
| 5 | `Score` pipeline | 2, 3, 4 |
| 6 | `ExtTools` (`klasyfyr` wrappers) | 0 |
| 7 | `Discover::feed` | 0, 2, 3, 4, 5, 6 |
| 8 | Config (`.tagl`) | 0 |
| 9 | REPL (`tokr` binary) | 1–8 |
| 10 | Testing infrastructure | spans all |

---

## Constraints

* Preserve behavior unless the task explicitly says otherwise.
* Keep diffs scoped, reviewable, and local to the stated scope.
* Do not split naturally related edits when they are needed to complete one tested deliverable.
* No new dependencies unless explicitly requested.
* Do not silently broaden scope when a missing prerequisite is discovered — stop and report.
* If unsure, stop and ask Socratic questions for clarity.
* If generated files or build products are expected, name them explicitly.
* If a report or plan is part of the task, distinguish completed work from proposed follow-on work.
* If the task changes a truth-bearing structure, state the source of truth explicitly.

### Priority order

1. User prompts.
2. Subtasks in this file (sourced from `tokr/docs/architecture.md`).
3. `README.md` and `AGENTS.md`.
4. Files referenced by the above.

---

## Language & Style

* Follow `STYLE.md`.
* Speak TAGL per `TAGL-README.md` when working in TAGL-oriented repos.
* Preserve the author's comments and design intent unless the task explicitly changes them.

---

## Tests

* Write or update tests at the boundary that proves the requested feature or contract.
* Prefer fast in-process tests first; system tests second when CLI or process behavior matters.
* Modified code must be tested.
* State the exact command(s) required for task completion.
* Task is not complete until the required test layer(s) pass.
* If the build or tests depend on workspace-relative paths, verify those paths explicitly.

---

## Acceptance Criteria

* Changes stay within the declared scope.
* The requested contract is preserved or improved as specified.
* Named tests/build commands pass.
* The resulting structure is easier to understand at the stated seam.
* The change reduces drift between code, tests, and documentation.

---

## Deliverable: Concise Report

After each phase, provide:

1. Summary of changes.
2. Test results (exact commands run and their output).
3. Open issues, concerns, or interesting observations.
4. Suggested concise git commit message.
