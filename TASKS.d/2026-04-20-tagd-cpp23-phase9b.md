# Task: C++23 Stage 2 — Clean Slate Pass · Phase 9B

Capture the deferred foundational work exposed by Phase 9 Task 3: hard tags
can become typed read-only vocabulary only if tag identity seams stop treating
`abstract_tag` as a mutable assembly buffer. This phase is not more vocabulary
modernization. It is a value-type truthfulness pass on tag identity.

Becoming const correct will cause fractures in the system, requiring design changes.
Do not regress and violate this task just to pass tests or to play it safe.
The system will break before we can fix it.

## Principles

* Comment *why* at when appropriate — never *what*.
* Keep the phase scoped to identity construction and immutability seams.
* Preserve behavior. This is a structural correctness pass, not a feature pass.
* Do not replace hard tags with string literals
* Stop and report if the work requires a new public builder vocabulary type.
* Stop and ask question if you are uncertain.

## Doctrine

Follow `docs/cpp23-excellence-guide.md`

## Scope

### Read
* `tagd/include/tagd.h`
* `tagd/include/tagd/url.h`
* `tagd/src/tagd.cc`
* `tagd/src/url.cc`
* `tagdb/sqlite/include/tagdb/sqlite.h`
* `tagdb/sqlite/src/sqlite.cc`
* `tagl/src/parser.y`
* `tagl/include/tagl.h`
* Relevant tests across `tagd`, `tagdb`, `tagl`

### Write
* `tagd/include/tagd.h`
* `tagd/include/tagd/url.h`
* `tagd/src/tagd.cc`
* `tagd/src/url.cc`
* `tagdb/sqlite/src/sqlite.cc`
* `tagl/src/parser.y`
* Generated parser output only if regeneration is required by the task
* Tests required to lock the new construction contract

### Non-goals
* No new public `builder` or `factory` vocabulary type.
* No opportunistic `string_view` propagation unrelated to identity seams.
* No TAGL grammar changes beyond what is required to finish identity before
  tag construction.
* No behavioral changes to parse, query, or storage semantics.
* If immutable identity requires a larger redesign of `predicate_set`,
  `errorable`, or callback ownership: stop and report.

---

## Task 1 — Make `abstract_tag` identity constructor-only

### Background

The excellence guide's Expert's Razor says the type system must express the
mathematical truth. For `abstract_tag`, identity is carried by `_id`,
`_sub_relator`, `_super_object`, and `_rank`. Today those fields can be
mutated after construction, which makes a value type double as a scratch
buffer. Phase 9 Task 3 exposed this seam when `HARD_TAG_*` became typed
vocabulary instead of preprocessor string literals.

### What must be true after this task

* `abstract_tag` identity fields are immutable after construction:
  * `_id`
  * `_sub_relator`
  * `_super_object`
  * `_rank`
* Public mutators for those fields are deleted or removed.
* `relation()` and other predicate mutation seams remain available — predicates
  are not part of the tag identity contract for this task.
* The class comment or a nearby intent comment states why identity is immutable:
  a constructed tag value must not change which point in tagspace it denotes.
* Any helper that previously depended on mutating identity after construction
  is refactored, not papered over with `const_cast`, placement new, or a new
  public builder type.

### Constraints

* `abstract_tag` should remain an STL-friendly value type  const correct.
* Do not add a new public "abstract tag builder" types.
* Do not weaken the immutability claim by leaving one identity mutator behind
  "temporarily."

### TDD

Add compile-time or unit-test coverage proving identity cannot be reassigned
after construction and runtime coverage proving predicate mutation still works.

### Verify

```
cd ~/sandbox/codex/tagd-workspace/tagd/
make clean && make tests
```

---

## Task 2 — Refactor parser construction to finish identity before emission

### Background

`parser.y` already constructs most tags near the right seam with `NEW_TAG` and
`NEW_REFERENT`, but reductions still mutate `_sub_relator` and
`_super_object` after the object exists. If identity is constructor-only, the
parser must accumulate identity parts first and then emit the final tag value
in one shot.

### What must be true after this task

* Parser reductions no longer rely on post-construction mutation of tag
  identity fields.
* The parser still emits the same effective tag values and errors for the same
  inputs.
* If temporary parse-time storage is needed, it is local parser state or
  reduction values — not a second public type in `tagd`.
* Comments explain why the parser now defers object emission until identity is
  complete.

### Constraints

* No TAGL grammar expansion or user-visible syntax change.
* Do not introduce heap churn just to shuffle identity parts around if an
  existing reduction value can carry them.

### TDD

Use existing parser tests as the behavioral contract. Add at least one test
covering a subject with explicit sub-relator and super-object so the
constructor-only identity path is exercised.

### Verify

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagl/tests
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

---

## Task 3 — Refactor sqlite hydration and transform paths to one-shot identity construction

### Background

`sqlite.cc` is the main mechanical blocker. It default-constructs
`abstract_tag` values and then mutates `_id`, `_sub_relator`, `_super_object`,
and `_rank` while decoding rows, referents, and URL forms. That makes storage
hydration depend on the very mutability this phase is meant to remove.

### What must be true after this task

* Row hydration in `sqlite::get(...)` constructs a complete tag identity in one
  shot, then attaches relations.
* Referent encode/decode helpers no longer rewrite identity fields on an
  already-constructed `abstract_tag`.
* URL/HDURI paths that currently rewrite tag identity are refactored to return
  or construct the correct identity value directly.
* No new public builder type is introduced. Private helpers are acceptable if
  they reduce duplication and keep the one-shot construction seam obvious.
* The resulting code is more const-correct and easier to reason about than the
  current "default construct then patch fields" style.

### Constraints

* Preserve all query and storage behavior.
* Do not mix this task with unrelated SQL cleanup or API redesign.
* If one-shot construction cannot be achieved without changing the public
  `tagdb` contract, stop and report before proceeding.

### TDD

Use existing sqlite tests as the contract. Add at least one test that exercises
hydration of a non-trivial tag with relations and one referent transform path,
proving the rebuilt value matches previous behavior.

### Verify

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagdb/tests
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

---

## Tests — Completion Command

All three tasks must pass before this phase is complete:

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

## Acceptance Criteria

* `abstract_tag` identity is immutable after construction.
* No public identity mutator remains on `abstract_tag`.
* Parser and sqlite paths construct identity in one shot instead of mutating an
  existing tag value.
* No new public builder vocabulary type is introduced.
* Existing behavior is preserved; full build and relevant tests pass clean.
* The resulting seams make a future const read-only hard tagspace more direct,
  not less.

## Deliverable: Concise Report

For each task:
1. Summary of changes.
2. Test results: exact command and output.
3. Open issues or non-trivial findings requiring follow-on work.
4. Suggested git commit message.
