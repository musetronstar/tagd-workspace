# C++23 Excellence Guide for tagd

## Core Philosophy

> “Simplicity is prerequisite for reliability.” — Edsger Dijkstra

tagd C++ is written to *express* the **mathematical structure** of the system.

- Structure > behavior
- Types > comments
- Compile-time > runtime
- Truth > convenience

---

## Expert’s Razor

> Remove everything that is not essential to the mathematical truth.

> *Imagine Stroustrup, the STL authors, and Meyers inspecting this code.
> What would they change, and in what order?*

Their answer would not be "modernize syntax." It would be:
**make the code say what it means.** Ownership, lifetimes, ordering contracts,
const boundaries — every invariant the system has should be visible in the type
system, not inferred from reading three files.

The `tagd` math document gives us something most codebases lack: a precise
formal model of what the system is. Tags are points in a topological space.
Ranks encode a partial order. The tagspace is its own specification. This is
not a metaphor — it is a theorem. C++23 gives us the tools to make the code
as honest as the math.

Standard: every line must justify its existence.

---

## The Mathematical Backbone

The `tagd` math document identifies these structures, each of which has a
direct C++ correspondence:

| Mathematical structure | `tagd` realization | C++ concern |
| ---------------------- | ------------------ | ----------- |
| Set of tags T | `tagd::tag_set = std::set<abstract_tag>` | Value type correctness, `operator<` contract |
| Partial order (⊑) | `rank::contains()`, rank prefix | `operator<=>`, `std::strong_ordering` candidate |
| Lexicographic total order | `rank::operator<` | `noexcept`, `std::totally_ordered` concept |
| Rooted tree | subordinate relation, `_entity` root | Invariant enforcement, hard tag immutability |
| Fiber / predicate set | `predicate_set` at each tag | `operator<` on `predicate`, const correctness |
| Continuous map | `merge_containing_tags` | Move semantics, `tag_set` efficiency |
| Canonical serialization | `dump()` | Rank-aware ordering (planned, see TODO) |
| Hard tag universal base | `hard-tags.h` | `constexpr`, compile-time invariants |

The refactoring order follows this structure. Fix what the math says is foundational
before fixing what depends on it.

### Tagd Math Paper → tagd Codebase Mapping

* tagspace = tree
* rank = prefix order
* identity = position

---

## Type Taxonomy — Ask This First

Before writing a single special member, classify the type. The classification
determines everything: what C++ features apply, what the correct special member
policy is, and what "correct" even means.

**Value type** — *is* its data. Two instances with the same data are
interchangeable. Copy, move, swap, equality, and ordering all make semantic
sense. STL containers and algorithms are built for these.
`tagd::predicate`, `tagd::abstract_tag`. Apply the Rule of Five or Rule of Zero.

**Execution-context type** — coordinates resources and process state. Copying
it makes no semantic sense. `TAGL::driver`, `TAGL::scanner`, `tagdb::tagdb`,
`tagdb::sqlite`. Explicitly `= delete` copy and move; document why.

**View type** — a non-owning window into storage someone else owns. Its
lifetime is governed entirely by the backing store. `TAGL::text_token` — `z`
points into `token_store`; treat it as owning and you get dangling pointers.

**Foreign / generated type** — managed by a C API or a code generator. Wrap
carefully; document the foreign contract; do not modernize in ways that lie
about the real constraint. `_parser` (`void*` owned by lemon's `ParseAlloc` /
`ParseFree`) is the primary example.

The same Rule of Five symptom — virtual destructor suppressing moves — demands
**opposite medicine** depending on taxonomy: `abstract_tag` needed move
operations *added*; `driver` needed them *deleted*.

---

## Const Correctness

Const encodes invariants.

```cpp
const tagd::id_vec& context() const;
```

Do not use const for style. Use it to express truth.

---

## Ownership & Lifetime (RAII)

Prefer stack lifetime:

```cpp
session get_session() {
    return session(this);
}
```

Delete unsafe semantics:

```cpp
tagdb(const tagdb&) = delete;
tagdb& operator=(const tagdb&) = delete;
```

---

## [[nodiscard]] as Contract

```cpp
[[nodiscard]] tagd::code get(...);
```

Return values must be checked. Ignoring them is a bug.

---

## Well Defined Types

```cpp
typedef enum {
    TAGD_OK = 0,
    TS_NOT_FOUND,
    TS_DUPLICATE
} code;
```

Principles:

* enums encode domains
* types encode semantics (domain constraints)
* no “stringly-typed” logic
  - example: a bad "stringly-type" might use raw strings where dedicated types should be used
  - the compiler sees `id_type` everywhere and cannot distinguish a relator from a tag id, a subject from an object.
    -  Swapped arguments compile silently.
  - C++23 strong wrapper types and concepts are the cure

---

## tagd Mathematical Core

Reflected in:

tagspace:
- rooted tree
- partial order
- prefix ordering via rank

where identity is derived from topological structure, not labels.

    "To be, is to be related"

Therefore, relational structure defines meaning.
And if a tagspace is mathematically a *topology*, meaning is also geometry.
Entire classes of mathematics might be available to help use reason by
operating upon and transforming tagspaces mathematically.

```cpp
bool contains(const rank&) const;
```

---

## Hard Tags

```cpp
#define HARD_TAG_SUB		"_sub"		//gperf HARD_TAG_ENTITY, tagd::POS_SUB_RELATOR
```

Never inline string literals. Use compile-time constants.

---

## Consistency

- Same naming patterns
- Same error handling
- Same ownership rules

Consistency reduces cognitive load.

---

## Comments

Only explain:
- why
- invariants
- non-obvious constraints

Never explain obvious code.

---

## C++23 Direction

- Rule of Zero (by default)
- Rule of Five (when necessary)
- constexpr where possible
- concepts for constraints

Integrated ideas:

* fail fast
* isolate errors
* propagate explicitly


---

## Error Philosophy

Errors are explicit:

- no silent failure
- no hidden state
- propagate via return codes

---

## Final Standard

Question to ask before refactoring or changing structure.

+ Does the structure encode the math?
+ Is the invariant enforced in the type system?
+ Does the type system express the truth?
+ Is the design simpler, better defined or more robust?
+ Does it make illegal states impossible?

