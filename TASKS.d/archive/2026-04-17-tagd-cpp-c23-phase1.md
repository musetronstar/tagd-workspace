# Task: C++23 Value Semantics and Const Correctness — `tagd` Phase 1

Bring `tagd::abstract_tag`, `tagd::predicate`, `tagd::tag_set` operations, and
`tagd::errorable` into conformance with C++23 value semantics, const correctness,
and STL alignment. These types are the semantic foundation of the entire enterprise —
defects here are not local: they propagate into every downstream module and compound
with each layer built on top. Getting this right now is cheaper than paying the debt later.

Use `tokr::model` as a reference pattern for what well-formed STL value semantics
look like in this codebase — not as a contract to replicate literally.

## Principles

* TDD order is mandatory: each contract is tested first, then implemented.
* Each TDD iteration completes one contract end-to-end: write the test, implement
  the change, fix immediate cascading compile/test consequences, verify integration.
* Comment *why* at every STL protocol site — not *what*. Restating the signature
  in prose is a defect.
* The seam is `tagd.h` and `tagd.cc`. Cascading fixes to keep the build green are
  permitted. Opportunistic cleanup elsewhere is not.

## Scope

### Read
* `tagd/tagd/include/tagd.h`
* `tagd/tagd/src/tagd.cc`
* `tagd/tagd/tests/Tester.h`
* `hardF/tokr/include/model.h` — STL reference pattern
* `hardF/tokr/tests/Tester.h` — test coverage reference
* All other modules (`tagdb`, `tagl`, `tagsh`, `httagd`) — read for caller audit and
  cascading fix verification only.

### Write
* `tagd/tagd/include/tagd.h`
* `tagd/tagd/src/tagd.cc`
* `tagd/tagd/tests/Tester.h`
* Cascading caller fixes in other modules required to keep the build green.

### Non-goals
* No new features or behavioral changes.
* No opportunistic cleanup outside the stated contracts.
* No adoption of `std::set::extract()` in `merge_tags`, `merge_tags_erase_diffs`,
  or `merge_containing_tags` — note as TODO only.
* `predicate` ordering semantics (`cmp_modifier_lt`, `cmp_modifier_eq`) must remain
  stable and documented — the numeric string-promotion logic is a subtle correctness
  invariant that future changes must not break silently.
* If broader changes are required beyond immediate cascading fixes: stop and report.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md` and `AGENTS.md`.

---

## Required Contracts

### Contract 1 — `abstract_tag`: Rule of Five — **COMPLETE**

**Problem:** `abstract_tag` declares `virtual ~abstract_tag()`. Under the Rule of Five,
a user-declared destructor suppresses compiler-generated move constructor and move
assignment. `abstract_tag` is currently not movable. Every `tag_set` insertion,
`merge_tags` call, and `std::vector<abstract_tag>` reallocation silently copies.

**What must be true after this contract:**
* `abstract_tag` has a member `swap(abstract_tag&) noexcept`.
* A free `swap(abstract_tag&, abstract_tag&) noexcept` exists in `namespace tagd`.
* `abstract_tag` has an explicit move constructor and move assignment, both `noexcept`.
* `std::is_nothrow_move_constructible<tagd::abstract_tag>` is true.
* Copy assignment uses copy-and-swap for strong exception safety.
* Subclasses (`tag`, `relator`, `interrogator`, `referent`) are audited: if they add
  data members beyond `abstract_tag`, they require their own swap and move operations.
  For each subclass report one of: "no action needed — no additional data members" or
  "requires follow-on task — see [finding]." Do not implement subclass fixes speculatively.

**TDD:** Write tests for `tagd::tag` (simplest concrete subclass) covering copy
construction, copy assignment, move construction, move assignment, member swap, and
ADL swap (via `using std::swap`). Tests must compile and **fail** before implementation
begins. Use `tokr/tests/Tester.h` as the coverage bar.

---

### Contract 2 — `abstract_tag::operator<` / `operator==` divergence — **COMPLETE**

**Problem:** `operator<` orders by `_id` only (identity ordering, required for
`std::set<abstract_tag>` membership). `operator==` tests all fields (deep equality).
The divergence is intentional and correct but completely undocumented. A type where
`!(a < b) && !(b < a)` does not imply `a == b` is non-obvious and must be stated.

**What must be true after this contract:**
* An intent comment above `operator<` states that it is identity-only ordering for
  `tag_set` membership and intentionally shallower than `operator==`.
* An intent comment above `operator==` states that it tests deep equality and
  intentionally diverges from `operator<`.
* A test confirms that two `tagd::tag` objects with the same `_id` but different
  `relations` are equivalent under `operator<` but not under `operator==`.

**TDD:** Write the test first. It should pass against existing code (the behavior is
already correct); the test makes the contract explicit and guards against regression.

---

### Contract 3 — Const correctness — **COMPLETE**

**Problem:** Three signatures are const-incorrect:
* `tag_set_equal(const tag_set A, const tag_set B)` — takes both by value; silently
  copies two full sets on every call.
* `errorable::last_error_relation(predicate p)` — takes by value; should be `const predicate&`.
* `errorable::most_severe(tagd::code)` — reads only; should be `const`.

**What must be true after this contract:**
* All three signatures are corrected.
* Before changing each signature, all callers across `tagd`, `tagdb`, `tagl`, `tagsh`,
  and `httagd` are audited. Cascading caller fixes are applied where required. If a
  caller change is non-trivial, stop and report before proceeding.

**TDD:** Write tests that call each corrected function through a `const` reference or
in a `const` context. Tests must fail to compile before the fix and pass after.

---

### Contract 4 — Intent comments at STL protocol sites — **COMPLETE**

**Prerequisite:** Contracts 1–3 must be complete and passing.

**What must be true after this contract:**
* Intent comment at each site below. One comment per site; header only unless the
  implementation intent is distinct.

| Site | Why comment is needed |
| ---- | --------------------- |
| `abstract_tag` virtual destructor | why Rule of Five is explicit |
| `abstract_tag::swap` | ADL delegate pattern; `noexcept` enables STL optimization |
| `abstract_tag::operator<` | identity ordering; diverges from `==` by design |
| `abstract_tag::operator==` | deep equality; intentionally deeper than `<` |
| `predicate::operator<` | ordering contract for `predicate_set = std::set<predicate>` |
| `predicate` struct | why compiler-generated special members are sufficient |
| `predicate::cmp_modifier_lt` / `cmp_modifier_eq` | numeric promotion logic is non-obvious |
| `merge_tags` / `merge_tags_erase_diffs` copy/erase/reinsert block | why not `extract()`; TODO for follow-on |
| `errorable::_errors` | why `shared_ptr`; aliasing intent of `share_errors` |
| `session` explicit copy/move | why `atomic` member requires explicit special members |

**This subtask is comment-only. Zero lines of code change.**

---

## Constraints

* Preserve all existing comments and TODOs unless they are factually wrong after the refactor.
* `noexcept` on swap and move is not optional — it is the contract that enables
  `std::vector` and other STL containers to move rather than copy.
* For `predicate::operator<`: do not assert `noexcept` as a correctness requirement.
  Evaluate whether a stronger exception contract is justified and report the finding;
  do not add it unilaterally.
* State the source of truth explicitly when any semantics change.

## Tests

Verify after each contract:

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd/tagd/tests
```

Full build verify after Contract 3 (caller fixes may touch other modules):

```
cd ~/sandbox/codex/tagd-workspace && make -C tagd
```

## Acceptance Criteria

* `tokr::model` test coverage bar is met for `abstract_tag` value-type behavior.
* `std::is_nothrow_move_constructible<tagd::abstract_tag>` is true.
* `operator<` / `operator==` divergence is tested and commented.
* `tag_set_equal`, `last_error_relation`, `most_severe` are const-correct.
* Every STL protocol site in scope carries an intent comment.
* All tests pass. Diff is scoped, reviewable, contains no unrelated changes.

## Deliverable: Concise Report

1. Summary of changes per contract.
2. Test results: exact command and output after each contract.
3. Open issues — callers or subclass findings requiring follow-on work.
