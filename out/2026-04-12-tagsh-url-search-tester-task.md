# Task

Extend `tagsh/tests/DriverTester.h` with in-process coverage for URL put/get and search/query
behavior, and remove those tests from `tagsh/tests/tester.exp`. After this migration, `tester.exp`
contains only genuine shell/process behavior: startup banner, `.load`, and `.exit`.

## Principles

* URL and search output contracts do not require a spawned shell; they belong in the same
  in-process layer as the CRUD contracts added in the previous batch.
* The owning seam is unchanged: tagsh command callbacks with the redirectable output stream.

## Scope

### Read

* `tagsh/tests/tester.exp`
* `tagsh/tests/DriverTester.h`
* `tagsh/tests/Makefile`
* `tagsh/src/tagsh.cc` (cmd_query, search paths)
* `tagd/tagd/include/tagd/*.h` (print_tags, print_tag_ids signatures — confirm stream support)

### Write

* `tagsh/tests/DriverTester.h`
* `tagsh/tests/tester.exp`

### Non-goals

* changes to `tagsh/include/tagsh.h` or `tagsh/src/tagsh.cc` unless a missing test seam is
  discovered
* changes to `tagsh/tests/Makefile` unless the build is broken
* changes to `tagl/tests/` or `tagd/tests/`
* `.load`, startup banner, or `.exit` coverage — those stay in `tester.exp`

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

## Language & Style

* follow `STYLE.md`
* preserve the author's comments and design intent unless the task explicitly changes them

## Tests

* `DriverTester.h` extended with tests covering:
  * URL put and get (`put_url_dog`, `get_url_dog`, `put_url_dog2`, `put_url_cat`)
  * sub-search (`tag_sub_search`, `tag_sub_symbol_search`)
  * full-text search (`search`)
  * URL queries (`query_url_dog`, `query_url_animal`, `query_url_animal_wikipedia`)
* task is not complete until all three layers pass:

```
make -C tagd/tagd tests
make -C tagd/tagl tests
make -C tagd/tagsh tests
```

## Acceptance Criteria

* `tester.exp` contains only: startup banner, `.load` tests, and `.exit`
* all removed `tester.exp` contracts have in-process equivalents in `DriverTester.h`
* all three test layers pass
* the change reduces drift between code, tests, and documentation

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns, or interesting observations
4. suggested concise git commit message
