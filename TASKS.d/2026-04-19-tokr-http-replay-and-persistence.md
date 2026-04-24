# Task

Design and implement a small `tokr` HTTP replay/persistence seam that stores enough request/response truth to replay classification inputs deterministically, using `tagd` / TAGL conventions where they help and explicitly replacing the old Perl cache/archive behavior where it was crude or underspecified. This task should treat the legacy Perl archive layout as historical input, not as a format to copy blindly.

## Principles

* Own replayable HTTP truth explicitly: request identity, response status, headers, body bytes, and storage metadata.
* Eat our own dogfood where it helps: TAGL for metadata and `tagd`-style contracts for truth-bearing structures.
* Keep persistence separate from live transport; this layer records and replays completed fetch results.
* Preserve deterministic rebuild/retest workflows so `tokr` model work is not coupled to live web drift.
* Replace Perl convenience globals and loose file conventions with explicit C++23 types and tests.

## Scope

### Read
* `AGENTS.md`
* `docs/ai-assisted-dev-doctrine.md`
* `docs/refactor-task-template.md`
* `TASKS.d/2026-04-16-tokr-port-perl-c++.md`
* `TASKS.d/2026-04-19-tokr-http-requests-via-httagd-client.md`
* `/home/inc/sandbox/hardF/tokr/TOKR/ExtTools.pm`
* `/home/inc/sandbox/hardF/klasyfyr/Klasyfyr/ContentStoreRepos.pm`
* `/home/inc/sandbox/hardF/klasyfyr/Klasyfyr/krawlr.pm`
* `/home/inc/sandbox/hardF/klasyfyr/Klasyfyr/ContentStore.pm`
* sample legacy archive trees under `/home/inc/sandbox/hardF/klasyfyr/Klasyfyr/t/sites/`
* `tagd/tagl/*`
* `tagd/tagdb/*`

### Write
* `/home/inc/sandbox/hardF/tokr/include/*`
* `/home/inc/sandbox/hardF/tokr/src/*`
* `/home/inc/sandbox/hardF/tokr/tests/*`
* `/home/inc/sandbox/hardF/tokr/data/train/*`
* `/home/inc/sandbox/hardF/tokr/data/models/*`
* `/home/inc/sandbox/hardF/tokr/utils/*`
* `/home/inc/sandbox/hardF/tokr/Makefile`
* `/home/inc/sandbox/hardF/tokr/src/Makefile`
* `/home/inc/sandbox/hardF/tokr/tests/Makefile`
* `TASKS.d/2026-04-16-tokr-port-perl-c++.md`

### Non-goals
* no new external HTTP cache library
* no broad archive/malware repository redesign from `klasyfyr`
* no full discovery pipeline integration unless needed to prove the seam
* no tokenizer refactor in this task except what is needed to consume replayed results
* no hard-tag additions here; event vocabulary belongs in the dedicated HTTP event task

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Constraints

* preserve behavior unless the task explicitly says otherwise
* keep diff scoped, reviewable, and local to the stated scope
* do not split naturally related edits when they are needed to complete one tested deliverable
* no new dependencies unless explicitly requested
* follow priority
  1. user prompts
  2. user specified task `.md` file
  3. `README.md` and `AGENTS.md`
  4. files referenced by the materials above
* do not silently broaden scope when a missing prerequisite is discovered
* if generated files or build products are expected, name them explicitly
* if a report or plan is part of the task, distinguish completed work from proposed follow-on work
* if the task changes a truth-bearing structure, state the source of truth explicitly
* use the existing legacy Perl archive conventions only as comparative input
* prefer one explicit on-disk contract over a pile of convenience files with implicit meaning
* metadata should be readable and diffable; TAGL is preferred when it fits the truth cleanly
* body bytes may remain raw bytes on disk; do not force binary content through a text-only metadata format

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md` when working in TAGL-oriented repos
* preserve the author's comments and design intent unless the task explicitly changes them

## Source of Truth

Legacy behavior to study and react to:

* `/home/inc/sandbox/hardF/tokr/TOKR/ExtTools.pm`
* `/home/inc/sandbox/hardF/klasyfyr/Klasyfyr/ContentStoreRepos.pm::fetchUrl`
* `/home/inc/sandbox/hardF/klasyfyr/Klasyfyr/krawlr.pm`
* legacy archive examples under `/home/inc/sandbox/hardF/klasyfyr/Klasyfyr/t/sites/`, especially `_meta.txt`, `request.dat`, and `response.dat`

New source of truth to establish:

* one `tokr` replay/persistence contract that records enough HTTP truth to rerun tokenizer/model work deterministically

## Required Deliverable

Implement a small replayable persistence seam that can:

* accept a completed HTTP fetch result from `httagd-client`
* persist request/response truth plus storage metadata
* load that persisted result back into memory
* replay the stored result into later `tokr` processing without a live network request

The initial slice should explicitly decide:

* what lives in TAGL metadata
* what lives as raw byte payloads
* how request and response records are associated
* how content hashes and timestamps are represented
* whether the layout is URL-derived, content-derived, or hybrid

## Tests

* write or update tests at the boundary that proves the requested feature or contract
* prefer fast in-process tests first, system tests second when CLI or process behavior matters
* modified code must be tested
* state the exact command(s) required for task completion
* task is not complete until the required test layer(s) pass
* if the build or tests depend on workspace-relative paths, verify those paths explicitly

Required test layers:

* `make -C /home/inc/sandbox/hardF/tokr tests`
* focused unit tests proving persist -> load -> replay round-trips
* if a small tool/CLI is added, one system-level replay smoke test

## Acceptance Criteria

* `tokr` has one documented replay/persistence seam for HTTP fetch results
* the design explicitly references and improves on the old Perl archive behavior
* persisted data is sufficient to replay classifier/tokenizer input without a live request
* metadata format and raw payload layout are both explicit and test-covered
* no third-party replay/cache library is introduced
* changes stay within the declared scope and non-goals
* named tests/build commands pass
* the resulting structure is easier to understand at the stated seam
* the change reduces drift between code, tests, and documentation

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns, or interesting observations
4. suggested concise git commit message
