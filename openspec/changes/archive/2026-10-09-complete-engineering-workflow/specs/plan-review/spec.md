# Spec Delta

## Purpose

An automatic, read-only review of a change's planning artifacts that runs in a fresh context before the human approves the plan, so planning mistakes are caught before any code exists.

## ADDED Requirements

### Requirement: Plan review runs before approval
After `/opsx:propose` creates the planning artifacts, the agent SHALL run the `plan-reviewer` subagent on the change and report its findings together with the plan.

#### Scenario: Plan created
- **WHEN** `/opsx:propose` finishes creating the artifacts of change `<name>`
- **THEN** the agent's report contains the `plan-reviewer` findings for `<name>` before asking the human to approve

### Requirement: Plan review is read-only
The `plan-reviewer` subagent SHALL read and search files only and SHALL NOT edit any file.

#### Scenario: Reviewer finds a problem
- **WHEN** the reviewer finds a problem in a planning artifact
- **THEN** it describes the fix in its report and every file stays unchanged

### Requirement: Plan review checks reuse
The reviewer SHALL flag any task that creates code which existing repository code, the standard library, a native platform feature, or an installed dependency already covers, naming the existing path or feature.

#### Scenario: Task re-implements a helper
- **WHEN** a task creates a helper that already exists in the repository
- **THEN** the finding names the task and the path of the existing helper

### Requirement: Plan review checks verifiability
The reviewer SHALL flag any task whose done condition cannot be checked by a command, naming the repository's `Verify:` command when `AGENTS.md` has one.

#### Scenario: Task has a vague done condition
- **WHEN** a task's done condition is not checkable by a command
- **THEN** the finding names the task and proposes a checkable condition

### Requirement: Plan review checks size and scope
The reviewer SHALL flag a change too large for one build session, and any task that touches an item listed under the proposal's "Out of scope".

#### Scenario: Task touches out-of-scope item
- **WHEN** a task edits something the proposal lists as out of scope
- **THEN** the finding names the task and the out-of-scope item

### Requirement: Plan review reports a verdict
The report SHALL end with `Ready to approve:` yes or no and the reason.

#### Scenario: No findings
- **WHEN** the reviewer finds no problem
- **THEN** the report states `Ready to approve: yes` with the reason
