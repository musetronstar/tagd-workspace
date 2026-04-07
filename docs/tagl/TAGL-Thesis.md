# TAGL Design Thesis

[Please check and proofread for correctness. I want to use specific language within the domain of computer science & language design.]

This is a design of the TAGL language as we wish it to be, not as it actually is now - we should mark features as DONE or some level of TODO.

This is a work in progress, everything is subject to change...

## Description
TAGL is a Touring complete functional-declarative language, so things like BITWISE operations will not be off limits. I want to use a "best of" from different languages as inspiration.  I need to put this altogether in a design document, where we can design the language TODOs even though its not yet implemented.

## Inspirations
But in short - the language features appear and  behave as:
* ERLange as default and fallback when unsure.
  + recursive functions - no loops
  + all variables and global and constant
  + selection done through pattern matching - no `if` statements 
  + but `tags` are the atoms of the system - where as ERLang atoms are but labels, tag are labels that also represent hierarchy and relation - not OOP, but adds a diminsion of heirachy and membership - tags can extend what ERLang has in atoms, by baking in "is a" and "has a" relations in a tag.
  + asyncronous functions are truly light weight threads - there can be tens of thousands easily. They act like processes where parameters are not "passed in" on the stack, but as TAGL through buffers. They are isolated in that they cannot do I/O except through buffers provided to them. Values are not returned, rather TAGL is written to the output buffer. They can be polled or instructed through signals. They can be local or remote - it doesn't matter. Upon error, they they emit their error TAGL to an error buffer and are killed and dropped from the internal/virtual process table.
* Set Theory and Mathematics
* C style operators for: logical, comparison, bitwise, mathematical, operations
* C++ scoping, closure, lambda and namspaces. `using` keyword
* Python style `**` exponentiation, sequence generality, slicing, comprehension, "dot method" chaining
* Perl style automatic `/regex/` patterns, capturing and binding
* JavaScript stye single threaded non-blocking asynchronous worker thread model.

That's not complete, but I want want to remain consistent with the meaning/behavior/usage of symbols in TAGL as they are in the languages it was inspired from.

## Workflow

We will follow the Joe Armstrong ERLange thesis: "Making reliable distributed systems in the presence of sodware errors"
https://erlang.org/download/armstrong_thesis_2003.pdf

Use his style, rigor and methodical approach to building the case for the language step by step, all supporting his thesis.

Moving, paragraph by paragraph, chapter by chapter, detailing the TAGL language in parallel to the Armstrong thesis. 

## Thesis Outline

I will provide the background and introduction of TAGL later, so lets jump forward to the ErLang Thesis section `1.2 Thesis outline` 

TASK: Provide a sparse/high level TAGL Thesis Outline - we can fill in detail later.

## Identity

The tagd system addresses two fundamental questions:

* What is it?
* How is it related?

These questions are resolved through a unified model:

* identity is defined by one heirarchical subordinate relation
* relations are defined by horizontal predicate relations

In tagd, meaning is derived structurally:

* a tag’s position in the hierarchy (given by its rank) establishes its identity within the tagspace
* predicate relations describe how the tag relates to other tags

TAGL provides a formal language for acting upon these structures. The canonical form of a tagspace is its dump - the UTF-8 TAGL code that repesents the tagspace (and can be loaded).

Imagine canonical tagspace dump on a large canvas where the TAGL text is printed in canonical form. TAGL opertions can be imagined as mechanical operations on paper:
* CMD_PUT: cut and insert a section
* CMD_GET: select and extract a section
* CMD_QUERY: scan for then select and extract matching sections
* CMD_DELETE: cut out a section

The tagd system provides a computing environment in which these structures can be:

* defined
* accessed
* queried
* compared
* serialized in canonical form (tagspace dump)

This approach enables knowledge representation that is:

* explicit
* deterministic
* inspectable

All semantics are encoded in the tagspace itself. No external schema or hidden interpretation layer is required.

