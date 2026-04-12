# tagd Agent Workspace

## Git Worktrees

This repository contains git worktrees for:

* `tagd/` tagd semantic-relational database and TAGL languge
* `tagd-simple-english/` VOA Wordbook Simple English dictionary to be translated into TAGL and httagd web app
* `tagr/` natural language to TAGL translator

## TAGL

Understand the current TAGL language in the `tagd` sources.

### Integrity & Consistency

The most important thing is that all language and rules used our generated
documents are derived solely from the tagd repository source (documents + code),
ordered by **dependency order** and used consistently.
Our documents must mirror the source precisely.

DO NOT INNOVATE - follow the source.

#### Dependency Order

Here is the epistemological dependency order of our system:

1. tagd/tagd/include/tagd/hard-tags.h  hard tag definitions - the axioms
2. tagd/tagd/include/tagd/codes.h      named constants
3. tagd/tagd/include/tagd.h            system primitives
4. tagd/tagd/src/tagd.cc               primitives structures and algorithms
5. tagd/tagd/include/tagd/rank.h       heirarchy and membership (containership)
6. tagd/tagl/src/tagdurl.re.cc         types and tokens according to lexical patterns
7. tagd/tagl/src/parser.y              TAGL grammar
8. tagd/README.md                      Best description and working examples of TAGL we have

Report any inconsistencies in the source first and foremost.

Then, strive to adhere to consistent usage of terms and relations with
intregrity as they are actually defined in the source.

## Definitions

tagd: the tagd semantic-relational system
TAGL: the tag language - defines tags and tagspaces
tagspace: a tagd semantic-relational database using TAGL
TAGLize: to translate (or tranform) input into TAGL

## Goals

TAGLize various forms of input and construct meaninful tagspaces.

## Tasks

Task `.md` files are stored in `TASKS.d`.
Only follow the task specified in the user prompt.

## Workflow

### One small step at a time

Do not make sweeping changes. Each edit should do exactly one thing.
Break large tasks into small steps and iterate.

Prefer the smallest change possible:

When writing code:
* write the test first
* make the minimal code change to pass it
* build and test after each step

When writing documentation:
* write the verification first (how do we know its correct?)
* make the minimal change that completes the task 
* verify consistency and integrity

### Preserve the author's style

When editing existing code:
* do not reformat lines that do not need changing
* do not change whitespace, indentation, or brace style on untouched lines
* do not alter comments unless explicitly asked
* do not remove commented-out code blocks without being explicitly asked

Comments and TODOs are design intent, not clutter.

### Minimal diffs

Produce the smallest possible diff that achieves the goal.
If a line does not need to change to make the feature work, do not touch it.

Assume the author may review changes with `git diff` and will care about
unnecessary edits.

### Reviewability

For non-trivial changes, prefer a patch the author can review rather than a
large rewrite.

### Verification

Build and test (or verify) after every change.
Before reporting success, make sure the current step is complete and verified while preserving system consistency and integrity.
