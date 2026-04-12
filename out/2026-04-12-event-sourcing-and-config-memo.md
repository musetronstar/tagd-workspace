# tagd Event Sourcing and TAGL Config Memo

Status: active reference
Date: 2026-04-12

## Purpose

Capture the current direction so it is not lost:

* event sourcing as a first-class `tagd` property
* replayable mutation events
* multiple tag printing modes
* future `_config_db` driven by TAGL
* command arguments represented in `_config_db`

## Core Distinction

There are two different truth-bearing artifacts:

* `tagdb::dump()`
  A canonical TAGL snapshot of full tagspace truth at one point in time.
* event log
  A canonical history of significant operations over time.

Restoring a `dump()` should recreate the same final tagspace truth.
Restoring a `dump()` does **not** recreate provenance, sequencing, or event history.

Therefore:

* snapshot and event history must remain separate concepts
* losing the db but keeping replayable mutation logs should still allow reconstruction
* backups of logs remain important even when canonical dumps exist

## Event Sourcing Direction

`tagd` is moving toward an event-sourced model:

* successful committed mutations are durable history
* current tagspace state is a materialized result of those mutations
* event logs should allow replay into a fresh tagspace

This does not require every emitted event to be replayable.

The replayable subset should be narrow and intentional:

* committed `put`
* committed `del`

The following are operationally useful but not state-reconstruction inputs:

* failed mutations
* `get`
* `query`
* deep trace/debug output

## Replayable Events

Replayable events must preserve canonical mutation intent, not just event identity.

Replay requires:

* deterministic ordering
* successful commit status
* canonical operation content
* stable event typing

Event identity alone is not enough. An EVURI says that an event happened.
Replay requires the mutation payload in a canonical form.

Current guidance remains:

* replay successful committed mutation events only
* do not replay failed mutation events
* do not replay read/query events

## Events As Tags

The design strength of `tagd` is that events are not opaque log records.
Events are tags and can carry semantic relations.

That means event records can eventually express:

* operation type
* result code
* subject tag
* command cause
* session/program identity
* structured error details
* links into adjacent tagspaces

This is stronger than ordinary logging because the system can describe its own
behavior in the same semantic model it uses for ordinary data.

## Event Naming

Hard-tag event naming should follow URI-style containership naming from
`tagd/tagd/hard-tags.md`:

* `_event`
* `_event:command`
* `_event:tagdb`
* `_event:tagdb_put`
* `_event:http`

Avoid suffix-style forms such as `_tagdb_put_event` when the tag already has a
clear superordinate family.

## Tag Printing Modes

Current printing is centered on one canonical stream rendering.
That is no longer sufficient.

We need an explicit rendering seam with at least distinct modes such as:

* canonical
* log

Canonical mode:

* may contain newlines
* is organized for readability
* is suitable for `dump()` and state-oriented output

Log mode:

* must not contain embedded newlines
* must be deterministic
* must be safe for grep/awk/sed and line-oriented tooling
* should preserve enough structure for replay and later ingestion

Do not overload one ostream representation with incompatible invariants.

## Log Format Direction

`dump()` output and log output should not be forced into the same presentation form.

Recommended separation:

* `dump()` remains canonical TAGL snapshot output
* event logs remain append-only operational history
* both stay TAGL-native in semantics even if rendered differently

For log-oriented rendering, a TAB-separated single-line discipline is promising:

* grep-able
* awk-able
* append-only friendly
* safe for line-oriented replay tooling

Important rule:

* replayable log records and event/tag log renderings must not contain newlines

## `_config_db` Direction

Longer term, configuration should become a tagspace backed by a `config.tagl`
file and represented as `_config_db`.

That implies:

* configuration lives in TAGL, not a parallel ad hoc format
* config can be queried with ordinary tagspace operations
* config becomes introspectable and semantically related to the rest of the system

This is preferable to continually enriching one-off argv parsing code.

## Command Args In `_config_db`

Command-line options should eventually have hard tags and be parsed into TAGL.

That means:

* define hard tags for supported command/config options
* map argv into TAGL/config facts
* load those facts into `_config_db`
* query effective configuration through ordinary tagspace queries

This supports a cleaner future model:

* file config
* command-line config
* runtime config inspection
* one semantic representation of options

Because this direction is planned, transitional CLI interfaces such as current
`--log-level` parsing should not be over-designed unless they become painful.

## Adjacent Tagspaces

Adjacent tagspaces that refer back to a primary tagspace may provide richer
history than the primary materialized state alone.

Potential uses:

* full event history
* operational analytics
* provenance links
* recovery metadata
* higher-order interpretations of command and db behavior

This should be treated as an extension of the event-sourcing model, not a
replacement for canonical state snapshots.

## Practical Guidance

Near-term priorities:

* preserve replayability of committed mutation logs
* keep event naming ontology consistent
* introduce explicit print/render modes before log formatting drifts
* avoid premature CLI parsing redesign while `_config_db` remains forthcoming

## Suggested Commit Message

`out: record event sourcing, replay, printing-mode, and config-db direction`
