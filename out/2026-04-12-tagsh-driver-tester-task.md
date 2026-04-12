# Task

Move TAGL CRUD and command behavior tests from `tagsh/tests/tester.exp` into a new in-process
cxxtest suite `tagsh/tests/DriverTester.h`. `tagsh` gains a redirectable output stream used by
the command callbacks in place of the hardcoded `TAGD_COUT`. After the migration, `tester.exp`
covers only shell/process behavior: startup banner, `.load`, URL tests, and `.exit`.

## Principles

* Test ownership: CRUD and command output contracts belong to tagsh in-process tests, not to a
  spawned shell. The owning seam is the tagsh callback pipeline.
* The output stream seam is the minimal src change required to expose the contract in-process.
  Interactive behavior (`std::cout` for prompts, `TAGD_CERR` for errors) is unchanged.
* Error conditions are verified through `shell.last_code()`; output capture is for success-path
  contracts only.

## Scope

### Read

* `tagsh/tests/tester.exp`
* `tagsh/tests/LogTester.h`
* `tagsh/tests/Makefile`
* `tagsh/include/tagsh.h`
* `tagsh/src/tagsh.cc`
* `tagd/tagd/include/tagd/config.h` (TAGD_COUT, TAGD_CERR)
* `tagd/tagd/include/tagd/*.h` (print_tags, print_tag_ids signatures)
* `out/2026-04-12-tagsh-driver-tester-plan.md`

### Write

* `tagsh/include/tagsh.h`
* `tagsh/src/tagsh.cc`
* `tagsh/tests/DriverTester.h`
* `tagsh/tests/Makefile`
* `tagsh/tests/tester.exp`

### Non-goals

* changing error output routing (TAGD_CERR, print_errors)
* modifying `tagd::print_tags` or `tagd::print_tag_ids` signatures
* migrating URL or search tests from `tester.exp`
* changes to `tagl/tests/` or `tagd/tests/`

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
* `echo_result_code` is `true` by default in tagsh; tests that inspect the output stream must
  account for the result-code echo lines or disable it explicitly

## Language & Style

* follow `STYLE.md`
* preserve the author's comments and design intent unless the task explicitly changes them

## Tests

* `DriverTester.h` covers: get-not-found, get-after-bootstrap output, put-duplicate, del-not-found,
  del-existing, referent lifecycle, query-children, query-empty, context-referent
* if `print_tags`/`print_tag_ids` do not accept a stream argument, query output tests are limited
  to `last_code()` checks; note the limitation in the report
* state the exact commands required for task completion
* task is not complete until all three layers pass:

```
make -C tagd/tagd tests
make -C tagd/tagl tests
make -C tagd/tagsh tests
```

## Acceptance Criteria

* `tester.exp` reads as shell behavior: banner, `.load`, URL/search coverage, `.exit`
* `DriverTester.h` covers all removed tester.exp contracts
* the output stream seam is the only change to `tagsh/src/`
* all three test layers pass
* the change reduces drift between code, tests, and documentation

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns, or interesting observations
4. suggested concise git commit message
