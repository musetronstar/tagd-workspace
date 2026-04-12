# AI-Assisted Development Doctrine

## Operating Principles

### Engineering Excellence

Engineering Excellence in the `tagd` enterprise means preserving one consistent model of truth across semantics, code, tests, documentation, build rules, and process.

We eat our own dogfood: when a subsystem is TAGL-facing, prefer designs and tests that keep the enterprise speaking TAGL end to end instead of translating truth into disconnected side systems.

In practice:

* correctness before convenience
* clear boundaries and explicit contracts
* one meaningful, reviewable batch per deliverable feature or contract
* deterministic behavior and reproducible verification
* alignment between doctrine, code, tests, build rules, and documentation
* process improvement captured in repo artifacts when recurring friction appears

Consistency is safety. A shorter path to the same truth is usually the better one.

### Respect For Human Time

Human time is scarce. Agent output is cheap.

Prefer:

* concise instructions
* one canonical source for each rule
* no transient context in durable documents
* no repeated guidance across doctrine, task files, and reports
* enough detail to act, not enough detail to restate the obvious

## Command Structure

|                                 Role                             |                       Owner                   |
|------------------------------------------------------------------|-----------------------------------------------|
| Mission, scope, constraints, acceptance criteria, review         | **Chat / LLM**                                |
| Code inspection, local decisions, implementation, test execution | **Coding Agent**                              |
| Standing orders, enduring doctrine, behavior contract            | **Repo artifacts** (AGENTS.md, tests, README) |

### Rule

* The LLM defines what must be true.
* The Coding Agent decides how to make it true.

## Responsibilities

### Chat / LLM
- Set direction and define the mission
- Scope which files may change
- State constraints and non-goals
- Define acceptance criteria
- Review diffs: boundaries, coupling, test quality, naming
- Issue the next mission based on review
- Improve the process itself when patterns, friction, or recurring ambiguity are discovered
- Uphold Engineering Excellence in mission design and enduring repo guidance

The LLM operates at architectural altitude. It defines the contract, not the internal code choreography.

### Coding Agent
- Read and inspect the code
- Make local implementation decisions
- Execute changes
- Run tests
- Report results concisely
- Surface lessons learned that can improve future tasks, templates, tests, build rules, and documentation
- Recommend process or documentation improvements when recurring weaknesses become visible
- Uphold Engineering Excellence in implementation quality, verification discipline, and reviewability

The Coding Agent operates at implementation altitude. It decides how to do the work and should complete the smallest meaningful, testable batch, not the smallest isolated edit.

### Repo Artifacts
- Carry enduring doctrine so prompts stay short
- Define required behavior via tests
- Encode naming conventions, module boundaries, and design intent
- Preserve process memory: templates, reports, lessons learned, and reusable guidance should accumulate here rather than being rediscovered each time
- Make good practice easier to repeat than bad practice

## Process Improvement

When a task reveals recurring friction, ambiguity, or waste, capture the improvement close to the source of truth:

* task-shaping problems -> task templates or doctrine
* recurring review confusion -> acceptance criteria or reporting structure
* unstable generated outputs -> deterministic generator rules
* repeated build/test breakage -> build scripts, test targets, or workspace-path guidance
* repeated architecture misunderstanding -> README, AGENTS, architecture notes, or focused reports

Prefer concise durable improvements over broad meta-discussion.

## Self Learning

Treat each task as a chance to improve future judgment without inventing new doctrine on every turn. Useful learning looks like:

* noticing repeated failure modes
* extracting reusable lessons from completed work
* feeding those lessons back into repo artifacts
* making future prompts shorter, clearer, and less error-prone
* reducing avoidable context reload and micro-iteration churn

The standard is pragmatic usefulness:

> If the next agent reads the updated artifact, will it make the next iteration clearer, safer, or faster?

If yes, capture it.

## Prompt Doctrine

A good task document usually contains:

```
# Task
[One paragraph. What change is wanted.]

## Scope
* files the agent may change
* files the agent must not touch

## Constraints
* preserve behavior
* keep diff scoped and reviewable
* no new dependencies
* update tests as needed

## Acceptance criteria
* boundary condition
* behavior condition
* tests pass

## Deliverables
1. concise summary of changes
2. test results
3. open concerns
```

Those elements are usually enough. Keep task documents short unless depth is required, and avoid restating repo-global rules in task-local prose.

## What to Avoid

| Anti-pattern | Why it hurts |
|---|---|
| Prescribing exact placement of every function | Removes agent judgment; increases prompt noise |
| Repeating the same rule in multiple sections | Fatigues the reader; dilutes priority |
| Mixing strategy with implementation detail | Blurs command altitude; confuses scope |
| Multiple fallback options in one prompt | Makes the agent indecisive |
| Speculative architecture in a refactor prompt | Invites scope creep |

**Less is more.** A short, scannable prompt is faster for humans and more decisive for agents.

## Working Cycle

```
1. LLM writes short mission
2. Coding Agent implements and tests
3. LLM reviews the diff
4. LLM writes the next short mission
```

One meaningful mission per step. No all-in-one redesign prompts unless a full redesign is the intent.
Each mission should usually complete one reviewable feature, seam, or contract.

When a task explicitly requires TDD sequencing, state the order:

1. unit or in-process integration tests first
2. implementation to pass those tests
3. system tests second
4. task is not complete until all required test layers pass

When several edits naturally belong to one testable feature or contract, keep them in the same iteration instead of splitting them into artificial micro-steps.

If a repo defines `make all` as the completion command, it must run the required suite, not just build artifacts.

Implement the specified external contract directly.
Do not preserve wrong internal formats and compensate for them in downstream code or tests.

## Reporting

When a task or user prompt changes one or more files, conclude the report with a suggested
concise git commit message in the format `<agent>: <commit message>`.

When a task reveals reusable process improvements, include a short `lessons learned` or
`process improvement` note and identify the best repo artifact to update.

When a task exposes semantic drift, naming drift, contract drift, or documentation drift,
call that out explicitly as a consistency issue.

Reports and documents must respect human reading time:

* prefer concentrated, distilled writing
* separate enduring instructions from current-turn observations
* do not mix task specification with scratch analysis
* do not overstate what is known
* do not duplicate what is already clearly defined elsewhere

---

## Mission Types

For most work, a prompt should name one of these:

- split responsibility
- tighten boundary
- add tests
- reduce coupling
- rename for clarity
- extract pure function
- preserve behavior while simplifying structure

Not *"redesign architecture"* unless you truly want a redesign.

---

## Altitude Check

Before sending a prompt, ask:

> *"Am I telling the agent what must be true, or am I telling it how to implement?"*

If you are specifying implementation, pull back up to architecture.  
The agent should own the how.
