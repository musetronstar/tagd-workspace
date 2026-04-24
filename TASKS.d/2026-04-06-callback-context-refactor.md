# Task

## Status

* PENDING: callback ownership/wiring is still implicit and side-effectful; what is left is the explicit callback-context boundary cleanup called out in `out/2026-04-06-refactor-closeout-audit.md`.

Refactor the `tagl` callback boundary so callback execution context is passed
explicitly rather than being reached through hidden mutable driver back-pointers.

## Scope

Files which can be changed:

* `tagd/tagl/include/tagl.h`
* `tagd/tagl/src/tagl.cc`
* `tagd/tagl/tests/Tester.h`
* `tagd/httagd/include/httagd.h`
* `tagd/httagd/src/httagd.cc`
* `tagd/httagd/tests/Tester.h`
* any small new `tagd/tagl/*` support file only if it clearly improves the
  callback boundary more than adding to `tagl.cc`

## Context

The scanner/parser/tagdurl refactor clarified many ownership boundaries, but
`TAGL::callback` still depends on a mutable `driver*` back-pointer.

That shape works today, but it is not well aligned with the intended
architecture:

* libevent-buffer driven push flow
* share-nothing / message-passing design philosophy
* possible future worker-thread or queued execution models

The callback boundary should fit a model where one completed parse event is
delivered with explicit context, rather than requiring the callback object to
reach back into mutable driver state.

Before implementation proceeds, one callback-boundary shape must be chosen and
documented. "Explicit context" is not specific enough by itself.

The design choice must be made between approaches such as:

* passing `driver&` directly
* passing a narrow `callback_context`
* passing only fully expanded arguments needed by each callback method

That choice determines the blast radius and ownership semantics of the whole
refactor. It should not be guessed implicitly during implementation.

## Refactor Direction

The desired direction is:

* callback methods receive the context they need explicitly
* callback objects do not depend on a hidden mutable `driver*` binding
* the driver remains the coordinator for scanner, parser, callback, and session
  flow
* the callback boundary remains compatible with single-threaded worker queues
  while avoiding assumptions that prevent future safe concurrency

This task is not about introducing threads. It is about avoiding a shared-state
callback shape that would make future concurrency or queued dispatch harder.
Share-nothing and message-passing are design pressures here, not a requirement
to implement speculative infrastructure now.

## Design Notes

Prefer a callback boundary that behaves like message delivery:

* one event
* one explicit payload
* explicit access to required execution/session context

over a callback object that holds implicit driver state.

This should support:

* current single-threaded event-buffer flow
* future worker-queue execution
* possible later threaded execution where share-nothing boundaries matter

The callback interface should move toward:

* explicit arguments
* isolated state
* less mutable coupling between callback and driver

While the old `callback::_driver` back-pointer still exists during migration,
binding behavior should remain confined to one intentional internal path rather
than being spread across constructors, setters, and ad hoc repair code.

## Naming Guidance

Use names that reflect actual domain meaning.

The word `constrained` is reserved for `constrain_tag_id` and the tag-id
matching mechanism it describes. Do not reuse `constrained` as a generic prefix
or adjective for unrelated callback, message, or body-preparation helpers.

Prefer names that describe:

* callback context
* message delivery
* event payload
* session access
* request path validation
* subject preparation

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Design Principles

+ Interative & TDD - Think small
  1. Write test according to user requirements
  2. Implement code according to user desired change of behaviour or constrainsts
     Write deep code according to specification, not shallow code just to pass a test
  3. Pass test
  4. Report back to user
  5. Ask to proceed with next iteration (unless already instructino to proceed).
+ small pure functions
+ deterministic translation
+ composable pipeline
+ clear error behavior
+ explicit context is preferred over hidden mutable state
+ design should remain friendly to both single-threaded worker queues and
   possible future concurrency

## Constraints

+ preserve behavior
+ keep diff small
- no new dependencies
+ do not widen scope into parser grammar changes or unrelated tagdurl semantics
+ do not introduce thread primitives as part of this task
+ do not rename `constrain_tag_id`
+ do not expand use of hidden shared mutable callback/driver state
+ follow priority
  1. user prompts
  2. user specified task `.md` file
  3. `README.md` and `AGENTS.md`
  4. files references encountered when processing
     the files above should be folowed as needed

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md`

## Tests

* update tests as needed
* modified code must be tested
* tests must pass before task is complete
* before changing callback virtual signatures, document the chosen callback
  boundary shape and the minimal migration path
* prefer the smallest tests that prove:
  * callback behavior remains correct
  * current callback binding behavior stays correct during the transition
  * required context is available without relying on hidden rebinding
  * include-file and request-driven paths still work

## Acceptance criteria

* within set boundaries
* one explicit callback-boundary design is chosen and documented before virtual
  interface changes begin
* callback execution context is clearer and more explicit
* callback behavior remains correct
* while legacy binding remains, it is established through one intentional
  internal path or one clearly dominant internal path
* the design moves away from hidden shared mutable state
* tests pass

## Deliverable: Concise Report

1. summary of changes
2. test results
3. chosen callback-boundary design and why it was selected
4. open issues, concerns or interesting observations
