# AGENT TASKS

## Task: Refactor `tagl` Scanner Into A Modular re2c-Based Lexer Architecture

### Goal

Refactor [`tagl/src/scanner.re.cc`](/home/inc/projects/tagd/tagl/src/scanner.re.cc) into a modular lexer design that makes it straightforward to define, reuse, and extend re2c rule sets over time.

The refactor must make it easier to:

- introduce new token families without rewriting the core scanner
- reuse named re2c patterns such as `NAME = pattern`
- separate lexical rules from parser/driver side effects
- support multiple lexical states cleanly
- add future specialized re2c-driven scanners or rule groups using the same runtime conventions

This is a design and structure task. Focus on interface boundaries, file/module roles, invariants, and responsibilities. Do not treat this as a request to preserve the current monolithic layout.

## Scope

### Current Scanner Layout

* `tagl/src/scanner.re.cc`
* `tagl/include/tagl.h`
* `tagl/src/Makefile`

### Refactored Scanner Layout

* `tagl/src/scanner.re.cc`
   + re2c scanner for TAGL language input
   + emits parser tokens
   + no function defs
   + any processing blocks, put in function, move to `scanner.cc`
   + TODO: output to file named `scanner.out.cc`
   + TODO: put the `/*!re2c` block of named re patterns into `scanner.h` if possible - make them reusable
   + TODO: put macros and function in to `scanner.h` and `scanner.cc`
* `tagl/src/tagdurl.re.cc`
   + re2c scanner for a **tagdurl** as input
   + emit parser tokens
   + emits same tokens as `scanner.re.cc`
   + TODO: output to file named `scanner.tagdurl.cc`
* `tagl/include/scanner.h` 
* `tagl/src/scanner.cc`
   + `scanner.h` funtions implemented in `scanner.cc`
   + function with good names
   + reuasble blocks of code useful for any scanner
* `tagl/include/tagl.h`
* `tagl/src/Makefile`


The parser contract in `tagl/src/parser.y` must be respected, but the refactor plan should reduce direct coupling between lexer rules and parser-facing actions.

## Required Outcomes

The refactored design must provide:

1. A clear separation between scanner runtime mechanics and lexical rule definitions.
2. A place for shared named re2c patterns that can be reused across rule groups and future scanners.
3. A stable abstraction for token emission that avoids scattering parser-driver calls through re2c actions.
4. A clean strategy for multiple lexical states such as normal scanning, line comments, block comments, and quoted strings.
5. A structure that allows future re2c-generated functionality beyond the current scanner without copying the existing file pattern.

But most importantly - pass the tests of the current design. Refactor the code, but the external TAGL drivers and parsers work the same.

## Design Requirements

### 1. Separate Runtime From Rules

The scanner architecture must distinguish between:

- multithreaded-concurrent usage - each user provides const input chars or evbuffer
- each thread owns its own const input buffers scanner 
- scanners own the refill and manage their own internal buffers

The runtime layer `tagl.cc`, `scanner.cc` should define scanner state, helper operations, and scanner invariants.
The re2c layer should primarily describe lexical patterns and state transitions - reusing as much from `scanner.h` as possible

### 2. Introduce Shared Pattern Definitions

The design must include a dedicated place for reusable named re2c definitions.

Examples of pattern categories that should be reusable:

- whitespace and newline forms
- identifier-like tokens
- URI and URL forms
- file-name forms
- quoted-string fragments
- punctuation classes

The intention is that future scanners or rule groups can consume the same definitions without copying and modifying large inlined blocks.

### 3. Define A Token Emission Boundary

The plan must introduce a clear interface between lexical matching and downstream parsing.

That interface should make it possible to reason independently about:

- what was matched
- whether a value is attached
- whether keyword lookup is required
- whether token classification is direct or context-sensitive
- what source location metadata is preserved

The scanner rules should not be responsible for orchestrating parser policy - just scan, (lookup if desired) and emit tokens

### 4. Model Lexical States Explicitly

The plan must specify a first-class strategy for lexical states.

At minimum, the design must account for:

- default token scanning
- line comment scanning
- block comment scanning
- quoted string scanning

State transitions should be visible in the design and should not depend on large cross-cutting goto-style control flow being spread across unrelated rule sections.

### 5. Support Incremental Input

The current scanner handles streamed input via `evbuffer`. The refactor plan must preserve support for:

- bounded internal buffering
- refill-driven scanning
- correct token continuation across buffer boundaries
- correct handling of partial quoted strings or partial tokens

Any modularization must keep streaming input as a supported mode, not a secondary afterthought.

### 6. Preserve Observable Behavior

The design must preserve the current external scanner behavior unless an explicit follow-up task changes it.

That includes:

- token categories
- statement termination behavior
- comment handling
- quoted string behavior
- URI, URL, and file token treatment
- line number reporting
- parser compatibility

Behavioral cleanup may be identified separately, but this plan is for modularization first.

## Recommended Module Structure

## Reuse Requirements For Future re2c Functions

The modular design must make it easy to add future re2c-based functionality that is not limited to the current scanner.

The plan should support future components that may need:

- shared named patterns
- a standard scanner state model
- reusable input-buffer conventions
- reusable token or span representations
- consistent error reporting and source-location handling

The architecture should treat the current scanner as one consumer of a reusable lexer foundation, not as a one-off special case.

## Interface Requirements

The plan should make recommendations as to how well are we doing and how to improve regarding:

- scanner state reset and initialization
- input source attachment
- token production
- matched-value access
- line-number access
- error propagation
- end-of-input handling

These interfaces should be defined in terms of responsibilities and observable behavior, not implementation detail.

## Testing Requirements

The refactor plan must require regression coverage for all existing `tagl`, `tagsh` and `httagd` tests

- tokenization equivalence on existing inputs
- comment state transitions
- quoted string handling
- stream refill boundaries
- line-number accounting
- keyword lookup classification
- URI and file token recognition

The plan should assume that scanner modularization is incomplete until those behaviors are verified.

## Non-Goals

This task is not about:

DO NOT:
- changing the TAGL language grammar
- redesigning parser semantics
- changing token names
- optimizing for micro-performance before structure is improved
- prescribing exact implementation code
- remove user comments - they are documentation
- change files other that those listed in **Refactored Scanner Layout**

## Deliverable

Produce a refactor plan and outline that:

- defines target module boundaries
- describes responsibilities for each module
- specifies the contracts between lexer runtime, re2c rules, and parser integration
- identifies behavior that must remain unchanged
- explains how shared `re NAME = pattern` definitions will be organized and reused

The deliverable should be a design specification for modularizing the scanner, not a step-by-step code recipe.
