# Task

I added target archive directories where I wanted completed files moved.
I then want an assessment of completed tasks, relevent generated documents, and tasks left to complete.

## Directories

    TASKS.d/     # agent tasks markdown files
    out/         # generated reports by agents

## Target Directories

    TASKS.d/archive/
    out/archive/

## Files to Move

### `TASKS.d/`

Do not move all files.

#### Acceptence Criteria
 
Only **fully completed** tasks in files

    TASKS.d/*.md

To be moved into

    TASKS.d/archive/

#### Constraints 

Do not move a file if the task is not **fully complete**.

### `out/`

Do not move all files.

#### Acceptance Criteria

I wanted only **fully addressed** or **no-longer-relevant** reports in files

    out/*.md

To be moved into

    TASKS.d/archive/

#### Constraints

Do not move a file if it is not **fully addressed** or **no-longer-relevant**.

## Movement Instructions

For <target_file> in each target_directory:
  Understand the task or report in the <target_file>
  [take note for report]
  Inspect files referenced in the <target_file>
  Inspect the  commit histories and diffs of <target_file> relevant to the task or report
  [take note for report]
  Does <target_file> pass **Acceptance Criteria**?
  [take note for report]
  If "Yes" then
    move <target_file> into archive directory
    [take note for report]
  Else
    do nothing, but [take note for report]

## Report Instructions

Write the `.md` report in `out/` consistent with our naming conventions.

1. **Expand and scatter** [report notes] into sections with topic heading; Use classfification/categorization techniques to choose the best topic from the content

2. **Map** all the expanded topics together with links of association

3. **Reduce** bring all content together, grouped by topic and filtered into conscise **impact statements** grouped and ordered by **topic**

4. Generate markdown report of highly condensed, non-repetitive - containing sections
1. after action report, status of the project as **impact statements by topic**
2. well organized document of actionable intelligence of **impact statements by topic** within the context and mission of reaching project (tagd-workspace) goal and applying lessons learned.
3. Conclude with a list of tasks to be complete as **impact statements by topic**

