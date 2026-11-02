# Spec Delta

## Purpose

Defines the phases a change moves through in a repository that uses the harness, the command that starts each phase, the context boundaries between them, the path for bugs, and how each phase ends.

## ADDED Requirements

### Requirement: Frame starts with grill-with-docs
The Frame phase SHALL start when the human runs `/grill-with-docs`, which runs the `grilling` interview together with `domain-modeling`. Terms resolved during Frame SHALL be recorded in `GLOSSARY.md`, created only when the first term is resolved.

#### Scenario: Frame resolves a domain term
- **WHEN** the human runs `/grill-with-docs` and a fuzzy term is settled during the interview
- **THEN** the agent records the term in `GLOSSARY.md`, creating the file if it does not exist

#### Scenario: Frame settles no term
- **WHEN** a Frame session ends without settling any domain term
- **THEN** no `GLOSSARY.md` and no `docs/adr/` file is created

### Requirement: Frame and Plan share one context
Frame and Plan SHALL run in the same context. After the human approves the plan, the agent SHALL name `/clear` followed by `/opsx:apply <name>` as the next commands and wait.

#### Scenario: Plan approved
- **WHEN** the human approves the planning artifacts of change `<name>`
- **THEN** the agent's report names `/clear` and then `/opsx:apply <name>` as the next commands and does not start Build

### Requirement: Build session closes the change
Build, Verify, archive, and retro for one change SHALL run in the same session. After `/opsx:archive`, the agent SHALL name `/retro` and then `/clear` as the next commands.

#### Scenario: Change archived
- **WHEN** the human runs `/opsx:archive` for a verified change
- **THEN** the agent's report names `/retro` and then `/clear` as the next commands

### Requirement: Changes fit one build session
Planning SHALL split work too large to build in one session into several changes.

#### Scenario: Large request
- **WHEN** a request needs more work than one build session can hold
- **THEN** the plan proposes a smaller first change and lists the remaining work as further changes

### Requirement: Bug path stops before the fix
When the human reports a bug, the agent SHALL diagnose with `/diagnosing-bugs`. During diagnosis it MAY create reproduction scripts, failing tests, and debug logs tagged `[DEBUG-...]`, and SHALL NOT change product code. It SHALL stop with the root cause, a proposed fix, and the fix's size.

#### Scenario: Root cause found
- **WHEN** diagnosis identifies the root cause of a reported bug
- **THEN** the agent reports the root cause, the proposed fix, and whether it is small or large, and waits without editing product code

#### Scenario: Human picks a small fix
- **WHEN** the human chooses the small fix
- **THEN** the agent applies it with `surgical-patch`, adds a regression test, and removes every `[DEBUG-...]` log

#### Scenario: Human picks a large fix
- **WHEN** the human chooses the large fix
- **THEN** the work continues through `/opsx:propose`

### Requirement: Phase report carries evidence
At the end of each phase the agent SHALL list the commands it ran with their results, and what it did not check.

#### Scenario: Build ends
- **WHEN** the Build phase ends
- **THEN** the report lists each check command run with its result and names every check that was not run
