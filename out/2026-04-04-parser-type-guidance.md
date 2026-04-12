# TAGL Parser Type Guidance

## Context

The current TAGL Lemon grammar in `tagd/tagl/src/parser.y` uses a broad
ownership model:

* `%token_type {std::string *}`
* `%default_destructor { DELETE($$) }`

That shape has been convenient, but it blurs several different semantic roles
into one heap-owning pointer model. The recent parser teardown bugs suggest the
grammar is carrying more ownership ambiguity than Lemon expects.

This note captures lessons learned and a possible structure for the refactor.
It is guidance, not a mandate.

## Comparison Model

SQLite's Lemon grammar is a useful reference:

* `/home/inc/src/sqlite-src-3510300/src/parse.y`

Notable qualities in SQLite's grammar:

* many symbols have explicit `%type`s
* owning symbols have explicit `%destructor`s
* helper symbols often use small value types
* overwrite / transfer is documented explicitly
* grammar actions tend to assign LHS values intentionally

That is a better fit for Lemon than a single broad pointer type with a broad
default destructor.

## Observed TAGL Data Kinds

From `scanner.re.cc` and `parser.y`, TAGL appears to have a small number of
real semantic categories:

1. text-carrying labels and decoded token text
2. scalar values such as booleans and operators
3. helper / control-flow nonterminals with no meaningful semantic payload
4. possible future owning parser products such as tags, interrogators,
   referents, or relation objects

The current grammar mostly collapses categories 1 and 3 together.

## Suggested Type Structure

One possible structure for the TAGL parser is:

### Default helper type

Use a non-owning default type for symbols that are only parse structure:

```cpp
namespace TAGL {
struct NoValue {};
}
```

This may fit better as a `%default_type` than a heap-owning string pointer.

### Text-carrying value type

Introduce an explicit text carrier for identifiers, decoded strings, and
scanner-emitted text values:

```cpp
namespace TAGL {
struct TokenText {
	std::string text;
};
}
```

This gives text-bearing terminals and aliases a clear semantic type without
implying transfer of heap ownership at every grammar step.

### Scalar value types

Keep small scalar types explicit:

* `bool` for `boolean_value`
* `tagd::operator_t` for `op`

### Future owner types

If parser-side object construction later becomes desirable, true owners could be
introduced explicitly, for example:

* `tagd::abstract_tag *`
* `tagd::interrogator *`
* `tagd::referent *`
* a dedicated relation / predicate struct

That step does not appear necessary for the first cleanup pass.

## Suggested Symbol Grouping

### Text-carrying symbols

These look like natural candidates for a `TokenText`-like type:

* terminals:
  * `TAG`
  * `SUB_RELATOR`
  * `RELATOR`
  * `INTERROGATOR`
  * `REFERENT`
  * `REFERS`
  * `REFERS_TO`
  * `CONTEXT`
  * `FLAG`
  * `UNKNOWN`
  * `URL`
  * `HDURI`
  * `QUOTED_STR`
  * `TAGDURL`
  * `TAGL_FILE`
  * `MODIFIER`
  * `QUANTIFIER`
  * `INCLUDE`
* nonterminals:
  * `context`
  * `tagl_file`
  * `include`
  * `quoted_str`
  * `refers_to`
  * `refers_subject`
  * `refers_to_object`
  * `context_object`
  * `sub_relator_symbol`
  * `relator_symbol`
  * `lhs_object`
  * `rhs_object`

### Helper / no-value symbols

These appear to behave more like parse structure than semantic values:

* `start`
* `statement_list`
* `statement`
* `set_statement`
* `get_statement`
* `put_statement`
* `del_statement`
* `query_statement`
* `set_context`
* `set_flag`
* `set_include`
* `new_context`
* `context_list`
* `empty_context_list`
* `push_context`
* `subject_sub_relation`
* `del_subject_sub_err`
* `interrogator_query`
* `search_query`
* `tagdurl_query`
* `search_query_list`
* `search_query_quoted_str`
* `interrogator_sub_relation`
* `interrogator`
* `subject`
* `unknown`
* `referent_relation`
* `query_referent_relations`
* `query_referent_relation`
* `sub_relator`
* `super_object`
* `relations`
* `predicate_list`
* `relator`
* `object_list`
* `object`
* `modified_object`
* `bare_object`

These are the most likely places where the current default destructor model is
misleading.

## Refactor Direction

The recent fixes suggest a gradual path:

1. make helper symbols clearly non-owning
2. make text-carrying symbols explicit
3. keep scalar values explicit
4. reserve explicit destructors for true owners
5. remove `DELETE` / `MDELETE` once ownership is no longer encoded by broad
   default pointer semantics

This direction would move TAGL closer to Lemon's intended use, and closer to the
discipline visible in SQLite's grammar.

## Open Question

The main unresolved design input is semantic typing for TAGL-specific constructs:

* whether some parser products should remain driver side effects
* whether some should become first-class semantic values
* where future owning types should begin, if at all

If those TAGL semantic boundaries are unclear, clarification from the language
author is likely more valuable than guessing.
