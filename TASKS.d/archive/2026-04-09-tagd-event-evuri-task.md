# Task

Create the first small, tested `tagd::event` model in `tagd` by following the existing `tagd::url` / HDURI pattern. Add the minimal session identity support needed for event ids while preserving existing `tagdb::session` behavior and public interfaces.

**Engineering Excellence**

* **We eat our own dogfood.**
* Event identity must preserve TAGL consistency: events are first-class semantic-relational things, not ad hoc log strings.
* Reuse the existing `tagd::url` / `hduri()` pattern before inventing new structure.
* The seams are the `tagd::abstract_tag` subclass boundary and the existing `tagdb::session` factory boundary.

## Scope

### Read
* `docs/ai-assisted-dev-doctrine.md`
* `tagd/tagd/include/tagd/url.h`
* `tagd/tagd/src/url.cc`
* `tagd/tagd/tests/UrlTester.h`
* `tagd/tagdb/include/tagdb.h`
* `tagd/tagdb/src/tagdb.cc`
* current `tagdb::session` usage in `tagl` and `httagd`
* `/home/inc/src/ulid/README.md`
* `/home/inc/src/ulid/skeeto-ulid-c/`
* `tagd/tagd/tests/Makefile`

### Write
* `tagd/tagd/include/tagd.h`
* `tagd/tagd/include/tagd/ulid.h`
* `tagd/tagd/include/tagd/event.h`
* `tagd/tagd/src/ulid.c`
* `tagd/tagd/src/event.cc`
* `tagd/tagd/tests/EventTester.h`
* `tagd/tagdb/include/tagdb.h`
* `tagd/tagdb/src/tagdb.cc`
* test/build integration files required to compile and run `EventTester.h`

### Non-goals
* no logger implementation
* no `tagd::error` changes
* no `tagd::error` inheritance change; add only a TODO comment to the class definition noting future event inheritance
* no parser/scanner changes
* no `tagsh` or `httagd` behavior changes
* no broad event ontology beyond the first `tagd::event` class and `evuri` syntax
* no `tagd::session_factory` implementation unless it is required to preserve the existing `tagdb::get_session()` / `new_session()` interface

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`.

## Required Design

Add a small internal ULID utility:

* use `skeeto-ulid-c` as the source to adapt
* keep the implementation in C, preferably C99
* create a dedicated `tagd/ulid.h` and `ulid.c` pair, similar in spirit to the existing `tagd/utf8.h` / `utf8.cc` utility placement
* do not port the ULID implementation to C++
* expose only the minimal API needed by `tagd::session`
* preserve the public-domain license notice in the adapted source

Create a minimal `tagd::session` base class:

* owns a session id
* returns the session id
* tracks a monotonic per-session sequence
* provides the sequence value needed for `evuri`
* uses the ULID utility for generated session ids
* creates a session timestamp in the constructor using UTC/Zulu time with fixed millisecond precision
* designs the sequence API for future thread-safety even if the current implementation remains single-threaded

Update `tagdb::session` to derive from `tagd::session` while preserving its current database context and error behavior. Keep `tagdb::get_session()` and `tagdb::new_session()` source-compatible for existing callers.

Define `tagd::event` analogously to `tagd::url`:

* subclass `tagd::abstract_tag`
* provide an `evuri()` method analogous to `url::hduri()`
* set event `_id` to the canonical `evuri`
* use `!` as the field delimiter, following HDURI collation practice
* encode literal delimiter characters inside field values
* do not validate `event_type_tag` against a `tagdb`

Document this initial `evuri` syntax in `tagd/include/tagd/event.h`:

```text
ev:time!host!program!session_id!sequence!event_type_tag
```

Rules:

* `evuri()` and `id()` are synonymous for event instances
* `time` is canonical UTC ISO 8601 with milliseconds: `YYYY-MM-DDTHH:MM:SS.mmmZ`
* `host` comes from the system hostname
* `program` is the tagd module/application name, such as `tagsh`, `httagd`, or `tagr`
* `session_id` uses `ssn_<ULID>`
* `sequence` is monotonic within the session
* `event_type_tag` is a TAGL tag id
* fields must be parsed and regenerated deterministically

Initial API decisions:

* `next_sequence()` returns the next sequence value and advances it
* the first returned session sequence value is `1`
* callers provide the event type tag id; internal callers should prefer hard tag macros where available
* test-only clock injection is out of scope unless needed to keep tests deterministic
* parser recognition of `ev:` is out of scope; parsing is class-level only
* future errors are expected to become events, likely by making `_error _type_of _event`; do not implement that here

## Tests

Create `tagd/tagd/tests/EventTester.h` modeled after `UrlTester.h` with one simple test proving construction, field access, canonical `evuri()` output, and round-trip construction from that `evuri`.

Add focused session tests proving `tagd::session` id access and monotonic sequence behavior. Existing `tagdb`, `tagl`, and `httagd` session behavior must remain unchanged.

Add a focused ULID utility test sufficient to prove generated ids are 26-character Crockford Base32 strings usable in session ids.

Required verification:

```sh
make -C tagd/tagd/tests
make -C tagd/tagdb/tests
make -C tagd/tagl/tests
make -C tagd/httagd/tests
```

## Acceptance Criteria

* `tagd::event` exists as a focused, first-class TAGL event identity model.
* `event.h` documents the `evuri` syntax clearly and concisely.
* `EventTester.h` proves the first simple `evuri` round trip.
* `tagd::session` provides session id and sequence without taking over unrelated session semantics.
* `tagd::event::id()` equals `tagd::event::evuri()`.
* session ids are generated through the internal ULID utility.
* ULID support is small, C-based, and isolated behind `tagd` APIs.
* `tagdb::session` still works through the existing `get_session()` and `new_session()` APIs.
* The implementation follows existing `tagd::url` patterns where practical.
* The diff stays small, reviewable, and within scope.
* Required tests pass.

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues or follow-on concerns
4. suggested concise git commit message
