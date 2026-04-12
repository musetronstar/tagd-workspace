# Task

Our lemon parser implementation in `tagd/tagl/src/parser.y` is a mess and is error prone in freeing tokens.

We need to refactor the TAGL parser. I want to first pull out any code that can be out of parser.y so that is is clean and minimal. The obvious target to put the code is `tagl.cc`, but it is already crowded. Propose other existing or new files to puth that code other that `tagl.cc` when appropriate.

## Task/Planning Files

Before we can finish this task:
* `TASKS.d/2026-04-04-tagdurl-refactor.md`

We must fix bugs:
* `TASKS.d/2026-04-04-parser-bugs.md`

But before fixing the bugs, we should refactor, consolodate and simplifly. Sometimes bugs just go away after a refactor.

During this refactor I want to **slice-and-dice** the current parser so that it is simplified and lean ane mean.

Claude helped assess Codex's performance. Take this report into consideration:
* `out/2026-04-04-codex-assessment.md`

## Lessons & Implications

The TAGL parser is currently using Lemon in a rough, overly broad ownership
style:

* `%token_type {std::string *}` is used broadly
* `%default_destructor { DELETE($$) }` is used broadly
* many nonterminals are really control-flow helpers with side effects on
  `tagl->tag_ptr()` rather than true semantic values
* manual `DELETE` / `MDELETE` calls are mixed with Lemon-owned destruction

This is not using Lemon effectively.

Use SQLite's Lemon grammar as a model for implementation:

* `/home/inc/src/sqlite-src-3510300/src/parse.y`

What SQLite does better:

* explicit `%type`s for many nonterminals
* explicit `%destructor`s for owning semantic values
* simple value types for helper symbols (`int`, `Token`, pointers to concrete
  AST nodes, etc.)
* explicit overwrite/transfer patterns (`/*A-overwrites-X*/`)
* grammar actions that assign LHS semantic values intentionally instead of
  relying on broad default pointer ownership

Implications for TAGL refactor:

1. shrink the use of `%default_destructor`
2. define explicit semantic types for helper nonterminals where possible
3. give side-effect-only helper nonterminals non-owning semantics
4. reserve explicit destructors for symbols that truly own heap values
5. remove `DELETE` / `MDELETE` only after ownership is made explicit enough for
   Lemon to clean up correctly

If TAGL semantic types are unclear, stop and ask for clarification rather than
guessing. The goal is to make the TAGL parser use Lemon effectively, not to
preserve an accidental ownership model.


### Task 1
* slice and dice `parser.y` to reduce and simplify 

### Task 2
* `TASKS.d/2026-04-04-parser-refactor.md`

## Scope

Files which can be changed:

`tagd/tagl/*`

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Design Principles

+ Interative & TDD - Think small
  1. Write test according to user requirements
  2. Implement code according to user desired change of behaviour or constrainsts
     Write deep code according to specification, not shallow code just to pass a test
  3. Pass test
  4. Report back to user
  5. Ask to proceed with next iteration (unless already instructino to proceed).
+ small pure functions
+ deterministic translation
+ composable pipeline
+ clear error behavior

## Constraints

+ preserve behavior
+ keep diff small
- no new dependencies
+ follow priority
  1. user prompts
  2. user specified task `.md` file
  3. `README.md` and `AGENTS.md`
  4. files references encountered when processing
     the files above should be folowed as needed

## Language & Style

* follow `STYLE.md`
* speak TAGL `TAGL-README.md`

## Tests

* update tests as needed
* modified code must be tested
* tests must pass before task is complete

## Acceptance criteria

* within set boundaries
* correct behavior
* tests pass

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns or interesting observations
