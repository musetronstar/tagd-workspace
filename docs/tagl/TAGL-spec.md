# TAGL Specification

## 1. Introduction

### 1.1 Purpose

TAGL is a semantic-relational language for defining and querying knowledge as
a tagspace, a hierarchical structure of tags connected by predicates.

TAGL expresses:
* identity via subordinate relations
* meaning via predicates
* knowledge as a tree-structured graph

### 1.2 Scope

This specification defines:

* lexical structure (tokens)
* grammar (syntax)
* semantic model
* evaluation rules
* statements

### 1.3 Non-Goals

This specification does NOT define:

* storage implementation (`tagdb`)
* transport protocols (`httagd`)
* natural language translation (e.g. `tagr`)

## 2. Conventions and Terminology

### 2.1 Normative Keywords

* MUST
* MUST NOT
* SHOULD
* MAY

### 2.2 Definitions

* tag: a semantic-relational entity identified nominally by a globally unique
  UTF-8 text label and structurally by its subordinate relation within a
  tagspace

* tagspace: a tree of tags defined using subordinate relations
  (aka identity relations). Tags derive their structural identity through their
  position in the tree hierarchy

* subject: the tag for which a subordinate relation defines identity and to
  which zero or more predicates are applied

* object: a tag that is related to a subject by a relator which MAY bind to a
  optional modifier using an operator.

* modifier: a UTF-8 byte string value bound to an object.
  A NULL value indicates a bare object with no modifier

* quantifier: a numeric modifier (CURRENT: number stored as UTF-8 text)

* object_list: one or more objects

* sub_relator: a specific object in an *identity relation* that
  cannot be modified

* super_object: the object of a tag’s *identity relation*, to which the
  subject is subordinate

* relator: a tag that relates a subject to an object_list

* predicate: a relation of `[relator + object_list]` applied to a subject

* predicate_list: a relator and its associated object_list

* relation: a `[relator + object]` or a `[sub_relator + super_object]`
  applied to a subject

* identity relation: (aka subordinate relation,  sub relation): a relation
  formed by a `[sub_relator + super_object]` that determines the rank of a
  tag (directly under the super_object) and which provides structural identity

* nominal identity: the identity of a tag defined by its globally unique
  UTF-8 label

* structural identity: the identity of a tag defined by its subordinate
  relation (rank) and predicate_list

Notes:
A predicate is formed when a relator is followed by an object_list.  
A relator alone is not a predicate.

## 3. Core Model

### 3.1 Tag

All tokens in TAGL are UTF-8 labels.

### 3.2 Tagspace

A tagspace is a hierarchical structure defined by subordinate relations.

* Root tag: `_entity`
* `_entity _sub _entity` is axiomatic

### 3.3 Identity (Sub Relations)

A tag’s identity is defined by a sub relation.

```tagl
>> dog _is_a mammal
```

Rules:

* A subject MUST have a sub relation to exist in the tagspace
* The object of a sub relation MUST exist
* A subject MUST have a subordinate relation to exist in the tagspace
* For a given tag id, there MUST exist exactly one subordinate relation
* The object of a subordinate relation MUST exist

### 3.4 Predicates

Predicates define relations about a subject.

A predicate consists of a relator followed by an object_list.

A relator MUST be a tag subordinate to `_rel` (`POS_RELATOR`).

A relator alone is not a predicate.

```tagl
>> dog _has legs = 4;
```

Note: The `object = modifier` (`legs = 4`) also operates like a `key = value` or `attribute = property`)

## 4. Lexical Structure

### 4.1 Commands

* `>>` PUT
* `<<` GET
* `!!` DELETE
* `??` QUERY
* `%%` SET

### 4.2 Operators

* `-^` maps to `_sub`
* `->` maps to `_rel`
* `=` assignment
* `,` separator
* `*` wildcard

### 4.3 Literals

* TAG: UTF-8 label
* QUANTIFIER: numeric
* STRING: quoted

### 4.4 Comments

```tagl
-- line comment
-* block comment *-
```

## 5. Syntax

### Statements

#### Statement Termination

A statement MUST be terminated by a terminator.

A terminator MUST be one of:

* a semicolon (`;`)
* a double newline (`"\n\n"`)

The scanner MUST emit a terminator token for either form.

Canonical form:

The `tagspace` `dump()` method outputs the TAGL text of a tagspace in canonical form. 

* A statement MUST be terminated by a double newline
* A semicolon MUST NOT be used when the following line is empty
* A semicolon MUST be used when statements are written on consecutive non-empty lines

#### 5.1 Statement Types

* PUT
* GET
* DELETE
* QUERY
* SET

#### 5.2 PUT Grammar

```bnf
put_statement ::= ">>" subject_sub_relation predicates
put_statement ::= ">>" subject_sub_relation
put_statement ::= ">>" subject predicates

subject_sub_relation ::= subject sub_symbol TAG

subject ::= TAG

predicates ::= predicates predicate_list
predicates ::= predicate_list

predicate_list ::= relator object_list

object_list ::= object_list ',' object
object_list ::= object

object ::= TAG
object ::= TAG "=" QUANTIFIER
object ::= TAG "=" STRING
```

#### 5.3 GET Grammar

```bnf
get_statement ::= "<<" subject
```

#### 5.4 DELETE Grammar

* Same as PUT
* MUST NOT include sub relation

#### 5.5 QUERY Grammar

```bnf
query_statement ::= "??" interrogator predicates
query_statement ::= "??" "<search terms>"
```

## 6. Semantic Model

### 6.1 Evaluation

TAGL statements are evaluated against a tagspace.

* PUT
  + define predicates
  + mutate predicates
* GET
  + retrieve definition
* DELETE
  - remove predicates
  - remove tags
* QUERY
  + retrieve matching subjects

### 6.2 Identity Constraints

* A tag MUST be introduced via a sub relation
* Sub relation object MUST exist

### 6.3 Predicates

* A subject MAY have multiple predicates
* Each predicate consists of:
  + a relator
  + an object_list

## 7. Hard Tags

Core:
* `_entity`
* `_sub`
* `_rel`

## 8. Query Semantics

* Queries traverse sub relations
* `*` matches any predicate

## 9. Context and Referents

```tagl
%% _context example;
```

## 10. URLs

* URLs are valid TAGL tokens

## 11. Errors

* Errors are represented as tags

## 12. Examples

```tagl
>> mammal _type_of animal;
>> dog _is_a mammal;
```

## 13. Implementation Notes (Non-Normative)

* Scanner: `re2c`
* Parser: `lemon`

## 14. Future Work

* formal EBNF grammar
* contradiction handling
* revision model

## 15. References

* `README.md`
* `hard-tags.h`
* `scanner.h`
