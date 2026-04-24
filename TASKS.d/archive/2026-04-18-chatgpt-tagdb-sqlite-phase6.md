Next is **Phase 6: decide the real `tagdb` abstraction boundary**.

## Status

* COMPLETE: the implementation objective was completed and documented in `out/2026-04-19-tagdb-cpp23-phase6-aar.md`; the only remaining gap was task-record reconciliation because this file remained a draft prompt rather than a full task spec.

Phase 5 only exposed the seam honestly. Now you choose, method by method:

* which sqlite-only methods should be promoted into `tagdb::tagdb`
* which should remain sqlite implementation detail
* whether `tagsh` should stop storing the concrete sqlite type

That is the next meaningful design step.

A good Phase 6 task would be:

## Phase 6 — `tagdb` abstraction tightening

Goal:

* review every sqlite-only public method still visible above the abstraction
* classify each one:

  * **promote** to `tagdb::tagdb`
  * **keep sqlite-only**
  * **defer / needs redesign**
* preserve identical behavior and tests

Likely contracts:

* audit public sqlite-only methods
* identify which are used by `tagsh` / `httagd`
* promote only the truly cross-backend operations
* document the rest as sqlite-specific
* narrow concrete-type storage where possible

Why this is next:

* Phase 4 made `tagdb` honest as an execution-context interface 
* Phase 5 cleaned one visible leak at the top
* the remaining question is no longer “is the boundary lying?”
* it is now “what **belongs** in the boundary?”

Also do this housekeeping now:

* write a short **Phase 5 AAR**
* update the excellence guide with:

  * Phase 5 complete
  * one accidental abstraction leak found and fixed
  * remaining work is interface promotion/narrowing

The shortest honest answer:

> **Next is Phase 6: formalize the `tagdb` vs `sqlite` interface boundary.**

I can draft that task.
