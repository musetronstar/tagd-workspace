# Task

Introduce `_integer` and `_float` as primitive numeric hard tags and split
the single `TOK_QUANTIFIER` scanner token into two distinct numbers: `TOK_INTEGER` and
`TOK_FLOAT` tokens. `TOK_QUANTIFIER` is going away, but parser
production `quantifier` will hold its slot in the parser position.

Rename `TYPE_TEXT` to `TYPE_STRING` in `data_t`. Update
`TAGL-spec.md` to document primitive types. All existing behavior that
depended on `TOK_QUANTIFIER` must be preserved under the new tokens.

## Source Justification

From the current source:

* `modifier` is stored as `id_type` (`std::string`) with `modifier_type`
  always defaulting to `TYPE_TEXT` — `TYPE_INTEGER` and `TYPE_FLOAT` are
  defined in `data_t` but no constructor in `tagd.h` sets them
* `parser.y` calls the four-argument `relation()` overload (no `data_t`
  argument) — numeric type is never set by the parser
* `scanner.h` matches both integers and floats in a single rule emitting
  `TOK_QUANTIFIER`:
  ```re2c
  "-"? [0-9]+ ("." [0-9]+)?   { emit(TOK_QUANTIFIER, new_value()); goto next; }
  ```

Therefore:

* numeric typing must originate in the scanner, not the parser
* `TYPE_INTEGER` and `TYPE_FLOAT` must become reachable via scanner-emitted
  tokens
* `cmp_modifier_lt` and `cmp_modifier_eq` in `tagd.cc` already parse modifier
  strings numerically via `std::strtoll` and `std::strtold` — this behavior
  must remain unchanged

## Principles

* The scanner is the gatekeeper of type. Numeric literals are classified
  lexically — no `lookup_pos()` required.
* `_integer` and `_float` are distinct types. No implicit coercion between
  them (Erlang semantics).
* Both types are always signed. A leading `-` is part of the literal token,
  not a unary operator. `"-23"` MUST be emitted as a single `TOK_INTEGER`.
* `TYPE_TEXT` → `TYPE_STRING` aligns `data_t` with the spec and the parser
  token `QUOTED_STR`. All references must be updated consistently.
* Scientific notation is DEFERRED — do not introduce it.

## Scope

### Read
* `tagd/tagd/include/tagd/hard-tags.h`
* `tagd/tagd/include/tagd/codes.h`
* `tagd/tagd/include/tagd.h`
* `tagd/tagd/src/tagd.cc`
* `tagd/tagl/include/scanner.h`
* `tagd/tagl/src/scanner.re.cc`
* `tagd/tagl/src/parser.y`
* `tagd/tagl/src/tagdurl.re.cc`
* `docs/TAGL-spec.md`
* existing tests for scanner, parser, and tagsh

### Write
* `tagd/tagd/include/tagd/hard-tags.h`
* `tagd/tagd/include/tagd/codes.h`
* `tagd/tagd/include/tagd.h`
* `tagd/tagd/src/tagd.cc`
* `tagd/tagl/include/scanner.h`
* `tagd/tagl/src/scanner.re.cc`
* `tagd/tagl/src/parser.y`
* `docs/TAGL-spec.md`
* scanner and parser tests

### Non-goals
* arithmetic expressions
* scientific notation
* boolean literals (`_true`, `_false`)
* `_string` or `_binary` primitive types
* `tagdurl.re.cc` — no numeric token changes required there
* storage layer (`tagdb`) changes beyond what `TYPE_STRING` rename requires

## Doctrine

Follow `docs/ai-assisted-dev-doctrine.md`

## Constraints

* changes must follow dependency order: `hard-tags.h` → `codes.h` → `tagd.h`
  → `tagd.cc` → `scanner.h` → `parser.y`
* the `TOK_FLOAT` scanner rule MUST precede the `TOK_INTEGER` rule
* `"-23"` MUST be scanned as a single `TOK_INTEGER` token; `"-1.0"` as a
  single `TOK_FLOAT` token
* `TOK_QUANTIFIER` scanner token must be replaced by `TOK_INTEGER` and
  `TOK_FLOAT` — no scanner references may remain
* `TYPE_TEXT` must be fully replaced by `TYPE_STRING` — no references may
  remain
* the `boolean_value` grammar rule currently uses `TOK_QUANTIFIER`; update
  it to `TOK_INTEGER` and preserve its behavior
* `quantifier` MUST be preserved as a named grammar production in `parser.y`
  — it is a meaningful semantic seam reserved for future design. It MUST
  reduce from `TOK_INTEGER` and `TOK_FLOAT` and feed into `rhs_object`:
  ```
  quantifier(q) ::= INTEGER(I) . { q = I; }
  quantifier(q) ::= FLOAT(F) .   { q = F; }
  rhs_object(o) ::= quantifier(q) . { o = q; }
  ```
  declare `%type quantifier { TAGL::TokenText }` accordingly
* modifier comparison in `tagd.cc` (`cmp_modifier_lt`, `cmp_modifier_eq`)
  must remain semantically unchanged
* do not silently broaden scope if a missing prerequisite is discovered —
  report it

## Spec Changes

Update `docs/TAGL-spec.md`:

* add Section 3.5 (Types) defining `_number`, `_integer`, `_float` as hard
  tags with their TAGL subordinate relations and literal forms
* integer literals: `0`, `1`, `55`, `-23`
* float literals: `3.14`, `-1.0`, `0.0`
* note scientific notation as DEFERRED
* update Section 4.3 to replace `QUANTIFIER` with `INTEGER` and `FLOAT`
  literal entries

## Tests

* scanner emits `TOK_INTEGER` for: `0`, `1`, `55`, `-23`
* scanner emits `TOK_FLOAT` for: `3.14`, `-1.0`, `0.0`
* `boolean_value` rule accepts `TOK_INTEGER` `0` and `1` with correct behavior
* existing tests pass unchanged
* completion command: `make all` from the repo root

## Acceptance Criteria

* `TOK_QUANTIFIER` does not appear anywhere in the codebase (scanner only —
  the `quantifier` grammar production is preserved and required)
* `TYPE_TEXT` does not appear anywhere in the codebase
* `HARD_TAG_NUMBER`, `HARD_TAG_INTEGER`, `HARD_TAG_FLOAT` defined in
  `hard-tags.h` in a `/***** primitive types *****/` section after relators,
  with TODO comment noting gperf limitation on sub_relator field
* `TAGL-spec.md` updated per Spec Changes above
* `make all` passes

## Deliverable: Concise Report

1. summary of changes
2. test results
3. open issues, concerns, or observations
4. suggested concise git commit message
