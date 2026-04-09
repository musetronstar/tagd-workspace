# Task

Document what must be true for `tagsh --trace` and `httagd --trace` to speak consistent TAGL dogfood for logs and errors while processing a real Simple English next-word workflow. The output document is an **active reference** task for future implementation of a universal TAGL-native logging and error-reporting system.

**Engineering Excellence**

* **We eat our own dogfood.**
* Logs and errors are part of the product and must preserve the enterprise's TAGL-centered model of truth.
* If output is not valid TAGL, the minimum fallback is TAGL comments prefixed with `--`.
* Consistency across logs, errors, code, docs, and tests is part of correctness.

## Scope

### Read
* `docs/documentation-task-template.md`
* `docs/ai-assisted-dev-doctrine.md`
* `TASKS.d/2026-03-19-08-33-simple-english-task.md`
* `tagd/tagsh/`
* `tagd/tagl/`
* `tagd/tagd/`
* `tagd/httagd/`

### Write
* `out/`

### Non-goals
* no implementation in this task
* no restatement of the Simple English workflow owned by its canonical task file
* no one-off analysis tied to a specific current word in the durable task text

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## What Must Be Done

1. Follow the canonical Simple English task to process the **next word**.
2. During that real workflow, run `tagsh` with `--trace`.
3. If `httagd` is runnable in the workspace, capture a bounded `--trace` case there too. If not, record that fact and inspect its trace path in source.
4. Observe the visible output and classify:
   * logs
   * traces
   * errors
   * structured `tagd:error` output
5. Identify the source roles responsible for that output in:
   * scanner
   * parser
   * driver
   * shell/service entrypoint
   * shared error/reporting base
6. Critique the quality of current error messages:
   * do they help the user understand what went wrong?
   * do they localize the problem?
   * do they separate root cause from trace noise?
   * do they help the user repair the input?
7. Reduce the findings into an implementation-ready plan for:
   * a universal TAGL-native logger
   * improved TAGL-native error reporting built on `tagd:error`
   * migration away from chaotic mixed-format trace output
   * disciplined use or replacement of current global `TRACE*` controls

## Constraints

* document current truth, not remembered architecture
* keep the task focused on `what`, verification, and acceptance
* do not duplicate canonical instructions from other source documents
* use `tagd:error` as the authoritative base model for structured errors
* extend existing logging wisdom; do not invent an unrelated parallel scheme

## Verification

* verify the next-word workflow by following the canonical task file
* verify at least one real `tagsh --trace` run
* verify `httagd` runtime availability or non-availability in the current workspace
* verify source-role claims against current code

## Acceptance Criteria

* the resulting document stays concise and durable
* the task is grounded in a real traced next-word workflow
* the document clearly distinguishes logs, traces, and errors
* the document produces actionable criteria for better TAGL-native errors
* the document produces an actionable plan for a universal TAGL-native logger
* the document does not overfit to transient current-turn context

## Deliverable

1. findings from the real traced workflow
2. classification of current output by role
3. critique of error-message quality
4. reduced implementation plan
5. verification performed
6. suggested concise git commit message

## Logger Design Addendum

### Current Trace Finding

`tagsh -f tagd/tagsh/bootstrap.tagl --trace -n` currently emits mixed output:

* valid TAGL source echo
* valid TAGL comments such as `-- TAGD_OK`
* non-TAGL parser trace lines such as `tagl_trace: Shift ...`
* non-TAGL source-location diagnostics such as `tagl.cc:124 line ...`
* non-TAGL callback diagnostics such as `callback::cmd_put: ...`
* non-TAGL scanner buffer diagnostics such as `fill ln:` and `print_buf:`
* interleaved stdout/stderr output that can corrupt otherwise readable lines

This proves `--trace` is not a TAGL-native logging mode and should be migrated behind a real logger.

### Logging Direction

Create a minimal logger in core `tagd/`.

The logger is a conventional logging facility:

* uses traditional syslog-style levels
* defaults to `stderr`
* supports a configurable `std::ostream` sink for tests and future routing
* logs ordinary messages without requiring tag or tagdb knowledge
* can accept a `tagd::event` or `tagd::error` and print it as TAGL

Log level and event type are separate concepts.

Event type describes what happened. Log level controls filtering and operational treatment.

### Initial Logger Shape

Start with a small interface, likely in `tagd/include/tagd/logger.h`:

```c++
namespace tagd {
	enum class log_level {
		emergency,
		alert,
		critical,
		error,
		warning,
		notice,
		info,
		debug
	};

	class logger {
		public:
			logger();
			explicit logger(std::ostream&);

			void level(log_level);
			log_level level() const;

			void log(log_level, const std::string&);
			void log(log_level, const tagd::event&);
			void log(log_level, const tagd::error&);
	};
}
```

Do not over-design sinks, formatting backends, or async buffering in the first iteration. Keep the seam testable.

### Event Direction

Do not make every trace line an event.

Events are significant system facts, such as:

* request/session lifecycle points
* tagdb method results
* command execution results
* structured errors
* future HTTP request/response observations

Avoid creating `tagd::code` values for every event type. That is not sustainable.

Add an event constructor that accepts one event type tag:

```c++
tagd::event::event(tagd::session&, const tagd::id_type& program, const tagd::id_type& event_type_tag);
tagd::event::event(const tagd::id_type& event_type_tag);
```

The one-argument constructor should create a normal event instance whose `super_object` is the supplied event type. Internal callers should prefer hard tag macros for event type ids.

### Hard Tag Direction

Add specific event type hard tags only when an event is meaningful enough to persist or inspect.

Potential first event type families:

```tagl
_log_event _type_of _event
_command_event _type_of _event
_tagdb_event _type_of _event
_http_event _type_of _event
```

Do not encode log level into the event type hierarchy.

### Migration Direction

Retire `--trace` and global `TRACE*` controls by routing their useful output through the logger.

Migration order:

1. Add core `tagd::logger` with level filtering and testable sink.
2. Add command-line log-level and verbosity options to `tagsh`.
3. Route existing `tagsh --trace` output through logger calls.
4. Remove or comment out low-value scanner/parser noise.
5. Convert useful parser/scanner diagnostics to `debug` or `trace` logger messages.
6. Add `httagd` request logging through the same logger.
7. Introduce durable `tagd::event` instances only for significant lifecycle/result events.

`--trace` may remain temporarily as a compatibility alias for the most verbose logger setting, but it should stop directly toggling global trace behavior.
