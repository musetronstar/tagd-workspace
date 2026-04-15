# TAGL Trace Dogfood Report

Status: active reference
Date: 2026-04-08
Task: `TASKS.d/2026-04-08-tagl-trace-dogfood-logging-task.md`

## Findings

* The canonical next-word workflow currently selects `VOA:against:1` from `simple-english.tagl`.
* `tagr.py` in the repo venv translates `against not agreeing with something` to:
  ```tagl
  >> against not_agreeing_with something;
  ```
* Tracing that candidate through `tagsh --trace` produces mixed non-TAGL output:
  * raw scanner echo: `scan(...)`
  * token trace lines from `tagl.cc`
  * lemon parser trace lines prefixed `tagl_trace:`
  * final structured error output:
    ```tagl
    TS_NOT_FOUND _type_of _error
    _caused_by _file = "/tmp/against-tagr-candidate.tagl", _line_number = 1, _unknown_tag = not_agreeing_with
    ```
* `httagd` is built and runnable in this workspace. A bounded `httagd --trace` startup produced thousands of mixed trace lines before serving requests.
* `httagd --trace` currently enables `TAGDB`, `TAGL`, and `HTTAGD` tracing together, so SQL trace, scanner echo, parser trace, callback trace, structured errors, and raw stderr output share one stream.

## Role Map

* Trace activation:
  * `tagd/tagsh/src/tagsh.cc`
  * `tagd/httagd/app/main.cc`
  * `tagd/httagd/src/httagd.cc`
  * role: coarse global trace switching
* SQL trace:
  * `tagd/tagdb/sqlite/src/sqlite.cc`
  * role: database statement instrumentation
* Parser trace:
  * `tagd/tagl/src/tagl.cc`
  * `ParseTrace(stderr, "tagl_trace: ")`
  * role: lemon parser instrumentation
* Token trace:
  * `tagd/tagl/src/tagl.cc`
  * `driver::parse_tok()`
  * role: per-token trace emission
* Debug/log macros:
  * `tagd/tagd/include/tagd/config.h`
  * `LOG_ERROR`, `LOG_DEBUG`
  * role: direct unstructured stderr output
* Structured errors:
  * `tagd/tagd/src/tagd.cc`
  * `errorable::error(...)`, `errorable::print_errors(...)`
  * role: accumulate and render `tagd:error`
* Parser-visible error creation:
  * `tagd/tagl/src/parser.y`
  * syntax error handling and file/line attachment
  * role: convert parser failure into user-visible error state

## Error Quality Critique

What is good:
* The final `TS_NOT_FOUND` output is closer to dogfood than the rest because it is structured and carries file and line context.
* `_unknown_tag = not_agreeing_with` is useful and points at the immediate failing symbol.

What is weak:
* The visible output mixes four channels with no common TAGL form.
* The root cause is buried inside parser-noise and token-noise.
* `Syntax Error!` is generic and not repair-oriented.
* The trace does not distinguish clearly between:
  * SQL/database instrumentation
  * debug instrumentation
  * parser mechanics
  * semantic lookup failure
  * final user-facing error
* The output helps confirm failure, but does not help enough with repair.

Compared to good developer-facing errors, the current system is weak on:
* phase clarity
* signal-to-noise ratio
* next-step guidance
* consistent output form

## Reduced Plan

### Universal TAGL-native logger

* Treat logging as a first-class `tagd` facility, not scattered macros.
* Keep log levels compatible with established severity wisdom.
* Emit logs in TAGL form, or TAGL comments when full TAGL facts are not appropriate.
* Replace direct `std::cerr` logging macros with a shared logger boundary.
* Make module traces additive, not chaotic: scanner, parser, driver, db, and service layers should share one rendering discipline.
* Use the new event/session foundation as the identity seam for future log events; do not require every trace line to become a persistent event.

### Better TAGL-native errors

* Keep `tagd:error` as the authoritative structured error base.
* Improve scanner/parser/driver cooperation so the final visible error names:
  * phase
  * offending symbol or construct
  * location
  * likely repair direction
* Separate user-facing error rendering from deep trace detail.
* Keep low-level parser trace available, but render it as explicit trace output rather than letting it compete with final errors.

### Trace control

* Replace or narrow coarse `TRACE*` globals with a disciplined logger/trace interface.
* Allow targeted module tracing without forcing all subsystems into the same raw stderr stream.
* Keep scanner/parser traces available for deep debugging, but default request/session traces should remain useful without parser-internal noise.

## Verification

* Next word:
  * `grep -A4 -w '\-\->>' tagd-simple-english/simple-english.tagl | head -n 5`
* Translator:
  * `cd tagr && source .venv/bin/activate && python tagr.py --hint subject=against`
* Traced validation:
  * `tagd/tagsh/bin/tagsh --trace -n -f /tmp/against-tagr-candidate.tagl`
* `httagd` runtime availability:
  * `test -x tagd/httagd/bin/httagd && echo httagd-built || echo httagd-not-built`
* Bounded `httagd --trace` sample:
  * `timeout 3s tagd/httagd/bin/httagd --trace --file tagd/tagsh/bootstrap.tagl --www-dir tagd/httagd/tests/www`

## Suggested Commit Message

`out: document TAGL trace/logging failures and dogfood logging plan`
