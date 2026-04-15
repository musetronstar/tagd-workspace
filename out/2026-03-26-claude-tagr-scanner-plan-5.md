# Task 5 — re2c Scanner Architecture: Feasibility Report Plan

**Date:** 2026-03-26
**Task file:** `TASKS.d/2026-03-21-tagr-tokenizing.md § Task 5`
**Scope:** `tagr/tagr-c++/src/`

---

## 1. Goal

Replace the hand-rolled whitespace splitter in `tagr_tokenizer::scan()` with a
re2c-generated scanner in a new `tagr-scanner.re.cc`, modeled on
`tagd/tagl/src/scanner.re.cc`, using a per-token callback to populate a tag
with matched tokens.

---

## 2. Current Architecture

```
tagr::scan_fd(fd)
  └─ evbuffer_read(fd)          // tagr.cc:312-313
  └─ tagr_tokenizer::scan(data, len)  // tagr.cc:244-268
       └─ [manual byte loop — split on std::isspace]
       └─ emit(tok, offset)     // tagr.cc:234-242
            ├─ _driver->lookup_pos(tok)  → int token_type
            ├─ TAGL::token_str(token_type) → const char* name
            ├─ _trie->add(tok, offset)
            └─ *_out << tok << '\t' << name << '\n'
```

### Limitations of the current scanner

| Limitation | Location |
|---|---|
| Whitespace-only token boundaries; no finer NL structure (punctuation, numbers, URLs) | `tagr.cc:255` |
| Single-byte loop — no longest-match, no rule priority | `tagr.cc:251-268` |
| Prefix ambiguity in `trie::print_trie()`: early return silences longer tokens sharing a prefix | `tagr.cc:168` (TODO at `tagr.cc:93-98`) |
| Output is alphabetical (trie order), not input-stream order | `trie::print_trie()` TODO at `tagr.cc:155-156` |

---

## 3. Existing re2c Infrastructure

re2c is **already a build-time dependency** of `tagd/tagl`:

```makefile
# tagd/tagl/src/Makefile
scanner.out.cc: scanner.re.cc
    re2c $(RE2CFLAGS) -o scanner.out.cc scanner.re.cc

scanner.o: scanner.out.cc lemonfiles
    g++ $(CXXFLAGS) -c -o $@ scanner.out.cc $(INC)
```

The generated `scanner.out.cc` is the compiled artifact; `scanner.re.cc` is the
source of truth. The same pattern applies to `tagr-scanner.re.cc →
tagr-scanner.out.cc`.

**No new runtime dependency is introduced.** re2c is only needed at build time.

---

## 4. Reference: TAGL Scanner Design

### 4.1 `TAGL::scanner` class (`tagd/tagl/include/tagl.h:47-90`)

```cpp
class scanner {
    driver *_driver;
    const char *_beg, *_cur, *_mark, *_lim, *_eof;  // re2c state
    int32_t    _state;       // YYGETSTATE / YYSETSTATE (stateful scanning)
    char       _buf[BUF_SZ]; // 16 KiB fixed ring buffer
    std::string _val;        // overflow when token spans buffer boundary
    evbuffer  *_evbuf;       // libevent streaming buffer
    bool       _do_fill;     // enable YYFILL streaming

    const char* fill();      // YYFILL implementation
    void scan(const char*, size_t);  // re2c entry point
};
```

### 4.2 TAGL scan → parse_tok → callback flow

```
driver::execute(evbuffer*)
  └─ scanner::evbuf(ev)         // arm streaming fill
  └─ scanner::scan(buf, sz)     // re2c loop
       └─ on each match:
            driver->parse_tok(token_type, value*)   // push to lemon parser
  └─ driver::finish()
       └─ driver::do_callback()
            └─ callback::cmd_get / cmd_put / cmd_del / cmd_query
```

The lemon parser accumulates tokens into a `tagd::abstract_tag` statement; the
callback fires once per complete statement.

### 4.3 Key re2c macros used by TAGL

```c
#define YYCURSOR   _cur
#define YYLIMIT    _lim
#define YYMARKER   _mark
#define YYGETSTATE()  _state
#define YYSETSTATE(x) { _state = (x); }
#define YYFILL(n)  { if(_do_fill && _evbuf && !_eof){ this->fill(); ... } }
```

`fill()` calls `evbuffer_remove()` to pull the next chunk from the libevent
buffer into `_buf`, maintaining the sliding-window invariant required by re2c.
tagr's `scan_fd()` already uses the same `evbuffer` API (`evbuffer_read`,
`evbuffer_pullup`); the fill mechanism can be reused directly.

---

## 5. Proposed Architecture

### 5.1 New files

| File | Role |
|---|---|
| `tagr/tagr-c++/src/tagr-scanner.re.cc` | re2c source — NL token rules + emit callback |
| `tagr/tagr-c++/src/tagr-scanner.out.cc` | re2c generated — committed like `tagl/scanner.out.cc` |

### 5.2 `tagr_scanner` class sketch

```cpp
// tagr-scanner.re.cc

// Per-token callback: token_type (TAGL int), matched bytes, byte offset
typedef std::function<void(int, const std::string&, size_t)> tagr_emit_fn;

class tagr_scanner {
    TAGL::driver  *_driver;     // for lookup_pos()
    tagr_emit_fn   _emit;       // per-token callback

    // re2c state — mirrors TAGL::scanner
    const char *_beg, *_cur, *_mark, *_lim, *_eof;
    int32_t     _state = -1;
    char        _buf[TAGL::BUF_SZ];
    std::string _val;           // buffer overflow
    evbuffer   *_evbuf = nullptr;
    bool        _do_fill = false;
    size_t      _byte_offset = 0;  // running input offset

    const char* fill();  // same contract as TAGL::scanner::fill()

public:
    tagr_scanner(TAGL::driver *drv, tagr_emit_fn emit)
        : _driver{drv}, _emit{std::move(emit)} {}

    void scan(evbuffer *ev);     // streaming entry: arms fill, calls scan()
    void scan(const char*, size_t);  // re2c entry point (generated body)
};
```

### 5.3 NL token rules (re2c sketch)

```re2c
/*!re2c
    re2c:define:YYCTYPE  = "char";
    re2c:yyfill:enable   = 1;

    NL        = "\r"? "\n" ;
    WORD      = [a-zA-Z]+ ("'" [a-zA-Z]+)? ;  // contractions: don't, it's
    NUMBER    = [0-9]+ ("." [0-9]+)? ;
    URL       = [a-zA-Z]+ "://" [^ \t\r\n]+ ;
    PUNCT     = [.,!?;:()\-] ;
    WS        = [ \t]+ ;

    WORD      { _emit(_driver->lookup_pos(matched), matched, offset); goto next; }
    NUMBER    { _emit(TOK_QUANTIFIER,               matched, offset); goto next; }
    URL       { _emit(TOK_URL,                      matched, offset); goto next; }
    PUNCT     { _emit(TOK_UNKNOWN,                  matched, offset); goto next; }
    WS        { goto next; }     // skip whitespace
    NL        { goto next; }     // skip newlines (or emit if significant)
    [\000]    { return; }        // EOF
    [^]       { goto next; }     // ANY — unknown byte, skip
*/
```

Token type resolution for `WORD` tokens uses `_driver->lookup_pos()` exactly
as `tagr_tokenizer::emit()` does today — the lookup logic is unchanged.

### 5.4 Integration: replacing `tagr_tokenizer::scan()`

```cpp
// tagr.cc — new scan() adapter (replaces the byte loop)
void tagr_tokenizer::scan(const unsigned char *data, size_t len) {
    if (!_trie)
        _trie = std::make_unique<trie>();

    tagr_scanner scanner(_driver, [this](int tok, const std::string& val, size_t off) {
        this->emit(val, off);  // emit() unchanged: trie.add + TSV output
    });

    // wrap raw bytes in a temporary evbuffer (no copy — evbuffer_add is a ref)
    evbuffer *ev = evbuffer_new();
    evbuffer_add(ev, data, len);
    scanner.scan(ev);
    evbuffer_free(ev);
}
```

`tagr::scan_fd()` could bypass the intermediate buffer and pass the libevent
buffer directly to `tagr_scanner::scan(evbuffer*)`, eliminating the
`evbuffer_pullup` call. That is a follow-on optimization, not required for the
first iteration.

### 5.5 Build system changes

Add to `tagr/tagr-c++/src/Makefile`:

```makefile
RE2CFLAGS =

tagr-scanner.out.cc: tagr-scanner.re.cc
    re2c $(RE2CFLAGS) -o tagr-scanner.out.cc tagr-scanner.re.cc

## Process Addendum

* The next implementation iteration should start with the narrowest executable seam: one tokenizer test that proves the first re2c-driven token path without requiring the full NLP token set up front.
* Feasibility reports should explicitly separate what is already true in the codebase from what is only proposed.
* Build integration should be treated as part of the design contract, not an afterthought: generated-file rules, workspace-relative paths, and test entry points should be named in the plan before coding starts.
* When current behavior is known to be imperfect, the plan should state whether the next step preserves that behavior temporarily or intentionally changes it under test.

tagr: tagr-scanner.out.cc
    g++ -O3 -std=c++23 -W -o $(TAGR_BIN) main.cc tagr.cc tagr-scanner.out.cc $(INC) $(LFLAGS)
```

---

## 6. "Populate a Tag" — Callback Interpretation

Task 5 says: *"populate a tag with matched tokens according to type and use the
TAGL callback"*.

TAGL's `callback` interface operates on complete `tagd::abstract_tag`
statements (`cmd_get`, `cmd_put`, etc.). For tagr, the analogous unit is a
**sentence or clause** — a sequence of NL tokens assembled into a
`tagd::abstract_tag` shaped as a TAGL statement.

Two possible interpretations:

| Interpretation | Description | Complexity |
|---|---|---|
| **A — per-token emit** | `tagr_emit_fn` fires once per matched token; trie and TSV output continue as-is | Low — this iteration |
| **B — statement callback** | Re2c scanner accumulates tokens into a `tagd::abstract_tag`; fires a TAGL-style callback per complete NL sentence | High — future iteration |

**Recommendation:** Implement interpretation A first (per-token emit), which
preserves existing behavior and unblocks re2c adoption. Interpretation B can be
layered on top once the scanner is in place — it is the path toward outputting
`<subject> <relator> <object>` shaped TAGL statements from raw NL input (see
`tagr/tagr-c++/AGENTS.md:43-46`).

---

## 7. Open Issues to Resolve First

These are pre-existing issues (from the Task 1–4 review) that interact with
this change:

| Issue | Location | Impact on Task 5 |
|---|---|---|
| `trie::print_trie()` alphabetical output; TODO says "match normalized input stream bytes" | `tagr.cc:155-156` | re2c scanner emits in input order — aligns with the intent; trie print_trie still needs fixing separately |
| Prefix-ambiguity: early return skips tokens that are prefixes of other tokens | `tagr.cc:168`, TODO `tagr.cc:93-98` | re2c longest-match resolves this at the scanner level; the trie's traversal bug remains separate |
| `simple-text.txt` is a word list, not declarative sentences | `tests/simple-text.txt` | Low: test fixture can be updated independently |

---

## 8. Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| `re2c` not installed on build host | Low (already used by tagl) | Check with `which re2c`; add to dev-env docs if needed |
| `tagr-scanner.out.cc` not committed → breaks builds without re2c | Medium | Commit generated file (follow tagl convention); add Make rule so it regenerates when `.re.cc` changes |
| Buffer boundary token split (token spans two YYFILL chunks) | Medium | Reuse TAGL's `_val` overflow pattern; covered by fill() implementation |
| NL token rule ambiguity (contractions, hyphenation, unicode) | Medium | Start with ASCII-safe rules; treat multi-byte sequences as `TOK_UNKNOWN` and iterate |
| Streaming vs. batch: `scan_fd` uses `evbuffer_pullup` (batch); re2c fill expects streaming | Low | `tagr_scanner::scan(evbuffer*)` can prime the fill path exactly as `driver::execute(evbuffer*)` does (`tagl.cc:177-192`) |

---

## 9. Feasibility Verdict

**Feasible.** The re2c infrastructure, build pattern, fill buffer mechanism, and
`lookup_pos()` integration are all proven in `tagd/tagl`. The structural change
to `tagr_tokenizer::scan()` is a straight substitution. The diff is bounded:
one new `.re.cc` file, one new `.out.cc` (generated), small additions to the
`Makefile`, and a narrow change to `tagr_tokenizer::scan()`.

No new runtime dependencies. No change to the trie, `emit()`, test fixtures, or
the `expect` test suite.

---

## 10. Recommended First Iteration (TDD)

1. **Test first:** Write a CXXTest case in `Tester.h` that constructs a
   `tagr_scanner` with a lambda callback, scans `"one any of\n"`, and asserts
   the three emitted `(token_type, value, offset)` tuples — same data the
   existing `test_known_tokens` asserts via `tagr_tokenizer`.

2. **Implement:** Create `tagr-scanner.re.cc` with the minimal re2c rules
   (WORD, WS, NL, EOF, ANY) and the `fill()` body copied from
   `TAGL::scanner::fill()`.

3. **Wire:** Replace the byte loop in `tagr_tokenizer::scan()` with the
   `tagr_scanner` adapter.

4. **Build and test:** `make all` in `tagr-c++/tests/` — all three test targets
   (`tagr_tests`, `expect_tests`, `test_rev_freqs`) must pass.

5. **Report:** concise summary of diff, test results, open issues.
