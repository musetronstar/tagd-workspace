# tagd Logging Guide

Status: active reference
Date: 2026-04-11

## Purpose

This note captures the current logging direction for `tagd`.

The goal is to improve and extend existing logging, not replace it.

## Rule

Severity level answers operational importance.

Event type answers what happened.

## Levels

* `EMERGENCY`
  System unusable.
* `ALERT`
  Immediate operator action required.
* `CRITICAL`
  Major subsystem failure.
* `ERROR`
  A specific operation failed.
* `WARNING`
  Abnormal but tolerated.
* `NOTICE`
  Significant normal system fact.
* `INFO`
  Routine operational fact.
* `DEBUG`
  Development and diagnosis detail.

## Operation Event Rules

Every tagspace operation should have an event form that records:

1. canonical TAGL operation
2. `tagd_code`
3. structured error if one occurred

Use levels as follows:

* successful committed `put` and `del` operations log at `NOTICE`
* failed `put` and `del` attempts log at `ERROR`
* successful `get` and `query` operations log at `INFO`
* failed `get` and `query` operations log at `ERROR`
* scanner, parser, SQL, and internal mechanics log at `DEBUG`

This gives one simple policy:

* `NOTICE` tells the mutation story
* `ERROR` tells the failed-operation story
* `INFO` tells the ordinary read-operation story
* `DEBUG` tells the implementation story

## Event Types

Prefer concrete event types:

* `_tagdb_put_event`
* `_tagdb_del_event`
* `_tagdb_get_event`
* `_tagdb_query_event`

Avoid vague event types like `_mutation_event`.

## Replay Rule

Replay only successful committed mutation events.

That means:

* replay `NOTICE`-level `_tagdb_put_event`
* replay `NOTICE`-level `_tagdb_del_event`
* do not replay failed mutation events
* do not replay `get` or `query` events

If a tagspace is loaded from `bootstrap.tagl` while mutation events are logged, replaying the successful mutation events should recreate the same tagspace.

## Current Direction

The recent scanner and parser work confirms the right method:

* improve one role at a time
* improve one level at a time
* keep output readable and scannable
* preserve structured `tagd:error`

## Suggested Commit Message

`out: tighten tagd logging guide around operation-event levels`
