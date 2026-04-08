# AI-Assisted Development Doctrine

## Operating Principles

### Engineering Excellence

Engineering Excellence is a core operating principle in everything we do.

It means:

* correctness before convenience
* clear boundaries and explicit contracts
* small reviewable changes
* deterministic behavior and reproducible verification
* strong alignment between doctrine, code, tests, build rules, and documentation
* process improvement as part of delivery, not a separate activity

Engineering Excellence is not polish for its own sake.
It is disciplined, pragmatic software engineering that improves the system and the way we work on the system.

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

### Repo Artifacts
- Carry enduring doctrine so prompts stay short
- Define required behavior via tests
- Encode naming conventions, module boundaries, and design intent
- Preserve process memory: templates, reports, lessons learned, and reusable guidance should accumulate here rather than being rediscovered each time
- Serve Engineering Excellence by making good practice easier to repeat than bad practice

---

## Process Improvement

Good task execution should improve not only the code, but also the way the team works.

When a task reveals recurring friction, ambiguity, or waste, capture the improvement close to the source of truth:

* task-shaping problems -> task templates or doctrine
* recurring review confusion -> acceptance criteria or reporting structure
* unstable generated outputs -> deterministic generator rules
* repeated build/test breakage -> build scripts, test targets, or workspace-path guidance
* repeated architecture misunderstanding -> README, AGENTS, architecture notes, or focused reports

Prefer small durable process improvements over broad meta-discussion.

Engineering Excellence applies here too:
delivery is not complete when the code change lands but the same avoidable confusion remains in the workflow.

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

Useful self-learning outputs include:

* improved task templates
* sharper acceptance criteria
* better test expectations
* clearer archive classifications
* more precise terminology for recurring engineering concepts

The standard for self-learning is pragmatic usefulness:

> If the next agent reads the updated artifact, will it make the next iteration clearer, safer, or faster?

If yes, the learning is worth capturing.

That is Engineering Excellence expressed as organizational memory.

---

## Prompt Doctrine

A good Coding Agent prompt contains exactly five things:

```
# Task
[One paragraph. What change is wanted.]

## Scope
* files the agent may change
* files the agent must not touch

## Constraints
* preserve behavior
* keep diff small and reviewable
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

That is usually enough.

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

One mission per step. No all-in-one redesign prompts unless a full redesign is the intent.

When a task explicitly requires TDD sequencing, state the order:

1. unit or in-process integration tests first
2. implementation to pass those tests
3. system tests second
4. task is not complete until all required test layers pass

If a repo defines `make all` as the completion command, `make all` must run the
full required suite, not just build artifacts.

Prefer repo-owned local fixtures for normal tests over external mutable data
files. Use external files only for explicit integration coverage.

Mark aggregate make targets like `all`, `tests`, and `clean` as `.PHONY`.

Implement the specified external contract directly.
Do not preserve wrong internal formats and compensate for them in downstream code or tests.

## Reporting

When a task or user prompt changes one or more files, conclude the report with a suggested
concise git commit message.

When a task reveals reusable process improvements, include a short `lessons learned` or
`process improvement` note and identify the best repo artifact to update.

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
