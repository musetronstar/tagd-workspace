# Task

Extend `tagd` hard-tag vocabulary and related tests so HTTP request and response events can be named and logged with a clearer hierarchy under the existing `_event:http` hard tag. The goal is not to model the whole HTTP protocol at once; the goal is to install a small, coherent event taxonomy that `httagd-client`, replay/persistence work, and later `tokr` tooling can rely on.

## Principles

* Grow the existing hard-tag tree surgically from `_event:http`; do not invent a parallel event vocabulary.
* Prefer a small semantic core that the logger and event URI machinery can consume immediately.
* Keep TAGL-facing truth explicit: if a hard tag exists in code, its intended conceptual hierarchy should be clear.
* Preserve current hard-tag generation and bootstrap mechanics.
* Add only the first practical HTTP method/status tags needed by current `httagd` and near-term `tokr` work.

## Scope

### Read
* `AGENTS.md`
* `docs/ai-assisted-dev-doctrine.md`
* `docs/refactor-task-template.md`
* `tagd/tagd/include/tagd/hard-tags.h`
* `tagd/tagd/hard-tags.md`
* `tagd/tagd/include/tagd/event.h`
* `tagd/tagd/src/event.cc`
* `tagd/tagd/tests/EventTester.h`
* `tagd/tagd/tests/LoggerTester.h`
* `tagd/tagdb/src/gen-hard-tags.gperf.pl`
* `tagd/tagdb/src/Makefile`
* `tagd/tagdb/src/hard-tag.cc`
* current `httagd` request/response handling

### Write
* `tagd/tagd/include/tagd/hard-tags.h`
* `tagd/tagd/hard-tags.md`
* `tagd/tagd/tests/EventTester.h`
* `tagd/tagd/tests/LoggerTester.h`
* `tagd/tagdb/src/hard-tags.gperf`
* any tightly related test/build file required by the hard-tag generation flow

### Non-goals
* no complete HTTP ontology
* no relation/value encoding for all status codes in this task
* no `tokr` transport or replay implementation here
* no logger redesign beyond what is needed to prove the new tags work

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
* preserve the existing hard-tag generation flow from `hard-tags.h` into the gperf lookup table
* do not add status-code relations yet unless the task explicitly grows to cover them

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md` when working in TAGL-oriented repos
* preserve the author's comments and design intent unless the task explicitly changes them

## Source of Truth

Current hard-tag source of truth:

* `tagd/tagd/include/tagd/hard-tags.h`

Conceptual target for this task:

```tagl
-- base http events
>> _event:http _sub _event;
>> _event:http:request _sub _event:http;
>> _event:http:response _sub _event:http;

-- request methods
>> _event:http:request:get _sub _event:http:request;
>> _event:http:request:head _sub _event:http:request;
>> _event:http:request:put _sub _event:http:request;
>> _event:http:request:post _sub _event:http:request;
>> _event:http:request:delete _sub _event:http:request;

-- response statuses
>> _event:http:response:ok;
>> _event:http:response:not_found;
```

Note: keep actual names aligned with existing repo conventions in `hard-tags.h`. If the current hard-tag naming style favors single-colon forms already present in code, preserve that style consistently and document the conceptual mapping.

## Required Deliverable

Install the first HTTP event hard-tag hierarchy under `_event:http`, with at minimum:

* request parent
* response parent
* method tags for `GET`, `HEAD`, `PUT`, `POST`, `DELETE`
* response tags for `ok` and `not_found`

Also document why the chosen names fit the current hard-tag style, and identify follow-on work for richer status-code relations without implementing it yet.

## Tests

* write or update tests at the boundary that proves the requested feature or contract
* prefer fast in-process tests first, system tests second when CLI or process behavior matters
* modified code must be tested
* state the exact command(s) required for task completion
* task is not complete until the required test layer(s) pass
* if the build or tests depend on workspace-relative paths, verify those paths explicitly

Required test layers:

* `make -C /home/inc/sandbox/codex/tagd-workspace/tagd/tagd/tests`
* `make -C /home/inc/sandbox/codex/tagd-workspace/tagd/tagdb/tests`
* any required build step that regenerates the hard-tag gperf table

## Acceptance Criteria

* `_event:http` grows a documented request/response hierarchy rather than ad hoc leaf tags
* the chosen hard tags are generated and lookupable through the existing hard-tag flow
* tests prove the new tags can be consumed by current event/logger paths where applicable
* conceptual TAGL hierarchy and actual hard-tag definitions no longer drift
* follow-on status-code relation work is noted but not bundled into this slice
* changes stay within the declared scope and non-goals
* named tests/build commands pass
* the resulting structure is easier to understand at the stated seam
* the change reduces drift between code, tests, and documentation

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns, or interesting observations
4. suggested concise git commit message
