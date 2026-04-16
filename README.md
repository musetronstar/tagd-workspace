# tagd Workspace

This workspace supports TAGLization work across linked repositories.

## Purpose

* Translate source material into TAGL.
* Build useful tagspaces.
* Support related `tagd`, `tagr`, and dictionary work.

## Structure

* `TASKS.d/` task files
* `skills/` workspace meta-command skills

Git Worktrees:
* `tagd/` core semantic-relational database and TAGL implementation
* `tagd-simple-english/` Simple English dictionary source and related app work
* `tagr/` natural language to TAGL translator
* `tagd-nlp/` tagd NLP resources
* `tagd-ai/` tagd AI models

## Notes

* `TAGL-README.md` describes TAGL.
* `tagd`, `tagd-simple-english`, `tagr`, and `tagd-nlp` are git worktrees.
