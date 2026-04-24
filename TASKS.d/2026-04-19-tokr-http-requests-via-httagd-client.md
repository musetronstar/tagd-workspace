# Task

Make `tagd/httagd/bin/httagd-client` the primary HTTP fetch seam for the `tokr` C++ port, and evolve that seam only as needed to support `tokr`'s real fetch contracts. The goal is not a second crawler stack inside `tokr`; the goal is one reviewable HTTP request path that `tokr` can call, test, and reason about while staying aligned with current `tagd` design and logging/event direction.

## Principles

* Own the HTTP fetch boundary in `httagd-client`, not in ad hoc `tokr` networking code.
* Preserve one transport seam across library, CLI, and later `tokr` integration.
* Keep `tokr` focused on classification/domain logic; HTTP mechanics belong in the dedicated client seam.
* Tighten the contract around request method, response status, headers, and body so later replay/persistence work has a stable source of truth.
* Prefer extending the existing `httagd` seam over reintroducing Perl-era `klasyfyr::Krawler` coupling.

## Scope

### Read
* `AGENTS.md`
* `docs/ai-assisted-dev-doctrine.md`
* `docs/refactor-task-template.md`
* `TASKS.d/2026-04-16-httagd-client-task.md`
* `TASKS.d/2026-04-16-tokr-port-perl-c++.md`
* `out/2026-04-18-tagd-c++-23-refactoring-history-progress-future.md`
* `tagd/httagd/include/*`
* `tagd/httagd/src/*`
* `tagd/httagd/tests/*`
* `/home/inc/sandbox/hardF/tokr/TOKR/ExtTools.pm`
* `/home/inc/sandbox/hardF/tokr/TOKR/Discover.pm`
* `/home/inc/sandbox/hardF/tokr/TOKR/utils/*.pl`

### Write
* `tagd/httagd/include/httagd-client.h`
* `tagd/httagd/src/httagd-client.cc`
* `tagd/httagd/src/client-main.cc`
* `tagd/httagd/src/Makefile`
* `tagd/httagd/tests/ClientTester.h`
* `tagd/httagd/tests/client-tester.exp`
* `TASKS.d/2026-04-16-tokr-port-perl-c++.md`

### Non-goals
* no general-purpose `curl` parity
* no second HTTP implementation inside `tokr`
* no replay/archive persistence in this task
* no tokenizer, HTML parsing, or scoring work
* no `klasyfyr` fetch-path maintenance beyond identifying legacy behavior being replaced

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
* use `httagd-client` as the primary HTTP user agent for `tokr`; do not introduce a competing fetch stack
* keep the API explicit about request method, response status, response headers, and response body
* prefer value-returning or explicitly owned result structures over ambient mutable callback state

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md` when working in TAGL-oriented repos
* preserve the author's comments and design intent unless the task explicitly changes them

## Source of Truth

* Current HTTP client seam: `tagd/httagd`
* Legacy `tokr` fetch intent: `/home/inc/sandbox/hardF/tokr/TOKR/ExtTools.pm::fetch_url`
* `tokr` architecture and current plan: `TASKS.d/2026-04-16-tokr-port-perl-c++.md`

## Required Deliverable

Tighten `httagd-client` until `tokr` can depend on it for:

* explicit `GET` and `HEAD`
* deterministic status/header/body capture
* deterministic failure surface
* a seam that later replay/persistence code can serialize without guessing

## Tests

* write or update tests at the boundary that proves the requested feature or contract
* prefer fast in-process tests first, system tests second when CLI or process behavior matters
* modified code must be tested
* state the exact command(s) required for task completion
* task is not complete until the required test layer(s) pass
* if the build or tests depend on workspace-relative paths, verify those paths explicitly

Required test layers:

* `make -C /home/inc/sandbox/codex/tagd-workspace/tagd/httagd/tests`
* any focused client system test added under `tagd/httagd/tests/client-tester.exp`

## Acceptance Criteria

* `httagd-client` is the documented primary HTTP request path for the `tokr` port
* the seam can issue at least `GET` and `HEAD` without `tokr` inventing transport code
* the seam exposes status, headers, and body in one coherent result contract
* failures remain deterministic and test-covered
* no competing HTTP fetch implementation is introduced in `tokr`
* changes stay within the declared scope and non-goals
* named tests/build commands pass
* the resulting structure is easier to understand at the stated seam
* the change reduces drift between code, tests, and documentation

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns, or interesting observations
4. suggested concise git commit message
