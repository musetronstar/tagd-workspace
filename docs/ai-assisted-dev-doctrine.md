# AI-Assisted Development Doctrine

## Operating Principles

### Engineering Excellence

Engineering Excellence is a core operating principle in everything we do.

**We eat our own dogfood.**

**Dogfooding is an operating principle: we build the tagd enterprise by speaking TAGL ourselves.**

**Engineering Excellence in the `tagd` enterprise means speaking TAGL end-to-end and preserving one consistent model of truth across the entire system: input in TAGL, processing in TAGL, output in TAGL, errors in TAGL, logs in TAGL, web-service mappings in TAGL, and eventually apps generated from TAGL.**

**Consistency is safety. Consistency is correctness. Consistency is how truth survives across semantics, ontology, code, data, tests, documentation, and process.**

It means:

* correctness before convenience
* clear boundaries and explicit contracts
* meaningful, reviewable batches organized around one deliverable feature or contract
* deterministic behavior and reproducible verification
* strong alignment between doctrine, code, tests, build rules, and documentation
* process improvement as part of delivery, not a separate activity
* semantic, ontological, and system consistency across the enterprise
* using TAGL as the native language of the enterprise rather than translating truth into disconnected side systems

Engineering Excellence is not polish for its own sake.
It is disciplined, pragmatic software engineering that improves the system and the way we work on the system.

### Respect For Human Time

Human time is scarce. Agent output is cheap. The burden is on the agent to spend more machine effort so the human spends less life parsing noise.

This means:

* concise by default
* dense with signal, not padded with repetition
* no transient context embedded into durable documents
* no restating canonical instructions owned by another source document
* no speculative detail when the task only needs requirements, verification, and acceptance
* enough detail when needed, but never more than needed

If a document can be made shorter without losing truth, clarity, or utility, it should be made shorter.

## Command Structure

|                                 Role                             |                       Owner                   |
|------------------------------------------------------------------|-----------------------------------------------|
| Mission, scope, constraints, acceptance criteria, review         | **Chat / LLM**                                |
| Code inspection, local decisions, implementation, test execution | **Coding Agent**                              |
| Standing orders, enduring doctrine, behavior contract            | **Repo artifacts** (AGENTS.md, tests, README) |

### Rule

* The LLM defines what must be true.
* The Coding Agent decides how to make it true.

---

## Responsibilities

### Chat / LLM
- Set direction and define the mission
- Scope which files may change
- State constraints and non-goals
- Define acceptance criteria
- Review diffs: boundaries, coupling, test quality, naming
- Issue the next mission based on review
- Improve the process itself when patterns, friction, or recurring ambiguity are discovered
- Uphold Engineering Excellence at the level of mission design, review quality, and enduring repo guidance

The LLM operates at **architectural altitude**.  
It should not choreograph internal code moves unless correcting a specific known mistake.

### Coding Agent
- Read and inspect the code
- Make local implementation decisions
- Execute changes
- Run tests
- Report results concisely
- Surface lessons learned that can improve future tasks, templates, tests, build rules, and documentation
- Recommend process or documentation improvements when recurring weaknesses become visible
- Uphold Engineering Excellence in implementation quality, verification discipline, and reviewability

The Coding Agent operates at **implementation altitude**.  
It should decide *how* to do the work within the given boundaries.
It should complete the smallest meaningful, testable batch, not the smallest isolated edit.

### Repo Artifacts
- Carry enduring doctrine so prompts stay short
- Define required behavior via tests
- Encode naming conventions, module boundaries, and design intent
- Preserve process memory: templates, reports, lessons learned, and reusable guidance should accumulate here rather than being rediscovered each time
- Serve Engineering Excellence by making good practice easier to repeat than bad practice
- Help the enterprise keep speaking one language of truth instead of fragmenting across code, tools, and documentation

---

## Process Improvement

Good task execution should improve not only the code, but also the way the team works.

When a task reveals recurring friction, ambiguity, or waste, capture the improvement close to the source of truth:

* task-shaping problems -> task templates or doctrine
* recurring review confusion -> acceptance criteria or reporting structure
* unstable generated outputs -> deterministic generator rules
* repeated build/test breakage -> build scripts, test targets, or workspace-path guidance
* repeated architecture misunderstanding -> README, AGENTS, architecture notes, or focused reports

Prefer concise durable process improvements over broad meta-discussion.

Engineering Excellence applies here too:
delivery is not complete when the code change lands but the same avoidable confusion remains in the workflow.
If we keep rediscovering the same truth instead of capturing it once in TAGL, tests, templates, or doctrine, we are not yet operating with Engineering Excellence.

If a process improvement is proposed, it should be:

* grounded in evidence from the current work
* written as a reusable rule, template improvement, or documentation addendum
* kept separate from speculative organizational philosophy

---

## Self Learning

Agents should treat each task as a chance to improve future judgment.

This does not mean inventing new doctrine on every turn. It means:

* noticing repeated failure modes
* extracting reusable lessons from completed work
* feeding those lessons back into repo artifacts
* making future prompts shorter, clearer, and less error-prone
* reducing avoidable context reload and micro-iteration churn

Useful self-learning outputs include:

* improved task templates
* sharper acceptance criteria
* better test expectations
* clearer archive classifications
* more precise terminology for recurring engineering concepts
* better alignment between TAGL, code structure, logs, errors, and documentation

The standard for self-learning is pragmatic usefulness:

> If the next agent reads the updated artifact, will it make the next iteration clearer, safer, or faster?

If yes, the learning is worth capturing.

That is Engineering Excellence expressed as organizational memory.

---

## Prompt Doctrine

A good Coding Agent prompt usually contains a small set of core elements:

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
* follow AGENTS.md
* follow interruptions introduced by user
  + comments or deleted code become design imperatives or contracts
  - do not fix broken code by reverse breaking changes introduced by user
  + do fix broken code by TDD (design by contract):
    1) write test according to new suggested change to design or behavior
    2) redesign/refactor around new tests and breaking changes
    3) pass tests according to new design/behaviour
* update tests as needed


### Interruptions by User
  + user comments or deleted code become design imperatives or contracts
  - do not fix broken code by reverse breaking changes introduced by user
  + do fix broken code by TDD (design by contract):
    1) write test according to new suggested change to design or behavior
    2) redesign/refactor around new tests and breaking changes
    3) pass tests according to new design/behaviour

## Acceptance criteria
* boundary condition
* behavior condition
* tests pass

## Deliverables
1. concise summary of changes
2. test results
3. open concerns
```

Those elements are usually enough.

Keep prompts and task documents short unless depth is truly required.
Do not dump gathered context into a durable artifact just because it is available.
Reference source documents; do not cheaply paraphrase them into longer, weaker copies.
Specify one meaningful deliverable feature or contract per iteration.
Prefer the smallest batch that completes and proves that deliverable, even when it requires several naturally related edits.
Do not bias toward micro-iterations that fragment one coherent change across multiple turns.

For the `tagd` enterprise, a good prompt should also preserve one more invariant:

* the task should strengthen, or at least not weaken, the consistent TAGL-centered model of truth across the stack

---

## What to Avoid

| Anti-pattern | Why it hurts |
|---|---|
| Prescribing exact placement of every function | Removes agent judgment; increases prompt noise |
| Repeating the same rule in multiple sections | Fatigues the reader; dilutes priority |
| Mixing strategy with implementation detail | Blurs command altitude; confuses scope |
| Multiple fallback options in one prompt | Makes the agent indecisive |
| Speculative architecture in a refactor prompt | Invites scope creep |

**Less is more.** A short, scannable prompt is faster for humans and more decisive for agents.

---

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

If a repo defines `make all` as the completion command, `make all` must run the
full required suite, not just build artifacts.

Prefer repo-owned local fixtures for normal tests over external mutable data
files. Use external files only for explicit integration coverage.

Prefer solutions that keep the enterprise speaking TAGL directly over solutions
that introduce parallel ad hoc representations without necessity.

Mark aggregate make targets like `all`, `tests`, and `clean` as `.PHONY`.

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
