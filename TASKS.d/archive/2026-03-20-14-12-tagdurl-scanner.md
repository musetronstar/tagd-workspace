# tagdurl Task

We would like to find all places where we use tagdurls
and use the TAGL tagdurl scanner instead.

Then we will add unit test file for tagdurl in
`tagd/tagl/tests/TagdUrlTester.h`
TODO: Fill it first with tests according to the occurences of tagdurls in processing/testing in the current software.

## Scope

Create/Modify these files/dirs:
+ `tagd/tagl/tests/TagdUrlTester.h`
+ `tagd/tagl/tests/Makefile`
+ `tagd-workspace/out/`

### Read
* `tagd/` repository
* `tagd-workspace/` repository

### Write 
**Write**: challenge with concice reason and **ask for permission**
           before a file scope addition

## Doctrine

Use an **Agile**, **TDD** iterative development style and methodology.
* Think Small: Try for one small success at a time.
* Big Success: is the accumulation of many small successes.

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

* boundary
* behavior
* tests pass

## Deliverable: Concise Report

1. summary
2. test results
3. open issues, concerns or interesting observations


## Task 1: Document current tagdurl parsing
* Create a document capturing the heiarchy, organization and flow
  of the current tagdurl parsing code in `httagd/`

## Task 2: Create Tests
Find all the instances of a `tagdurl` being processed or used in
* source code
* tests (e.g. httagd expect tests)

Fill in several **test tagdurl #** examples scope section this file outline all the places `tagdurl`s occur

## tagdurl Test Examples
1. <test tagdurl 1>

## Task 3: TDD/Agile Development
Use TDD methodology to test/implement/test **task 2** **test tagdurl**s

for each <test tagdurl>  from **task 2**:
  1. Create a new unit test for tagdurl
  2. call the cxxtester executable to test that new test target
  3. Implement feature in `scanner-tagdurl.re.cc`
    - Do no overbuild
    + Only add enough to pass the test
    + Follow existing project style and idioms

Update the Makefile and test all using `make tests`

## Task 3: System Testing

In `tagd/`,
* do a `make clean && make tests`
  Fix anything broken
  

