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
   - Add a `# TODO` comment explaining the assumption.
6. Do not refactor or modify the `tagd` library unless explicitly instructed.
7. Work inside `tagd-dictionary` unless library inspection is needed.

---

## TAGL Generation Philosophy

- "Nothing exists in isolation - To define is to related."
- TAGL is a formal language - use correct TAGL syntax rather than prose.
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

