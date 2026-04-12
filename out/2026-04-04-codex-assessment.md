# Codex Work Assessment & Intervention Plan
## tagdurl refactor + parser bugs — 2026-04-04

---

## 1. Summary of Codex's Work

Codex successfully scaffolded the tagdurl scanner pipeline:

- `tagdurl.re.cc`: well-structured re2c state machine covering the major URL patterns (subject, query relations, modifiers, `?q=`, `?c=`).
- `scanner.h`: clean `QUERY_OPT_*` constants and `scanner::tagdurl` subclass declaration.
- `parser.y`: `scan_tagdurl()` helper using an inner `TAGL::driver` to avoid re-entrant parser calls — architecturally sound.
- `TagdUrlTester.h`: reasonable test coverage for get, HTTP method mapping, query children, search terms, context option, and UTF-8 subjects.

The work moves in the right direction. But two bugs block completion, and one test is structurally unsound.

---

## 2. Current Test State

```
make -C tagd/tagl tests

[Tester]         78 tests pass ... munmap_chunk(): invalid pointer  ← CRASH
[TagdUrlTester]  12/13 pass
                 FAIL: test_get_context_option_japanese
```

---

## 3. Bug 1 — Parser Stack Corruption (crash)

**What**: `munmap_chunk(): invalid pointer` after all 78 Tester tests run.
This is deferred heap corruption — the fault and the crash are separated in time.

**Where**: `TAGL::driver::free_parser()` via `ParseFree`.

**Root cause**: Grammar actions for non-terminals like `interrogator` never set their result value `$$`. Because `%default_destructor { DELETE($$) }` applies to every symbol of the default type (`std::string *`), Lemon calls `DELETE(garbage_ptr)` when `ParseFree` walks the stack after a syntax error teardown.

Confirmed in `parser.cc` (generated):
- Symbol 65 (`interrogator`) has a destructor that calls `DELETE(yypminor->yy0)`.
- Neither `interrogator ::= .` nor `interrogator ::= INTERROGATOR(I)` sets `$$`.

The `%syntax_error` block calls `do_callback()` but does **not** clean the stack — the commented-out manual cleanup code was intentionally left out. The stack items remain, and the uninitialized pointers are eventually freed by `ParseFree`.

**Acceptance goal**: `Tester` runs 78 tests and exits cleanly with no signal/abort. The fix must be localized: correct destructor behaviour for affected non-terminals without changing grammar semantics. Do not add manual stack-walking in `%syntax_error`.

**Key test**: `test_query_tag` (search string without quotes) is the minimal reproducer — it triggers the error path. Add a regression test that runs *after* `test_query_tag` and confirms the driver is still usable.

---

## 4. Bug 2 — `test_get_context_option_japanese` Fails

**What**:
```
Expected (tagl.tag().id() == "イヌ"), found ("" != イヌ)
Expected (tagl.session_ptr()->context().size() == 1), found (0 != 1)
```

Both the tag and the context are missing after `scan_tagdurl + finish()`.

**Root cause to confirm**: `session::push_context(id)` requires the tag to exist. If it fails, `_context_level` stays 0 and the session is left without a valid context. More critically: `free_parser()` skips the `Parse(TOK_TERMINATOR)` call when `has_errors()` is true — so if the push_context failure propagates an error state onto the driver, the grammar never reduces, `_tag` is never set, and `tagl.tag()` returns `empty_tag`.

**Key distinction vs. the passing test** (`test_get_context_option`):
- That test does **not** call `finish()`, so it never exercises the TERMINATOR-triggered reduction path.
- It passes vacuously — the context is pushed during scan, but the tag is never confirmed. It is an under-specified test.

**Acceptance goals**:

1. `test_get_context_option_japanese` passes with correct tag id and context size.
2. `test_get_context_option` and `test_get_context_option_simple_english` also call `finish()` and assert the tag id (make them consistent with the japanese variant).
3. If `push_context` can legitimately fail during a tagdurl scan, the failure must not corrupt the driver's parse-ability for the current statement. The context opt is advisory — a bad context id should not prevent the GET from succeeding.

---

## 5. Structural Concern — `test_get_context_option` Is Under-Specified

All three context-option tests should follow the same pattern:
```
scan_tagdurl(...)
finish()
assert tag id
assert context
clear_context_levels()
```

The current `test_get_context_option` skips `finish()` and does not assert the tag id. Fix it to match the others. This is a test-contract issue, not a behaviour change.

---

## 6. Intervention Plan

Priority order:

### Step 1 — Fix Bug 1 (parser crash)

Goal: `Tester` exits cleanly after 78 tests.

- Reproduce: run `test_query_tag` in isolation and confirm the crash path.
- Fix the `$$` uninitialized value issue for the affected non-terminal(s) in `parser.y`. The `%destructor` / `%default_destructor` contract must be consistent: any non-terminal that carries a `std::string *` and is reachable during error teardown must either set `$$` to a valid (deletable or null) value, or have an explicit no-op destructor.
- Do not change grammar semantics. Do not add manual stack cleanup in `%syntax_error`.
- Pass `make -C tagd/tagl tests` with no signal and no CxxTest failures.

### Step 2 — Fix Bug 2 (japanese context test)

Goal: `TagdUrlTester` passes all 13 tests.

- Trace the error-state propagation from `push_context` through `free_parser` for the UTF-8 + context path.
- Ensure a failed or absent context push does not prevent the statement from reducing and setting `_tag`.
- Fix `test_get_context_option` and `test_get_context_option_simple_english` to call `finish()` and assert the tag id — bring them in line with the japanese test's expectations.
- Pass `make -C tagd/tagl tests` with all 13 TagdUrlTester tests green.

### Step 3 — Final verification

Run the full suite:
```
make -C tagd/tagl tests
```
Both `tester` and `tagdurl_tester` must exit 0 with no signals. Report any remaining parser-teardown risks.

---

## 7. What NOT to Do

- Do not weaken test assertions to make them pass.
- Do not paper over the crash with `_parser = nullptr` resets or try/catch.
- Do not change `scan_tagdurl`'s inner-driver pattern without understanding the re-entrancy reason for it.
- Do not add new dependencies.
- Keep diffs small and reviewable — one bug at a time.

---

## 8. Open Questions for the Executing Agent

1. Which non-terminals beyond `interrogator` share the uninitialized-`$$` problem? A systematic audit of all non-terminals using the default `std::string *` type without explicit `%destructor` is warranted before fixing only `interrogator`.
2. Does `session::push_context` set an error on the `tagdb::session` object, and if so, does that error propagate to the driver? Tracing the exact error path for an unknown context id is required before fixing Bug 2.
