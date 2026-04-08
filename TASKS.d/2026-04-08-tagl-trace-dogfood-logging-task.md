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
