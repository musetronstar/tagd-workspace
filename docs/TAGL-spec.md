# TAGL Specification
## TAGL-spec.md (Draft v0.3)

---

## 1. Introduction

### 1.1 Purpose

TAGL is a semantic-relational language for defining and querying knowledge as a tagspace, a hierarchical structure of tags connected by predicates.

TAGL expresses:
- identity via subordinate relations
- meaning via predicates
- knowledge as a tree-structured graph

---

### 1.2 Scope

This specification defines:

- lexical structure (tokens)
- grammar (syntax)
- semantic model
- evaluation rules
- statement types

---

### 1.3 Non-Goals

This specification does NOT define:

- storage implementation (tagdb)
- transport protocols (httagd)
- natural language translation (e.g. tagr)

---

## 2. Conventions and Terminology

### 2.1 Normative Keywords

- MUST
- MUST NOT
- SHOULD
- MAY

---

### 2.2 Definitions

- tag: UTF-8 semantic identifier  
- tagspace: tree of tags defined by sub relations  

- subject: primary tag in a statement  
- object: target of a relation  

- relator: a tag that relates a subject to one or more objects  

- predicate: a relator with an object_list  

A predicate is formed when a relator is followed by an object_list.  
A relator alone is not a predicate.

---

## 3. Core Model

### 3.1 Tag

All tokens in TAGL are UTF-8 labels.

---

### 3.2 Tagspace

A tagspace is a hierarchical structure defined by subordinate relations.

- Root tag: `_entity`
- `_entity _sub _entity` is axiomatic

---

### 3.3 Identity (Sub Relations)

A tag’s identity is defined by a sub relation.

Example:

>> dog _is_a mammal;

Rules:
- A subject MUST have a sub relation to exist in the tagspace
- The object of a sub relation MUST exist

---

### 3.4 Predicates

Predicates define statements about a subject.

A predicate consists of a relator followed by an object_list.

Example:

>> dog _has legs = 4;

---

## 4. Lexical Structure

### 4.1 Commands

| Token | Meaning |
|------|--------|
| `>>` | PUT |
| `<<` | GET |
| `!!` | DELETE |
| `??` | QUERY |
| `%%` | SET |

---

### 4.2 Operators

- `-^` → `_sub`
- `->` → `_rel`
- `=` assignment
- `,` separator
- `*` wildcard

---

### 4.3 Literals

- TAG: UTF-8 label
- QUANTIFIER: numeric
- STRING: quoted

---

### 4.4 Comments

-- line comment  
-* block comment *-

---

## 5. Syntax

### 5.1 Statement Types

- PUT
- GET
- DELETE
- QUERY
- SET

---

### 5.2 PUT Grammar

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

---

### 5.3 GET Grammar

get_statement ::= "<<" subject

---

### 5.4 DELETE Grammar

Same as PUT, but MUST NOT include sub relation

---

### 5.5 QUERY Grammar

query_statement ::= "??" interrogator predicates  
query_statement ::= "??" "<search terms>"

---

## 6. Semantic Model

### 6.1 Evaluation

TAGL statements are evaluated against a tagspace.

- PUT → define or mutate predicates
- GET → retrieve definition
- DELETE → remove predicates or tags
- QUERY → retrieve matching subjects

---

### 6.2 Identity Constraints

- A tag MUST be introduced via a sub relation
- Sub relation object MUST exist

---

### 6.3 Predicates

- A subject MAY have multiple predicates
- Each predicate consists of a relator and object_list

---

## 7. Hard Tags

Core:
- `_entity`
- `_sub`
- `_rel`

---

## 8. Query Semantics

- Queries traverse sub relations
- `*` matches any predicate

---

## 9. Context and Referents

%% _context example;

---

## 10. URLs

URLs are valid TAGL tokens.

---

## 11. Errors

Errors are represented as tags.

---

## 12. Examples

>> mammal _type_of animal;  
>> dog _is_a mammal;  

---

## 13. Implementation Notes (Non-Normative)

- Scanner: re2c  
- Parser: lemon  

---

## 14. Future Work

- formal EBNF grammar
- contradiction handling
- revision model

---

## 15. References

- tagd README  
- hard-tags.h  
- scanner rules  
