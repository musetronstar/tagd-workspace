# The Mathematics of tagd

*A formal description of the mathematical structures present in the tagd
semantic-relational system and the TAGL language.*

---

## Preface

The tagd system was built from engineering instincts about how knowledge
should be structured. This paper makes the mathematics of those instincts
explicit. Every claim here is grounded in the tagd source code and the TAGL
specification. Where we identify a named mathematical structure — a partial
order, a topology, a universal base — it is because the source already
exhibits that structure, not because we are imposing one on it.

The core thesis is simple: **information is structural**. A tag's meaning is
not intrinsic. It is determined entirely by its position in the tagspace — by
its relations to other tags. This is not a metaphor. It is a precise
mathematical claim, and the sections below give it precise mathematical form.

---

## 1. Primitives

### 1.1 Tags

A **tag** is the atomic unit of the tagd system. All tokens in TAGL are
UTF-8 labels (`tagd-README.md`). A tag has:

- a globally unique UTF-8 label called its **nominal identity**
- a position in the tagspace hierarchy called its **structural identity**

Formally, let $T$ be the set of all tags in a tagspace. Each tag
$t \in T$ is identified by a string $\text{id}(t) \in \Sigma^*$ where
$\Sigma^*$ denotes the set of all finite UTF-8 strings.

In TAGL:
```tagl
>> dog _is_a mammal;
```

Here `dog` is a tag. Its nominal identity is the string `"dog"`. Its
structural identity is defined by its subordinate relation to `mammal`.

### 1.2 The Root and the Axiom

Every tagspace has a distinguished root tag: `_entity`.

From `tagd-README.md`:
> `_entity` is axiomatic and self-referencing (i.e. `_entity _sub _entity`).
> It is the only tag having this relation. It is the root of a tagspace.

This is the **axiomatic element**: the one tag that does not require another
tag above it to justify its existence. It is the fixed point of the
subordinate relation.

In TAGL notation:
```tagl
_entity _sub _entity
```

In set-theoretic terms, `_entity` is the **least element** of the tagspace
under the subordinate order — the tag that is an ancestor of everything,
including itself.

---

## 2. The Subordinate Relation and the Rooted Tree

### 2.1 Subordinate Relations

A tag's **structural identity** is defined by a single subordinate (sub)
relation. From `TAGL-spec.md`:

> A tag's identity is defined by a sub relation. A subject MUST have
> exactly one subordinate relation to exist in the tagspace.

Sub relators defined in `hard-tags.h`:

```c
#define HARD_TAG_SUB     "_sub"     // most abstract sub relator
#define HARD_TAG_IS_A    "_is_a"    // instance subordination
#define HARD_TAG_TYPE_OF "_type_of" // type subordination
```

In TAGL:
```tagl
>> physical_object -^ _entity;
>> living_thing _type_of physical_object;
>> animal _type_of living_thing;
>> mammal _type_of animal;
>> dog _is_a mammal;
```

### 2.2 The Tagspace as a Rooted Tree

The subordinate relation organizes all tags into a **rooted tree**:

- The **root** is `_entity`
- Each non-root tag $t$ has exactly one **parent** $p(t)$, the super-object
  of its subordinate relation
- There are no cycles (except the axiomatic self-reference of `_entity`)

Formally: a tagspace is a pair $(T, p)$ where:

- $T$ is a set of tags
- $p : T \setminus \{\texttt{\_entity}\} \to T$ is the parent function
  assigning each non-root tag its super-object

The tree structure of the example above:

```
_entity
└── physical_object
    └── living_thing
        └── animal
            └── mammal
                └── dog
```

This is not merely a data structure choice. The tree encodes **taxonomic
knowledge**: to be a `dog` is to be a `mammal`, which is to be an `animal`,
and so on. Structural position *is* meaning.

---

## 3. Rank: Encoding the Tree in Strings

### 3.1 The Rank Function

Each tag is assigned a **rank** — a UTF-8 byte string that encodes its
position in the tagspace tree. From `rank.h`:

> A rank string is the ordinal value of each node in the tagspace tree.
> A code point at a particular level is known as the rank value.

The rank function $r : T \to \Sigma^*$ assigns to each tag a string such
that the string's structure reflects the tag's position in the tree.

From the bootstrap dump (`bootstrap-dump-grid.txt`):

```
_entity       rank: (empty / level 0)
_sub          rank: 1
_is_a         rank: 1.1
_type_of      rank: 1.2
_rel          rank: 2
_has          rank: 2.1
_number       rank: 3
_integer      rank: 3.1
_float        rank: 3.2
```

### 3.2 The Prefix Partial Order

The key property of ranks, stated explicitly in `rank.h`:

> All children of a particular node in the rank hierarchy will be prefixed
> by the parent node — that is, rank substrings define subtrees in the
> hierarchy.

This gives rise to a **partial order** on tags via their ranks. Define the
**containership relation** $\sqsubseteq$ on $T$ by:

$$a \sqsubseteq b \iff r(b) \text{ is a prefix of } r(a)$$

In plain language: $a \sqsubseteq b$ means $b$ is an ancestor of $a$ (or
$b = a$). Tag $b$ **contains** tag $a$ in the hierarchy.

This is implemented directly in `rank.h`:

```cpp
// this rank contains the rank being compared,
// in other words, this rank is a prefix to the other
bool contains(const rank&) const;
```

And used in `tagd.cc` for structural operations:

```cpp
if (b->rank().contains(a->rank())) { // rank can contain itself (b == a)
    merged++;
}
```

### 3.3 Verifying the Partial Order Axioms

The containership relation $\sqsubseteq$ is a **partial order** because it
satisfies all three required properties:

**Reflexivity:** Every tag contains itself — `rank.h` notes `contains()`
holds when `b == a`. In dotted notation: `1.1` is a prefix of `1.1`. ✓

**Antisymmetry:** If $a \sqsubseteq b$ and $b \sqsubseteq a$, then
$r(b)$ is a prefix of $r(a)$ and $r(a)$ is a prefix of $r(b)$, which
implies $r(a) = r(b)$, hence $a = b$. ✓

**Transitivity:** If $r(b)$ is a prefix of $r(a)$ and $r(c)$ is a prefix
of $r(b)$, then $r(c)$ is a prefix of $r(a)$. ✓

So $(T, \sqsubseteq)$ is a **poset** (partially ordered set).

### 3.4 Lexicographic Order

Ranks also carry a total **lexicographic order**, implemented by:

```cpp
bool operator<(const rank& rhs) const { return _data < rhs._data; }
```

This order — noted in `rank.h` as a deliberate UTF-8 design choice ("it
collates lexicographically") — enables efficient storage and retrieval of
the entire tagspace as a sorted structure. Tags within the same subtree sort
together. The tree *is* the index.

---

## 4. The Tagspace Topology

### 4.1 From Partial Order to Topology

Every partial order canonically generates a topology. Given the poset
$(T, \sqsubseteq)$, define the collection $\mathcal{T}$ of **open sets**
as all **upward-closed** subsets of $T$:

$$U \in \mathcal{T} \iff \forall a \in U, \forall b \in T :
a \sqsubseteq b \Rightarrow b \in U$$

In the tagspace tree, "upward-closed" means: if a tag is in the set, all
its **ancestors** are too. Equivalently, each basic open set is the
**subtree rooted at a tag** together with all tags above it.

This is called an **Alexandrov topology** — the topology generated by a
partial order where arbitrary intersections (not just finite ones) of open
sets remain open.

### 4.2 Verifying the Topology Axioms

Let $M$ be the underlying set of all tags in a tagspace, and let
$\mathcal{T}$ be the collection of upward-closed subsets. We verify
the three axioms from the video transcript and the screenshot:

**(i) $\emptyset \in \mathcal{T}$ and $M \in \mathcal{T}$**

The empty set is vacuously upward-closed. The entire tagspace $M$ is
upward-closed because there is nothing outside it. Both belong to
$\mathcal{T}$. ✓

**(ii) Finite intersections stay in $\mathcal{T}$**

If $U, V \in \mathcal{T}$ then $U \cap V \in \mathcal{T}$.

Proof: suppose $a \in U \cap V$ and $a \sqsubseteq b$. Then $b \in U$
(since $U$ is upward-closed) and $b \in V$ (since $V$ is upward-closed),
so $b \in U \cap V$. ✓

In the tagspace: the intersection of two subtrees is either empty or the
subtree of their common ancestor. This is exactly what `merge_containing_tags`
in `tagd.cc` computes:

```cpp
if (b->rank().contains(a->rank())) {
    merged++;
} else if (a->rank().contains(b->rank())) {
    A.insert(*b);
}
```

**(iii) Arbitrary unions stay in $\mathcal{T}$**

If $\{U_\alpha\}$ is any collection of sets in $\mathcal{T}$, then
$\bigcup_\alpha U_\alpha \in \mathcal{T}$.

Proof: suppose $a \in \bigcup U_\alpha$ and $a \sqsubseteq b$. Then $a \in
U_\alpha$ for some $\alpha$. Since $U_\alpha$ is upward-closed, $b \in
U_\alpha \subseteq \bigcup U_\alpha$. ✓

Therefore $(M, \mathcal{T})$ is a **topological space**. ✓

### 4.3 Specialization Order

In the Alexandrov topology, every topological space carries a natural
**specialization preorder**: $a$ specializes $b$ (written $a \rightsquigarrow b$)
when $a$ is in the closure of $\{b\}$.

In the tagspace, this specialization order is exactly the subordinate order:
`dog` specializes `mammal`, which specializes `animal`. More specific tags
(deeper in the tree) specialize more general ones. The topology makes
taxonomic inheritance a *geometric* fact — not a rule to be enforced, but a
structural consequence of the shape of the space.

### 4.4 Continuity as Meaning-Preservation

A map $f : T_1 \to T_2$ between two tagspaces is **topologically
continuous** if and only if it preserves open sets — equivalently, if it
preserves the subordinate order. If `dog _is_a mammal` in $T_1$, a
continuous map must send `dog` somewhere below `mammal`'s image in $T_2$.

This gives a precise mathematical definition of a **meaning-preserving
transformation** between tagspaces.

---

## 5. The Hard Tag Base: A Universal Subspace

### 5.1 Hard Tags

Every tagspace — no matter how different its user-defined tags — contains
exactly the same set of hard tags, defined in `hard-tags.h`:

```c
#define HARD_TAG_ENTITY      "_entity"      // root
#define HARD_TAG_SUB         "_sub"         // subordination
#define HARD_TAG_IS_A        "_is_a"        // instance relation
#define HARD_TAG_TYPE_OF     "_type_of"     // type relation
#define HARD_TAG_RELATOR     "_rel"         // predicate root
#define HARD_TAG_HAS         "_has"         // possession
#define HARD_TAG_CAN         "_can"         // capability
#define HARD_TAG_NUMBER      "_number"      // numeric type root
#define HARD_TAG_INTEGER     "_integer"     // integer type
#define HARD_TAG_FLOAT       "_float"       // float type
#define HARD_TAG_INTERROGATOR "_interrogator" // query root
```

From the bootstrap dump, their ranks are fixed and invariant:

```
_entity        (rank: empty — level 0)
_sub           rank: 1
_rel           rank: 2
_number        rank: 3
_interrogator  rank: 4
```

### 5.2 The Hard Tag Subspace

Let $H \subset T$ denote the set of hard tags in any tagspace $T$. The
induced subspace topology on $H$ is the same in every tagspace. $H$ is
therefore a **universal invariant subspace** — a fixed topological base
that every tagspace shares.

In category-theoretic terms, the hard tag subspace is the **initial
object** in the category of tagspaces: every tagspace is an extension of
$H$, and every valid map between tagspaces must fix $H$.

### 5.3 Interoperability via the Common Base

Because every tagspace contains $H$ as a common topological foundation,
any two tagspaces can communicate. The hard tags are the shared language —
the invariant ground that makes the `httagd` web protocol possible. Two
tagspaces may diverge arbitrarily in their user-defined tags, but they
always agree on the structure of $H$.

In TAGL:
```tagl
>> dog _is_a mammal;       -- user-defined, varies by tagspace
_entity _sub _entity        -- axiomatic, invariant in every tagspace
```

---

## 6. Predicates: Fibered Structure

### 6.1 Predicates as Horizontal Relations

Predicates are relations attached to a tag that do not alter its position
in the tree. From `TAGL-spec.md`:

> A predicate consists of a relator followed by an object_list.
> A relator MUST be a tag subordinate to `_rel`.

In TAGL:
```tagl
>> dog _is_a mammal
    _has legs = 4, tail
    _can bark;
```

Here `_is_a mammal` is the vertical (structural) relation that places `dog`
in the tree. `_has legs = 4`, `_has tail`, and `_can bark` are horizontal
predicates — additional structure attached at the point `dog`.

### 6.2 The Two-Layer Structure

The tagspace thus carries two distinct mathematical layers:

1. **The base space**: the topological space $(M, \mathcal{T})$ defined by
   subordinate relations and ranks — the vertical dimension.

2. **The fiber**: at each tag $t \in M$, a set of predicates
   $P(t) \subseteq \text{Rel} \times T \times \text{Mod}$ — the horizontal
   dimension.

This two-layer structure — a base space with additional data at each point
— is analogous to a **fiber bundle** in differential geometry. The topology
gives the skeleton; the predicates give the flesh.

The `abstract_tag` class in `tagd.h` encodes exactly this:

```cpp
class abstract_tag {
    tagd::rank    _rank;       // position in the base space
    predicate_set relations;   // fiber: additional data at this point
};
```

### 6.3 Relators are Tags

Crucially, relators are themselves tags — subordinate to `_rel` in the
tagspace tree. This means predicates are not outside the system; they are
*inside* it. The tagspace is self-describing. The language used to attach
meaning to tags is itself expressed in the same structural language.

From the bootstrap dump:
```
_rel     rank: 2        (root of all relators)
_has     rank: 2.1
_can     rank: 2.2
_refers  rank: 2.3
```

---

## 7. Structural Identity

### 7.1 Identity is Position

The deepest mathematical claim of the tagd system is that a tag's identity
is entirely structural. From `TAGL-spec.md`:

> **structural identity**: the identity of a tag defined by its subordinate
> relation (rank) and predicate_list.

A tag `dog` is not `dog` because of the string `"dog"`. It is `dog` because
of where it sits — under `mammal`, under `animal`, under `living_thing`,
under `_entity` — and because of what predicates are attached to it there.
Change the position (the subordinate relation), and you have a different
tag, regardless of the label.

This is **mathematical structuralism** applied to knowledge representation:
identity is relational, not intrinsic.

### 7.2 The Canonical Form

A tagspace can be fully serialized as TAGL text via `dump()`. This canonical
form is a complete description of the topological structure and all attached
predicates. It can be loaded to reconstruct the identical tagspace.

From `TAGL-Thesis.md`:
> The canonical form of a tagspace is its dump — the UTF-8 TAGL code that
> represents the tagspace (and can be loaded).

The dump is not a record of a structure. It *is* the structure, expressed
in TAGL. The tagspace is its own specification.

---

## 8. Summary of Mathematical Structures

The following table collects the mathematical structures identified in the
tagd source and maps them to their realizations in code and TAGL:

| Mathematical Structure | tagd Realization | Source |
|---|---|---|
| Set | All tags $T$ in a tagspace | `tagd.h: tag_set` |
| Rooted tree | Subordinate relations from `_entity` | `tagd-README.md` |
| Partial order (poset) | Rank prefix containership $\sqsubseteq$ | `rank.h: contains()` |
| Lexicographic total order | Rank byte string comparison | `rank.h: operator<` |
| Alexandrov topology | Upward-closed subtrees as open sets | `rank.h`, `tagd.cc` |
| Universal base subspace | Hard tag set $H$ | `hard-tags.h` |
| Fiber / attached structure | Predicate sets $P(t)$ at each tag | `tagd.h: predicate_set` |
| Continuous map | Order-preserving tagspace transformation | `tagd.cc: merge_containing_tags` |
| Canonical serialization | `dump()` in TAGL canonical form | `TAGL-spec.md` |

---

## 9. Conclusion

The tagd system is not merely a database or a knowledge graph. It is a
**topological space of structured meaning**. Tags are points. Subordinate
relations give the space its shape. Ranks encode that shape as a partial
order. The Alexandrov topology makes the shape mathematically precise.
Predicates attach additional structure at each point. And the hard tag base
ensures that every tagspace shares the same foundational geometry.

TAGL is the language for acting on this space: defining points, querying
regions, transforming structure. Every TAGL statement is a topological
operation.

The vision that *information is structural* — that meaning comes from shape,
not from labels — is not a design philosophy. It is a theorem about how the
system works.

---

## References

- `hard-tags.h` — hard tag definitions and axioms
- `rank.h` — rank structure, prefix order, `contains()`
- `tagd.h` — `abstract_tag`, `predicate_set`
- `tagd.cc` — `merge_containing_tags`, merge operations
- `TAGL-spec.md` — language specification and semantic model
- `tagd-README.md` — working examples and tutorial
- `bootstrap-dump-grid.txt` — concrete tagspace rank assignments

