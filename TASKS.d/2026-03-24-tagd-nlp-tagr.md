# Task

Start eating our own dogfood and use `tagr-c++` in place of `tagr.py` in the
translation of VOA Word Book into TAGL.

## Priorities

1. Develop the TAGL language - increase its features so that much of the processing can be implemented in TAGL.
2. Develop `tagd-nlp` repository. We have a `tagd:nlp:treebank` tagspace, add more: starting with NLTK Treebank, then Universal Dependencies, etc.
3. Develop `tagr-c++` - increase its abilities to translate Natural Language into TAGL - low hanging fruit - use tagspaces: simple-english, tagd-nlp-treebank, Universal Dependencies, etc.

### Tranfer `tagr.py` to `tagr-c++`

Read the markdown files in `tagr/*.md` and `tagr/docs/*.md` from the context of a desire to develop Python NLP abilities directly into TAGL or `tagr-c++` modules: decomposing, refactoring, consolodating and improving 

## Scope

Do go to directories outside './' except the targets of these symlinks:

    tagd -> /home/inc/projects/tagd
    tagd-nlp -> /home/inc/projects/tagd-nlp
    tagd-simple-english -> /home/inc/projects/tagd-simple-english
    tagr -> ../tagr

Files/Directories which can be changed:

### Read/Write
`tagd/`
`tagd-nlp/`
`tagr/tagd-c++/`
`tagd-simple-english`
`tagr-workspace/`

### Access Denied

Permission must be granted for any other file/directory except expressed above.

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

* TDD write tests first
* modified code must be tested
* aim for high code coverage
* unit tests: (linked against [e.g. CXXTest]) develop by contract, exposing a unit-testable interface
* system tests: (I/O driven layer [e.g. TCL expect])
* tests must pass before task is complete

## Acceptance criteria

* within set boundaries
* correct behavior
* tests pass

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns or interesting observations

