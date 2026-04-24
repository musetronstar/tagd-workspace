# `tagd` C++23 Engineering Excellence — Refactoring Guide

## The Razor

> Make the code say what it means.

Ownership, lifetimes, ordering contracts, and mathematical invariants must be
visible in the type system — not inferred.

---

## Type Taxonomy (Primary Organizing Principle)

Every refactoring decision begins with this question:

> **What kind of type is this?**

The entire `tagd` system must be classified into one of these categories:

| Type Category                | Description                                                              | Examples                               |
| ---------------------------- | ------------------------------------------------------------------------ | -------------------------------------- |
| **Value Type**               | Copyable, comparable, STL-compatible, represents mathematical objects    | `abstract_tag`, `predicate`, `tag_set` |
| **Execution-Context Type**   | Owns resources, not copyable, represents a running process/state machine | `TAGL::driver`, `scanner`, `callback`  |
| **View Type**                | Non-owning reference into another structure                              | `TokenText`, string slices             |
| **Foreign / Generated Type** | External or tool-generated, cannot be reshaped                           | lemon parser, re2c scanner             |

### Rule

> Never apply value-type rules to execution-context types.

This is the most important constraint in the entire system.

---

## The Mathematical Spine

| Mathematical structure | `tagd` realization   | C++ concern               |
| ---------------------- | -------------------- | ------------------------- |
| Set of tags            | `tag_set`            | ordering, value semantics |
| Partial order          | `rank`               | ordering contracts        |
| Tree                   | subordinate relation | invariant enforcement     |
| Predicate set          | relations            | ordering + identity       |
| Continuous map         | merge functions      | move semantics            |

The math defines the order of refactoring.

---

## Completed Work

### Phase 1 — Value Types (`tagd/`)

* Rule of Five complete
* Ordering contracts defined
* Const correctness established

### Phase 2b — SQLite Layer

* Statement cache
* RAII boundaries clarified

---

## Current Work

### Phase 3 — Execution Context (`tagl/`)

Focus:

* make ownership explicit
* eliminate accidental copy/move
* enforce const correctness
* prove lifetime guarantees

---

## Future Work — Ordered by Dependency

### Phase 4 — `tagdb` Interface

* explicit non-copyable base
* ownership clarity

### Phase 5 — `tagsh`

* verify downstream correctness

### Phase 6 — `httagd`

* top-layer integration

---

## Concepts — Final Stage (Not Phase 3)

Concepts are not optional. They are the **final form** of the system.

They encode mathematical truth at compile time.

### Target Concepts

```cpp
template<typename T>
concept rank_like = requires(T r) {
    { r.contains(r) } -> std::same_as<bool>;
    { r < r } -> std::same_as<bool>;
};

template<typename T>
concept tag_like = requires(T t) {
    { t.id() };
    { t.rank() };
};

template<typename F>
concept continuous_map = requires(F f) {
    // order-preserving mapping
};
```

### Rule

> Concepts come after ownership, const correctness, and taxonomy are complete.

They are not part of Phase 3.

---

## Standing C++23 Improvements

* `std::span` for buffer safety
* `std::string_view` for non-owning inputs
* `[[nodiscard]]` for error handling
* `constexpr` hard tags
* `std::set::extract()` optimization

---

## Test Standard

Every type must prove:

* correct construction semantics
* correct ownership semantics
* correct ordering semantics
* no lifetime violations

---

## Process

* one task per seam
* tests define truth
* no silent scope expansion
* math is the final authority

---

## Core Insight

> `tagd` is not just C++ code — it is a mathematical system expressed in C++.

Engineering Excellence is achieved when:

* the math
* the contracts
* the code

are indistinguishable.

