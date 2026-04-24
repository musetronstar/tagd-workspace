# Task

Add a minimal `httagd` HTTP client seam that can issue one real HTTP request using the existing libevent/evhtp-oriented stack, and expose it through a small CLI binary. The goal is not a general-purpose user agent. The goal is one small, reviewable client boundary plus one simple executable that fits current `tagd` style and can grow later without fighting existing `httagd` structures.

## Principles

* Tighten the `httagd` client seam.
* Keep the contract small, explicit, and testable.
* Prefer existing `httagd` / evhtp request and response structures over inventing parallel abstractions.
* Preserve style, naming, comments, and local idioms already present in `tagd`.
* Make the CLI prove the seam instead of inventing a second path.

## Scope

### Read
* AGENTS.md
* docs/ai-assisted-dev-doctrine.md
* existing httagd/include/*
* existing httagd/src/*
* existing httagd/bin/*
* existing httagd/tests/*
* existing evhtp/libevent usage in the repo
* build rules

### Write
* `tagd/httagd/include/httagd-client.h`
* `tagd/httagd/src/httagd-client.cc`
* `tagd/httagd/bin/httagd-client`
* `httagd/tests/ClientTester.h`
* `httagd/tests/client-tester.exp`

### Non-goals
* no redesign of `httagd`
* no new dependencies
* no advanced HTTP features

## Constraints

* TDD required
* unit test → implementation → CLI → system test
* minimal API
* no scope creep

## Contract

Minimal API:

* construct request
* perform request
* return status + body
* deterministic failure

## CLI

Binary:

tagd/httagd/bin/httagd-client

Example:

$ httagd-client 'http://localhost:2112/dog'

Print response body to STDOUT.

## Tests

### Unit
`httagd/tests/ClientTester.h`

### System

Read:
Use `httagd/tests/tester.exp` as a model

Write;

`httagd/tests/client-tester.exp`

## Task Status

* COMPLETE: add minimal client seam in `tagd/httagd/include/httagd-client.h` and `tagd/httagd/src/httagd-client.cc`
* COMPLETE: add `tagd/httagd/bin/httagd-client` as a thin CLI over the seam
* COMPLETE: add unit coverage in `httagd/tests/ClientTester.h` for successful GET
* COMPLETE: add deterministic failure coverage for malformed URL and refused connection
* COMPLETE: add system coverage in `httagd/tests/client-tester.exp`
* COMPLETE: move `httagd-client` build ownership under `httagd/src/Makefile`
* COMPLETE: add `-v` client debug/header output while keeping the body on `STDOUT`
* COMPLETE: add shared server/client HTTP header logging through `httagd.h` / `httagd.cc`
* COMPLETE: log server request and response headers at debug level, with response body size but not response body
* COMPLETE: collect the final slice into one or more commits if not already committed

## Acceptance Criteria

* minimal client works
* CLI prints response
* tests pass
* style matches repo

## Deliverable

1. summary
2. tests
3. issues
4. commit message

## Addendum: Low-Hanging-Fruit User-Agent Follow-On

### Goal

Extend `httagd-client` from a minimal HTTP-only proof into a small but useful user agent that captures the highest-value 80/20 features people expect from a `curl`-like tool, without turning this into a broad redesign or dependency grab. HTTPS and redirects will be needed.

### Scope

### Read
* existing `httagd-client` seam and CLI
* current libevent HTTP and HTTPS client examples, including `/home/inc/src/libevent-2.1.12-stable/sample/https-client.c`
* existing `tagd` logging, error, and CLI idioms
* current `httagd` tests and build rules

### Write
* `tagd/httagd/include/httagd-client.h`
* `tagd/httagd/src/httagd-client.cc`
* `tagd/httagd/src/client-main.cc`
* `tagd/httagd/src/Makefile`
* `tagd/httagd/tests/ClientTester.h`
* `tagd/httagd/tests/client-tester.exp`

### Principles

* Keep one client seam; do not fork transport logic between library and CLI
* Prefer libevent/OpenSSL primitives already in the current dependency surface
* Add only features that materially increase real-world usefulness
* Preserve deterministic error reporting and repo style
* Keep each new feature in reviewable, testable batches

### Tasks

* COMPLETE: add HTTPS support
* COMPLETE: add bounded redirect following
* COMPLETE: keep verbose mode useful across HTTP, HTTPS, and redirect hops
* PENDING: add explicit `GET` and `HEAD` CLI method selection
  TODO: confirmed still missing; `client_request` supports `HTTP_HEAD`, but `tagd/httagd/src/client-main.cc` still parses only `[-v] <http-url>` and does not expose method selection
* PENDING: add minimal repeated `-H 'Key: Value'` request-header injection
  TODO: confirmed still missing; the current client code only adds fixed `Host`, `Connection`, and `User-Agent` headers and has no repeated CLI header option
* PENDING: add explicit timeout behavior
  TODO: confirmed still missing; no small explicit timeout contract or CLI/config seam is present in the current client task files

### Non-Goals

* no broad `curl` parity
* no `httagd` server redesign

### Constraints

* TDD remains required
* no new third-party dependencies beyond the current libevent/OpenSSL surface already in use
* keep the API minimal and avoid speculative abstraction

### Acceptance Criteria

* `httagd-client https://...` can perform one verified HTTPS GET
* `httagd-client` can follow at least one normal redirect chain safely
* verbose mode remains readable and useful across HTTP, HTTPS, and redirect cases
* failures remain deterministic
* style and naming still match `tagd`
