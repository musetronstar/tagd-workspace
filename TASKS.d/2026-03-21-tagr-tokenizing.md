# tagr-c++ Scanner Tokenizer Tasks

Develop `tagr/tagr-c++` as a *tokenizer*:
+ use `tagd` logging facilities
+ use `tagd:error` reporting facilities
+ use a TAGL inspired/derived scanner
+ lookup tagd POS for tag-like patterns

## Task 1
* log emitted tokens / values to console

## Task 2
* print table of reverse freq count of tokens for an input stream
  Perhaps print from C++, but use bash to make the rev freq table

## Task 3
* construct trie of tokens and their
  + position within the input stream
  + scanner token (note the trie should be able to tell the value)

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

## Scope

Files/Dirs which can be changed:
`tagd-workspace/out`
`tagr/tagr-c++/`

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Constraints

* preserve behavior
* keep diff small
* no new dependencies
* follow priority
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
* behavior
* tests pass

## Deliverable: Concise Report

1. summary
2. test results
3. open issues, concerns or interesting observations

