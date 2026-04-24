# `tagd` C++ 23: Refactoring History, Progress & Future

Can we keep the same truth the system produces? In:
* tagd design contracts
* TAGL language
* tagsh usage
* httagd usage
We have good tests throughout the system to confirm this. If the tests themselves need to be updated, the task should provide that guidance (upstream as the next chosen TDD iteration feature).
Stop and ask questions If clarification is needed.

You've responded with a lot - some good, but some unbalanced due to conflicting goals on my part (sorry). But overwhelming none-the-less. For me its like a pile of raw ingredients that  needs sliced, diced, fermented and distilled.

But this software is not currently in production use. Everything is subject to change if it is an improvement. However, we don't change everything all at once.  We document issues, and make task files that guide our development.

There are many things that are well defined in this system (as evidenced by the design by test/contract => => implementation => test verification pipeline) lean on those facts ordered by its first principles. We have a strong vision that is well documented.

## C++ Experts Razor
So having said that, Imagine Bjarne Strousoup, the authors of C++ STL, and Eric Meyers, are in the room, all inspecting my code...

What kind of task file would these C++ principles/teachers write to take `tagd` C++ from its current state to a state of **Engineering Excellence** according to best practices (up to version C++ 23)?

Use this as a razor to rewrite the Phase 3 task file and review the `tagd` codebase.

## High Standard
If this high C++ standard for `tagd` is not reached in the existing base code, or if the acceptance criteria in these relavent task files has not been met, we need to document the gaps and shortcomings so that we can write tasks to guide us towards Engineering Excellence.

### `tagd` Codebase

In the `tagd` repository: 

```bash
$ git ls-files  # I pasted `lemon` generated `parser.h` manually
.editorconfig
.gitignore
LICENSE
Makefile
README.md
docs/tagd-cloud.png
httagd/Makefile
httagd/app/.eslintrc.json
httagd/app/Makefile
httagd/app/main.cc
httagd/app/tpl/browse.html.tpl
httagd/app/tpl/error.html.tpl
httagd/app/tpl/home.html.tpl
httagd/app/tpl/layout.html.tpl
httagd/app/tpl/query.html.tpl
httagd/app/tpl/relations.html.tpl
httagd/app/tpl/tag.html.tpl
httagd/app/tpl/tree.html.tpl
httagd/app/www/favicon.ico
httagd/app/www/script/api.js
httagd/app/www/script/main.js
httagd/app/www/script/tag.js
httagd/app/www/script/tagl.js
httagd/app/www/script/tagsh.js
httagd/app/www/script/tree.js
httagd/app/www/style/main.css
httagd/architecture.md
httagd/include/httagd-client.h
httagd/include/httagd.h
httagd/new-app.sh
httagd/src/Makefile
httagd/src/client-main.cc
httagd/src/httagd-client.cc
httagd/src/httagd.cc
httagd/tests/ClientTester.h
httagd/tests/Makefile
httagd/tests/Tester.h
httagd/tests/tester.exp
httagd/tests/www/test.txt
tagd/Makefile
tagd/hard-tags.md
tagd/include/tagd.h
tagd/include/tagd/codes.h
tagd/include/tagd/config.h
tagd/include/tagd/domain.h
tagd/include/tagd/event.h
tagd/include/tagd/file.h
tagd/include/tagd/hard-tags.h
tagd/include/tagd/http.h
tagd/include/tagd/io.h
tagd/include/tagd/logger.h
tagd/include/tagd/rank.h
tagd/include/tagd/ulid.h
tagd/include/tagd/url.h
tagd/include/tagd/utf8.h
tagd/src/Makefile
tagd/src/domain/Makefile
tagd/src/domain/domain.cc
tagd/src/domain/effective_tld_names.dat
tagd/src/domain/gen-gperf-tlds.pl
tagd/src/domain/public-suffix.gperf
tagd/src/domain/public-suffix.gperf.h
tagd/src/event.cc
tagd/src/file.cc
tagd/src/gen-codes-inc.pl
tagd/src/io.cc
tagd/src/logger.cc
tagd/src/rank.cc
tagd/src/tagd.cc
tagd/src/ulid.c
tagd/src/url.cc
tagd/src/utf8.cc
tagd/tests/DomainTester.h
tagd/tests/EventTester.h
tagd/tests/FileTester.h
tagd/tests/LoggerTester.h
tagd/tests/Makefile
tagd/tests/Tester.h
tagd/tests/UrlTester.h
tagd/tests/io-test/file.txt
tagdb/Makefile
tagdb/include/tagdb.h
tagdb/sqlite/Makefile
tagdb/sqlite/include/tagdb/sqlite.h
tagdb/sqlite/src/Makefile
tagdb/sqlite/src/sqlite.cc
tagdb/src/Makefile
tagdb/src/gen-hard-tags.gperf.pl
tagdb/src/hard-tag.cc
tagdb/src/tagdb.cc
tagdb/tests/Makefile
tagdb/tests/Tester.h
tagl/Makefile
tagl/architecture.md
tagl/include/parser.h
tagl/include/scanner.h
tagl/include/tagl.h
tagl/src/Makefile
tagl/src/lemon.c
tagl/src/lempar.cc
tagl/src/parser.y
tagl/src/scanner.cc
tagl/src/scanner.re.cc
tagl/src/tagdurl.re.cc
tagl/src/tagl.cc
tagl/tests/Makefile
tagl/tests/TagdUrlTester.h
tagl/tests/Tester.h
tagsh/Makefile
tagsh/bootstrap.inc.tagl
tagsh/bootstrap.tagl
tagsh/include/tagsh.h
tagsh/src/Makefile
tagsh/src/main.cc
tagsh/src/tagsh.cc
tagsh/tests/DriverTester.h
tagsh/tests/LogTester.h
tagsh/tests/Makefile
tagsh/tests/tester.exp
```

## Doctrine, Tasks and Reports

```bash
AGENTS.md
docs/ai-assisted-dev-doctrine.md
docs/refactor-task-template.md
README.md
STYLE.md
TAGL-README.md
out/2026-03-21-claude-tagr-c++-trie-design.md
out/2026-03-21-codex-tagr-trie-memo.md
out/2026-04-06-refactor-closeout-audit.md
out/2026-04-06-scanner-parser-tagdurl-status-report.md
out/2026-04-08-tagl-trace-dogfood-logging-report.md
out/2026-04-11-tagd-logging-guide.md
out/2026-04-17-tagdb-sqlite-stmt-cache-aar.md
out/2026-04-17-tagd-cpp23-phase1-aar.md
TASKS.d/2026-04-04-parser-refactor.md
TASKS.d/2026-04-04-tagdurl-refactor.md
TASKS.d/2026-04-06-callback-context-refactor.md
TASKS.d/2026-04-12-tagsh-test-layer-refactor.md
TASKS.d/2026-04-16-httagd-client-task.md
TASKS.d/2026-04-16-tokr-port-perl-c++.md
TASKS.d/2026-04-17-tagdb-sqlite-stmt-cache.md
TASKS.d/2026-04-17-tagd-cpp-c23-phase1.md
TASKS.d/2026-04-18-tagl-cpp23-phase3.md
TASKS.d/archive/2026-03-19-11-36-scanner-refactor-task.md
TASKS.d/archive/2026-03-20-08-33-scanner-refactor-continue.md
TASKS.d/archive/2026-04-08-tagl-trace-dogfood-logging-task.md
TASKS.d/archive/2026-04-09-tagd-event-evuri-task.md
```

## Apply the razor

Follow our documentation template

Apply the razor and create two documents for download:

1. Surgically update `TASKS.d/2026-04-18-tagl-cpp23-phase3.md` according to the **Experts Razor**
2. Apply the C++ 23 Experts Razor to the existing `tagd` codebase and write (from scafolding to mastery) a refactoring guide in `out/` towards C++ 23 Engineering Excellence in tagd.

Stop and do not guess if you need clarification. Use Socratic questioning.
Ask for me to upload any files referenced that you will need.

## Lessons Learned

After applying the razor and refactoring the `tagd` C++ codebase, here are some lessons learned:

* The C++ Experts Razor forces every change to be judged against zero-overhead, strong contracts, and Rule of Zero. This eliminates the temptation to add clever abstractions that look modern but increase cognitive load without delivering measurable benefit. Impact: future refactoring phases will be shorter and safer because we now have a clear filter for what "good" looks like.

* Mathematical truths (rank as prefix partial order, structural identity, canonical TAGL dump) are not optional documentation — they are the system's spine. When we express them directly in types and concepts, the compiler becomes an ally instead of a passive translator. Impact: consistency is no longer a hope or a test assertion; it becomes a compile-time guarantee, which is the only way a semantic system like tagd can remain trustworthy at scale. Good types and concepts help reinforce this.

* Execution-context types (driver, scanner, callback) must be explicitly non-copyable. Treating them as values silently invites lifetime bugs. Impact: deleting copy/move constructors early removed an entire class of potential bugs before they could appear in tagsh or httagd usage.

* Concepts and `std::expected` move contracts from comments/READMEs into the type system. Impact: the cost of maintaining correctness drops dramatically because violations are caught at compile time rather than in tests or production.

* The original C port of `tagd::url` being slower than the C++ version was not a surprise once aliasing and optimizer information were considered. Impact: this validates that modern C++ is the right default for tagd's core; C should only be chosen at clear system boundaries (like libevent) where the ABI matters, not as a premature optimization.

* Incremental, test-driven phases with explicit justification documents prevent "big rewrite" drift. Impact: we keep the same system truth while steadily raising the engineering floor, which is the only sustainable path for a codebase that must remain reliable for years.

