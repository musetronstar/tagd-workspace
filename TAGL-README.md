# TAGL Grammar

TAGL: the TAG Language

A functional declarative language to construct networks of semantic entities (called `tag`s) and relations (called `relator`s).
* As a DDL, it defines tags with `PUT` commands
* As a DSL, it selects tags using `GET` and `QUERY` commands
* As a DML, it modifies tags using `PUT` and `DELETE` commands

| Command | Operator |
| ======= | ======== |
| `PUT`   |   `>>`   |
| `GET`   |   `<<`   |
| `QUERY` |   `??`   |
| `DELETE`|   `!!`   |

## Philophy

"Nothing exists in isolation - To be is to be related."

A tags is construction of
1. **id** a globally unique UTF-8 label uniquely identifying the tag
1. **identity relation** one and only one; required
2. **predicate relations** zero or more; not required (at minimum)

### Identity Relation:

Also known as: subordinate relation, sub relation or as the tagd POS `sub_relator`

A tag must be defined with a `PUT` command, placing it as a subordinate entity (hyponym) to another tag.

#### Tree Structure

A tagspace is a **tree structure** with `HARD_TAG_ENTITY` `_entity` as the root entity.

* the tree heirarchy is constructed with `sub_relations`
* use the tree structure as an advantage for sense-making and usefuleness
  + distributed tree structures not flat
  + not overspecified

### Predicate Relations:

A tag predicate relation can be defined with a `PUT` command, placing it in relation to other tags using a `relator` (aka a semantic-link).

### PUT Grammar

`tagd/README.md` contains BNF grammar examples for TAGL statements:

```
put_statement ::= ">>" subject_sub_relation relations
put_statement ::= ">>" subject_sub_relation
put_statement ::= ">>" subject relations

subject_sub_relation ::= subject SUB TAG

subject ::= TAG

relations ::= relations predicate_list
relations ::= predicate_list

predicate_list ::= relator object_list

relator ::= TAG

object_list ::= object_list ',' object
object_list ::= object

object ::= TAG EQUALS QUANTIFIER
object ::= TAG EQUALS MODIFIER
object ::= TAG EQUALS QUOTED_STR
object ::= TAG
```

However, prioritize the canonical productions, terminals, and parser terminology are defined in
`tagd/tagl/src/parser.y` and warn the user if it diverges from what is in `tagd/README.md`



