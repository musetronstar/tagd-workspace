# Next Step: tagsh TAGL CRUD Behavior Tests In-Process

**Task file**: `TASKS.d/2026-04-12-tagsh-test-layer-refactor.md`  
**Batch**: `tagsh/tests/DriverTester.h` — 20 TAGL command behavior tests moved from `tester.exp` to in-process cxxtest.

---

## Current State

- `tagsh/tests/LogTester.h`: 7 in-process logger and argv tests
- `tagsh/tests/tester.exp`: 33 tests, the majority of which are TAGL CRUD behavior verified through a spawned shell
- `log-tester.exp` was retired; its contracts live in `LogTester.h`
- Recent migrations moved logger, parser, and callback tests to `tagd/tests/` and `tagl/tests/`

What remains in `tester.exp` is dominated by TAGL command output contracts. None of them require a spawned process.

---

## Baseline

All three test layers pass before any changes:

```
make -C tagd/tagd tests
make -C tagd/tagl tests
make -C tagd/tagsh tests
```

---

## What Changes

### tagsh gains an output stream seam

`tagsh` has a redirectable output stream used by the command callbacks (`cmd_get`, `cmd_put`,
`cmd_del`, `cmd_query`) in place of the current hardcoded `TAGD_COUT`. When no stream is
set, `std::cout` is the default — existing behavior is unchanged. The prompt output in
`tagsh::interpret(std::istream&)` stays on `TAGD_COUT`; tests have no need to capture it.

Error output (`tagsh::error()`, `handle_cmd_error()`) remains on `TAGD_CERR`. Tests verify
error conditions through `shell.last_code()`.

One open question: `tagd::print_tags()` and `tagd::print_tag_ids()`, called from `cmd_query`,
write directly to `std::cout`. If those functions accept a stream argument, query output is fully
redirectable. If not, query result tests are limited to `last_code()` checks and full output
redirect is deferred.

### `tagsh/tests/DriverTester.h` is a new in-process test suite

Each test holds its own `:memory:` db and `tagsh` instance. Tests that need the bootstrap schema
load `../bootstrap.tagl` (same relative path already used by `LogTester.h`).

`echo_result_code` is `true` by default in tagsh — unlike in `cmd_args::interpret()`, which
clears it before processing. Tests that inspect the output stream should account for the
`"-- TAGD_OK"` / `"-- TS_NOT_FOUND"` lines that put/del/query emit, or disable
`echo_result_code` explicitly.

The 9 test methods and what each asserts:

| Test | Setup | Asserts |
|---|---|---|
| `test_cmd_get_not_found` | empty db | `last_code == TS_NOT_FOUND` |
| `test_cmd_get_returns_tag` | bootstrap | `last_code == TAGD_OK`; output contains `"dog kind_of mammal"` |
| `test_cmd_put_duplicate` | bootstrap | `last_code == TS_DUPLICATE` |
| `test_cmd_del_not_found` | bootstrap | `last_code == TS_NOT_FOUND` |
| `test_cmd_del_existing` | bootstrap | `last_code == TAGD_OK` |
| `test_referent_lifecycle` | bootstrap | not-found → put referent → get resolves (output contains `"refers_to dog"`) → bare delete is `TS_MISUSE` → full-predicate delete is `TAGD_OK` → not-found again |
| `test_cmd_query_children` | bootstrap | `last_code == TAGD_OK` after `?? what type_of mammal` |
| `test_cmd_query_empty` | bootstrap | `last_code == TS_NOT_FOUND` after `?? what type_of dog` |
| `test_context_referent` | bootstrap | put Japanese referent → ambiguous without context (`TS_AMBIGUOUS`) → set context (`TAGD_OK`) → get resolves (`last_code == TAGD_OK`, output contains `"refers_to dog"`) → reset context (`TAGD_OK`) |

Suggested test structure (pseudocode):

```
each test:
    tdb = sqlite(":memory:")
    shell = tagsh(tdb)
    out = stringstream
    shell.set_output(out)
    [optionally] shell.interpret_fname("../bootstrap.tagl")
    shell.interpret("<tagl statement>;")
    assert shell.last_code() == <expected>
    [optionally] assert out contains <expected substring>
```

### `tagsh/tests/Makefile` builds `driver-tester`

`driver-tester` is generated from `DriverTester.h` using `cxxtestgen`, linked against the same
libraries as `log-tester`, and runs as part of `make tests` before `tester.exp`. The stale
untracked `driver-tester.cpp` (referencing a no-longer-present `DriverTester.h`) is overwritten
by the new generation.

### 20 tests are removed from `tester.exp`

| Removed test | Covered by |
|---|---|
| `get_dog_not_exists` | `test_cmd_get_not_found` |
| `get_dog` | `test_cmd_get_returns_tag` |
| `put_duplicate` | `test_cmd_put_duplicate` |
| `get_doggy_not_exists` | `test_referent_lifecycle` |
| `refer_doggy` | `test_referent_lifecycle` |
| `get_doggy` | `test_referent_lifecycle` |
| `delete_refers_tag_err` | `test_referent_lifecycle` |
| `delete_refer_doggy` | `test_referent_lifecycle` |
| `get_doggy_deleted_not_exists` | `test_referent_lifecycle` |
| `delete_missing_badger` | `test_cmd_del_not_found` |
| `delete_bat` | `test_cmd_del_existing` |
| `query_mammal_children` | `test_cmd_query_children` |
| `query_mammal_children_empty` | `test_cmd_query_empty` |
| `query_parent_relator` | `test_cmd_query_children` (extended) |
| `refer_japanese_dog` | `test_context_referent` |
| `get_japanese_dog_ambiguous` | `test_context_referent` |
| `get_japanese_dog_ambiguious` | `test_context_referent` (typo in original name) |
| `set_context_simple_english_japanese` | `test_context_referent` |
| `get_japanese_dog` | `test_context_referent` |
| `set_context_simple_english2` | `test_context_referent` |

**Remaining in `tester.exp`** after trimming:

- Startup banner + first prompt
- `bootstrap`, `bootstrap_quiet`, `bootstrap_reload_duplicate` — `.load` is a shell command, not TAGL
- URL tests (`put_url_dog`, `get_url_dog`, `put_url_dog2`, `put_url_cat`) — deferred
- Search and URL-query tests — deferred
- `.exit` + `wait`

---

## Verification

```
make -C tagd/tagd tests
make -C tagd/tagl tests
make -C tagd/tagsh tests
```

All three pass. `tester.exp` exits 0. `driver-tester` exits 0.

---

## Acceptance

- `tester.exp` reads as shell behavior: banner, `.load`, URL/search coverage, `.exit`
- CRUD and referent command contracts live in `tagsh/tests/DriverTester.h`
- The output stream seam is the only `tagsh/src/` change
- Diff is reviewable in one sitting

---

## Suggested Commit Message

```
codex: tagsh: add DriverTester.h for TAGL CRUD behavior in-process
```
