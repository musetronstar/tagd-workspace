# Task

Continue to refactor the scanner so that we may
* easily reuse it elsewhere
* swap out scanners (as the front end)
* swap out parsers
* so more independence between scanner modules and parsers

## Scope

Files you can change:

* `tagl/src/scanner.re.cc`
* `tagl/src/tagdurl.re.cc`
   + re2c scanner for a **tagdurl** as input
   + emit parser tokens
   + emits same tokens as `scanner.re.cc`
   + TODO: output to file named `scanner.tagdurl.cc`
* `tagl/include/scanner.h` 
  * defines `TAGL::scanner` (parent class)
  * defines `TAGL::scanner::tagdurl` (child class of `TAGL::class`)
* `tagl/src/scanner.cc`
   + `scanner.h` funtions implemented in `scanner.cc`
   + function with good names
   + reuasble blocks of code useful for any scanner
     Move any scanner implentation from `tagl.cc` to here
   + implements: `TAGL::scanner::scan()` 
   + implements: `TAGL::scanner::tagdurl::scan()`
     overrides parent
* `tagl/include/tagl.h`
* `tagl/src/Makefile`

## Remove `scanner_mode`

We have object oriented styles, polymorphism,etc. - there is no reason to write code like this
its not extensible (e.g. like adding a new scanner mode.

- Remove `scanner_mode` from code

```bash
$ grep -r 'scanner_mode' tagl/*
tagl/include/tagl.h:enum class scanner_mode {
tagl/include/tagl.h:            scanner_mode _mode = scanner_mode::TAGL;
tagl/include/tagl.h:            void mode(scanner_mode m) { _mode = m; }
tagl/include/tagl.h:            scanner_mode mode() const { return _mode; }
tagl/include/tagl.h:                    _mode = scanner_mode::TAGL;
tagl/src/scanner.cc:            case scanner_mode::TAGDURL:
tagl/src/scanner.cc:            case scanner_mode::TAGL:
```

+ use OOP style scanner classes instead 
   + `TAGL::scanner` 
   + `TAGL::scanner::tagdurl`

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

* scope boundary
* behavior
* tests pass

## Deliverable: Concise Report

1. summary
2. test results
3. open issues, concerns or interesting observations

