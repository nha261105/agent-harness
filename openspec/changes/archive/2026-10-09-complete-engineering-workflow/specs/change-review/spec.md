# Spec Delta

## Purpose

A human-started review of a built change on three axes, spec conformance, bugs, and over-engineering, merged into one report that separates must-fix findings from optional ones.

## ADDED Requirements

### Requirement: Review starts only on the human's command
The change review SHALL run only when the human types `/review-change <name>`. The agent SHALL NOT start it on its own.

#### Scenario: Build finishes
- **WHEN** Build of change `<name>` finishes
- **THEN** the agent names `/review-change <name>` as the next command and does not run the review itself

#### Scenario: Name missing or ambiguous
- **WHEN** the human runs `/review-change` without a name that matches exactly one active change
- **THEN** the agent lists the active changes and asks which one to review

### Requirement: Review covers three axes
`/review-change <name>` SHALL run, in order, the `verifier` subagent (spec conformance), the bundled `/code-review` (bugs in the diff), and `ponytail-review` (over-engineering in the diff).

#### Scenario: All reviewers available
- **WHEN** the human runs `/review-change <name>`
- **THEN** the report contains a section for each of the three axes

#### Scenario: A reviewer cannot run
- **WHEN** one reviewer cannot run (for example, `/code-review` is set to user-invocable only)
- **THEN** the report names that axis as not checked with the reason, and the other axes still run

### Requirement: Review separates must-fix from optional findings
The merged report SHALL mark spec and bug findings as must-fix and over-engineering findings as optional, and SHALL number findings across the whole report.

#### Scenario: Mixed findings
- **WHEN** the reviewers return a spec finding, a bug finding, and an over-engineering finding
- **THEN** the report lists the first two under must-fix and the third under optional, each with its own number

### Requirement: Review edits nothing
`/review-change` SHALL NOT edit files; the human chooses which numbered findings to fix.

#### Scenario: Findings reported
- **WHEN** the review completes with findings
- **THEN** no file has changed and the agent waits for the human to name the findings to fix
