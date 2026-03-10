# tagd Agent Workspace

This workspace contains two related repositories:

- `./tagd` — core TAGL language and tagd engine (library)
- `./tagd-dictionary` — VOA Wordbook dictionary encoded as TAGL (application)

The goal is to represent the VOA Wordbook as a TAGL tagspace.

---

## Ground Rules for Dictionary Generation

1. Source of truth is the VOA Wordbook TSV data.
2. Prefer VOA definition wording.
3. Avoid inventing new high-level ontology unless necessary.
4. Use minimal hyponymy.
5. If inference beyond the VOA definition is required:
   - In `.tagl`, add an inline `-- reasonable induction` comment on the inferred statement.
   - TODO comments are added by human, do not add unless instructed. Do not modify existing `-- TODO`
6. Do not refactor or modify the `tagd` library unless explicitly instructed.
7. Work inside `tagd-dictionary` unless library inspection is needed.

---

## TAGL Generation Philosophy

- "Nothing exists in isolation - To define is to related."
- TAGL is a formal language - use correct TAGL syntax rather than prose.
- Don't be creative; prefer TAGL statements that use only wording present in the VOA definition where possible.
- If the definitions provide an abstraction explicitly, implicitly, or by clear induction, it is acceptable to use that abstraction in the hierarchy.
- Part-of-speech matching is not required for every subordinate relation; prefer the hierarchy that best preserves and derives meaning consistently.
- Use the tree structure to benefit usable software; consistency is more important than finding a single perfect ontology.
- Prefer simple, shallow hierarchies.
- Avoid metaphysical expansion.
- Prefix each VOA term definition id with a `VOA:` namespace
  so we can distinguish tags from the VOA Word Book from other tags

When uncertain, choose the simpler structure.

---

## Workflow Expectations

- Read from `.tsv`
- Generate or update `.tagl`
- Keep definitions consistent with existing examples
- Do not delete existing valid entries without instruction
- Add prerequisite subordinate statements inline as needed while working from top to bottom; avoid unnecessary reordering of generated TAGL beyond what is needed to satisfy dependencies and consistency.
- Define "next word" strictly as the first remaining commented VOA id in file order from `voa-simple-english-tree.tagl`, selected with: `grep -w '\-\-_has VOA:id' voa-simple-english-tree.tagl | head -n 1`.
- "Process a word" means this exact iterative loop for one word only:
  1) Find the next word using `grep -w '\-\-_has VOA:id' voa-simple-english-tree.tagl | head -n 1`.
  2) Translate only that single selected commented `VOA:id` block into TAGL.
  3) Run validation: `/home/inc/projects/tagd/tagsh/bin/tagsh -f voa-simple-english-tree.tagl -n`.
  4) If validation fails, fix the reported issue(s) and repeat step 3 until validation succeeds.
  5) Stop after validation succeeds for that one word; do not process additional words unless explicitly asked.
  6) Show the diff for the successful changes from this processed word.
- "Process the next N words" means batch mode with the same validation loop:
  1) Repeat the single-word loop N times in top-to-bottom order.
  2) After each word translation, run `/home/inc/projects/tagd/tagsh/bin/tagsh -f voa-simple-english-tree.tagl -n` and fix issues until it succeeds before moving to the next word.
  3) Continue automatically until all N words are successfully processed.
  4) Then show one combined diff containing the successful changes for those N words.
- If the selected commented block is a duplicate of an already translated uncommented entry with the same `VOA:id`, remove the duplicate commented block, run validation, and then stop; do not continue to additional ids unless explicitly asked.

---

## Practical Rules

- Keep each VOA sense separate unless the source wording clearly supports a semantic parent-child relation between senses.
- Prefer the shallowest TAGL rendering that stays close to the VOA wording; do not replace vague source terms like `something` with a more specific parent like `event` unless required.
- Define prerequisite tags and relators before using them in a statement; TAGL requires valid subject-relator-object structure, not bare English fragments.
- Sparse subordinate definitions taken directly from the VOA wording are acceptable when they preserve the source semantics and avoid unnecessary invented ontology.
- If a statement is not direct VOA wording or an exact normalization of recurring VOA wording, but is still a justified prerequisite or abstraction, mark that statement inline with `-- reasonable induction`.
- Prefer object relations over modifiers: when information can be represented as a meaningful subject-relator-object statement, model it as an object relation instead of a modifier assignment. Use modifiers mainly for scalar/literal metadata where no useful object node or relation is intended.
- When defining a namespaced or URI-style tag id with `:`, use the superordinate tag as the prefix and the word as the suffix, for example `event:accident` or `place:across`.
- Do not add predicates that are not present in the VOA definition unless TAGL requires a fallback.
- If a more specific subordinate relation is not part of the VOA definition, use `_sub`.
- If a more specific predicate relation is not part of the VOA definition, use `_rel`.
- Validate edited `.tagl` files with `tagsh -f <file> -n` after changes.
