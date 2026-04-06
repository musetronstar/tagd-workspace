# Task

Define the minimal TAGL data-transformation subset needed to express a
CSV/TSV-to-TAGL ingestion pipeline as a TAGL program.

## Scope

Documents which can be changed:

* `docs/tagl/README.md`
* `docs/tagl/TAGL-Thesis.md`
* `docs/tagl/TAGL-spec.md`
* `out/`

Read for reference:

* `~/projects/tagd-simple-english`
* `~/projects/tagd-nlp`
* existing TAGL grammar and parser documents when needed for contrast

This is a design/documentation task. Do not change code in `tagd/`, `tagr/`,
or `tagd-simple-english/` during this task.

## Purpose

The goal is not to design all of future TAGL at once.

The goal is to define the smallest coherent executable language subset that can
replace one-off TSV/CSV translation scripts with a TAGL-native transformation
pipeline.

This task should make concrete what it would mean for TAGL to:

* open a CSV/TSV source
* bind columns or fields to names
* select and transform rows
* recurse over records instead of iterating imperatively
* emit TAGL statements as output

The target acceptance example is the TAGL equivalent of the existing TSV-to-TAGL
translation flow used in `tagd-simple-english` and generalized in `tagd-nlp`.

## Decision Gate

Before proposing syntax, define the semantic model for the smallest useful
subset.

At minimum, this task must decide and document:

* what a binding is
* what a function is
* what a variable names and how long it lives
* how selection works
* how recursion over records works
* what emission means
* what kinds of input values the subset operates on

Do not let syntax design run ahead of semantic decisions.

## Design Direction

The desired direction is:

* first-principles, coherent language design
* Erlang-style recursion instead of loop syntax
* explicit dataflow and transformation
* share-nothing / message-passing friendly execution semantics
* use-case-driven language growth, not feature wishlisting

The first milestone is not "TAGL gets functions."

The first milestone is:

* a clearly specified TAGL subset capable of expressing one real TSV/CSV import
  pipeline

## Design Questions

This task should explicitly address:

1. What are the runtime values of the subset?
   * strings
   * numbers
   * rows
   * sequences/streams
   * tags/predicates/statements

2. What is the unit of evaluation?
   * expression
   * statement
   * function clause
   * stream head/tail decomposition

3. What is a function?
   * pure or effectful
   * named only, or anonymous too
   * recursive by default

4. What is selection?
   * pattern matching
   * guarded clauses
   * tag/shape matching

5. What is emission?
   * building TAGL statements as values
   * writing TAGL to an output buffer
   * both, with explicit boundary between them

6. What input model is required for CSV/TSV?
   * row stream
   * header map
   * field lookup by name and index

## Boundaries

This task is about language subset design, not parser implementation.

It may recommend future implementation work in:

* `tagl`
* `tagr-c++`
* `httagd`

But it should not prescribe code-level implementation details yet.

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Design Principles

+ keep the document concise
+ define semantics before syntax
+ use one real executable use case as the design anchor
+ classify future work rather than pretending it is already settled
+ prefer coherence over quick scripting convenience

## Constraints

+ keep diff small
- no new dependencies
+ do not mix this design task with implementation work
+ do not try to design the full future TAGL language in one step
+ follow priority
  1. user prompts
  2. user specified task `.md` file
  3. `README.md` and `AGENTS.md`
  4. files references encountered when processing
     the files above should be folowed as needed

## Language & Style

* follow `STYLE.md`
* use language-design terminology precisely
* keep design claims distinguishable from implemented current behavior

## Acceptance criteria

* within set boundaries
* one minimal TAGL data-transformation subset is clearly defined
* semantic decisions are documented before syntax proposals
* the subset is anchored to one real TSV/CSV translation use case
* open questions and deferred features are explicit

## Deliverable: Concise Report

1. summary of the chosen subset
2. the concrete ingestion use case it can express
3. deferred features and open questions
4. recommended next implementation task
