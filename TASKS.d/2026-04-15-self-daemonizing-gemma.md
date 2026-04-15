# Task

Turn `bin/gemma.py` into a self-daemonizing local client for `google/gemma-4-E2B-it` using a UNIX socket. Default invocation should ensure a daemon is available, send one request, print only the model response to `stdout`, and exit. `--daemon` should run the long-lived server process, load the model once, serve multiple requests, reset an idle shutdown timer on each request, and exit after a configurable idle period.

## Scope

You have read access in this directory `./` and recursivly in its subdirectories.

You have read/write access in the git worktree `tagd-ai/`.

### Read
* `AGENTS.md`
* `README.md`
* `STYLE.md`
* `tagd-ai/bin/gemma.py`
* `tagd-ai/deps/setup-venv.sh`
* `tagd-ai/deps/pip-modules.txt`

### Write
* `tagd-ai/bin/gemma.py`
* `tagd-ai/tests/test_gemma.py`
* repo-local tests for the client/daemon contract

### Non-goals
* no HTTP server
* no web framework
* no new external dependencies unless unavoidable
* no multimodal expansion
* no multi-model orchestration

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`.

## Workspace / Execution

* activate the repo environment with `venv`
* use the repo interpreter path explicitly when needed: `.venv/bin/python3`
* do not use system Python for this task
* if adding test commands or examples, prefer `.venv/bin/python3 ...` so execution is unambiguous

## Constraints

* preserve existing prompt input behavior unless improved in a backward-compatible way
* keep the diff scoped and reviewable
* prefer Python standard library primitives
* use a UNIX socket as the daemon rendezvous point
* do not use process-name lookup as the source of truth
* if a pid or lock file is used, it must not be the only health signal
* client mode remains default; daemon mode explicit
* response goes to `stdout`
* diagnostics/debug output go to `stderr`
* preserve comments and design intent unless correction is required
* if comments drift from the code, correct them

## Tests

* add fast tests proving:
  * default invocation ensures daemon availability
  * repeated requests reuse the daemon
  * response is printed to `stdout`
  * diagnostics stay on `stderr`
  * idle timeout shuts the daemon down
  * stale socket/lock state does not count as healthy
* if real model loading makes tests too slow, introduce a seam so lifecycle/protocol behavior can be tested without loading the real model
* task is not complete until the required tests pass

## Acceptance Criteria

* `bin/gemma.py` self-daemonizes in normal client use
* `bin/gemma.py --daemon` runs the daemon
* client/daemon use a UNIX socket
* model loads once per daemon lifetime
* each request resets idle timeout
* daemon exits after configured idle time
* shell usage is cleaner than reload-per-call behavior
* tests pass

## Deliverable

1. summary of changes
2. test results
3. open issues or observations
4. suggested concise git commit message

