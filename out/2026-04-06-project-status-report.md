# Project Status Report
## Scanner, Parser, and tagdurl Tasks — 2026-04-06

---

## Critical Blocker

**`parser.y` does not compile.** `get_statement ::= CMD_GET TAGDURL(U)` appears
twice — at lines 269 and 273 — with different action bodies. Lemon emits
`This rule can not be reduced` and exits with error. No tests can run until this
is resolved. Every acceptance criterion that requires passing tests is blocked.

**Root cause**: A merge artifact. The helper-function form
(`scan_tagdurl(tagl, U.str())`) and the inline inner-driver form coexist.
One must be removed; the inline inner-driver form is the architecturally correct
choice per the codex-assessment (avoids re-entrant parser calls).

---

## Task-by-Task Assessment

### `2026-03-19-11-36-scanner-refactor-task.md` — Scanner Modularization

| Criterion | Status |
|---|---|
| `tagdurl.re.cc` created | COMPLETE |
| `scanner.h` defines `TAGL::scanner` and `TAGL::scanner::tagdurl` | COMPLETE |
| `scanner.cc` implements scanner runtime | COMPLETE |
| `scanner.out.cc` targeted by Makefile (generated at build time) | COMPLETE |
| Named re2c patterns centralized in `scanner.h` | COMPLETE |
| `token_store` backing for scanner | COMPLETE |
| Multiple scanner modes via OOP (not `scanner_mode` enum) | COMPLETE |
| Streaming/refill behavior preserved | COMPLETE |
| Tests pass (`make -C tagl tests`) | **BLOCKED** — parser does not compile |

### `2026-03-20-08-33-scanner-refactor-continue.md` — Remove `scanner_mode`

| Criterion | Status |
|---|---|
| `scanner_mode` enum removed from `tagl.h` and `scanner.cc` | COMPLETE |
| `TAGL::scanner` and `TAGL::scanner::tagdurl` OOP hierarchy in place | COMPLETE |
| Tests pass | **BLOCKED** — parser does not compile |

### `2026-03-20-14-12-tagdurl-scanner.md` — tagdurl Scanner Unit Tests

| Criterion | Status |
|---|---|
| `tagd/tagl/tests/TagdUrlTester.h` created | COMPLETE (27 test methods) |
| `tagdurl.re.cc` implements scanner | COMPLETE |
| `httagd` reduced to HTTP routing and scanner delegation | COMPLETE |
| Duplicate parsing logic removed from `httagd` | COMPLETE |
| `TagdUrlTester` covers all required categories | COMPLETE (see below) |
| Tests pass | **BLOCKED** — parser does not compile |

**TagdUrlTester coverage present**: root get, HTTP GET/DEL, HDURI, children query,
children with placeholder, parent relations, modifier, search terms, sub-search,
search without trailing slash, root search, context option, UTF-8 subject,
Japanese context, simple-english context, PUT empty/slash/trailing/illegal-search,
PUT constrain tag id, DEL illegal search.

**Coverage absent per spec**: `PUT`, `DELETE` method categories have limited
end-to-end coverage; wildcard query (`GET /*/rel`) has no dedicated test.

### `2026-03-28-symbolic-sub-rel.md` — Symbolic Aliases `-^` and `->`

| Criterion | Status |
|---|---|
| Scanner emits dedicated tokens for `-^` and `->` | PRESENT in `scanner.re.cc` |
| Parser maps to `_sub` / `_rel` semantics in operator positions only | `Tester.h` has tests for `-^`; implementation present |
| `_sub` and `_rel` canonical hard tags still valid | Preserved |
| `-^` and `->` rejected as operands | Tested in `Tester.h` |
| Tests pass | **BLOCKED** — parser does not compile |

### `2026-03-29-tagdurl-scanner-redo.md` — Planning / Critique Task

This was a documentation and planning task, not implementation. It produced
`out/2026-03-29-tagdurl-scanner-redo.md` and `out/2029-03-29-tagdurl-scanner-redo-claude.md`.
The deliverables were analysis and a refactor plan. Those exist.

| Criterion | Status |
|---|---|
| Critique of prior artifacts produced | COMPLETE |
| Refactor plan with scanner test categories stated | COMPLETE |
| Suggested task rewrite with restraints not imperatives | COMPLETE |

### `2026-04-04-parser-bugs.md` — Parser Crash and Japanese Context Failure

| Criterion | Status |
|---|---|
| Bug 1: `munmap_chunk` crash after `test_query_tag` fixed | **UNKNOWN** — tests blocked |
| Bug 2: `test_get_context_option_japanese` passes | **UNKNOWN** — tests blocked |
| `test_get_context_option` calls `finish()` and asserts tag id | Not verified |
| `test_get_context_option_simple_english` consistent with Japanese variant | Not verified |
| `Tester` and `TagdUrlTester` both pass | **BLOCKED** |

The original bugs may or may not still exist. The duplicate-rule blocker must be
resolved before these can be confirmed.

### `2026-04-04-parser-refactor.md` — Parser Type Cleanup

| Criterion | Status |
|---|---|
| `%token_type {TAGL::TokenText}` replaces `{std::string *}` | COMPLETE |
| `%default_destructor { /* NOOP */ }` replaces `{ DELETE($$) }` | COMPLETE |
| `TokenText` struct introduced | COMPLETE |
| `NoValue` struct introduced | COMPLETE |
| Explicit `%type` for text-carrying nonterminals | PARTIAL — several declared; full audit incomplete |
| Helper/control-flow nonterminals use non-owning semantics | PARTIAL |
| `DELETE` / `MDELETE` removed | INCOMPLETE — `MDELETE(U)` still present at line 287 |
| Parser compiles cleanly | **FAILED** — duplicate rule blocks compilation |
| Tests pass | **BLOCKED** |

### `2026-04-04-tagdurl-refactor.md` — tagdurl Ownership Move to `tagl`

| Criterion | Status |
|---|---|
| `httagd.cc` delegates to `TAGL::driver::scan_tagdurl` | COMPLETE |
| No new manual parsing in `httagd` | COMPLETE |
| `TagdUrlTester` covers supported tagdurl contract | COMPLETE (27 tests) |
| `tagdurl.re.cc` owns structural URL parsing | COMPLETE |
| Query opts `q` and `c` handled in TAGL mapping | COMPLETE (`QUERY_OPT_SEARCH`, `QUERY_OPT_CONTEXT` in `scanner.h`) |
| Tests pass | **BLOCKED** |

### `2026-04-05-token-backing-store.md` — Token Backing Store

| Criterion | Status |
|---|---|
| `token_store` class introduced in `scanner.h` | COMPLETE |
| `TokenText { z, n }` lightweight token type | COMPLETE |
| Scanner holds `_token_store` instance | COMPLETE |
| `store_text` / `store_token_text` methods wired into scanner lifecycle | COMPLETE |
| Parse-lifetime reset on `init()` | NOT VERIFIED |
| Iteration 1: token-across-refill boundary test | NOT VERIFIED |
| Iteration 2: backing store abstraction wired without changing token types | PARTIAL |
| Iteration 3: narrow token path through backing store | PARTIAL |
| Iteration 4: lifetime-focused tests | NOT VERIFIED |
| Iteration 5: migrate one parser alias cluster to lightweight token types | INCOMPLETE |
| Iteration 6: explicit Lemon types and narrower destructors | INCOMPLETE |
| Tests pass | **BLOCKED** |

---

## Notable Observations

### 1. Single fix unblocks the entire suite

The duplicate `get_statement ::= CMD_GET TAGDURL(U)` rule at lines 269 and 273
in `parser.y` is the only reason the parser fails to build. Removing the
redundant helper-function form (lines 269–272) leaves the architecturally
correct inner-driver form. This one edit restores compilation and unblocks all
tests across every task above.

### 2. `MDELETE(U)` survives the refactor

Line 287 of `parser.y` still calls `MDELETE(U)` on a `TAGDURL` token inside the
inner-driver action block. With `%token_type {TAGL::TokenText}` and a NOOP
default destructor, this is either a no-op macro or a latent error. It should be
audited: if `MDELETE` is now a no-op, the call is dead code; if it still frees
memory it does not own, it is a bug.

### 3. `test_get_context_option` contract gap

Per `out/2026-04-04-codex-assessment.md`, `test_get_context_option` does not call
`finish()` and does not assert the tag id. This makes it pass vacuously and is an
under-specified test that masks the same failure mode as the Japanese variant.
This fix is part of the accepted scope for `2026-04-04-parser-bugs.md` and has
not been confirmed complete.

### 4. Token backing store TDD iterations are partially executed

The `token_store` infrastructure exists, but the six-iteration TDD path in
`2026-04-05-token-backing-store.md` is only partially walked. Iterations 1–3
(token boundary test, backing store wired, one narrow path routed) are partially
implemented. Iterations 4–6 (lifetime tests, alias cluster migration, explicit
Lemon types) are not yet done. The parser refactor and token backing store tasks
are coupled and should proceed together once the build is restored.

### 5. Parser type cleanup is partial

The refactor correctly changed the default token type to `TokenText` and cleared
the default destructor. However, the `%type` declarations are incomplete — many
nonterminals flagged as "helper / no-value symbols" in
`out/2026-04-04-parser-type-guidance.md` have not yet received explicit non-owning
type declarations. The grammar compiles (once the duplicate rule is removed), but
the ownership model is still partially implicit.

### 6. Architecture goal for `httagd` is substantially met

`httagl::tagdurl_get`, `tagdurl_put`, and `tagdurl_del` now all delegate to
`scan_request_tagdurl`, which calls `TAGL::driver::scan_tagdurl`. The ad hoc
manual path parsing (`htscanner::scan_tagdurl_path`) has been removed and
replaced by the re2c scanner pipeline. This was the primary structural goal of
the tagdurl refactor tasks.

---

## Summary

| Area | State |
|---|---|
| Scanner modularization | COMPLETE (subject to tests) |
| `scanner_mode` removal | COMPLETE |
| OOP scanner hierarchy | COMPLETE |
| `TagdUrlTester` suite | COMPLETE |
| `httagd` delegation | COMPLETE |
| Symbolic aliases `-^` / `->` | COMPLETE (subject to tests) |
| Token backing store infrastructure | PARTIAL |
| Parser type refactor | PARTIAL |
| Parser bug fixes | UNKNOWN — blocked |
| **Build** | **BROKEN** — duplicate rule in `parser.y` lines 269 and 273 |
| **Tests** | **ALL BLOCKED** — no tests can run until build is fixed |

**Recommended first action**: remove the duplicate `get_statement ::= CMD_GET TAGDURL(U)` rule
(the shorter helper-function form at lines 269–272) from `parser.y`, confirm the
parser compiles, and run `make -C tagd/tagl tests` to reveal the true test state.
