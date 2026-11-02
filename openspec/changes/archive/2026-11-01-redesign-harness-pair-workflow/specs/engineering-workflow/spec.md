# Spec Delta

## Purpose

Defines the phases a piece of work moves through in a repository that uses the harness, so that the human decides every transition and understands the flow of every change that ships.

## ADDED Requirements

### Requirement: Human starts and ends every phase
The agent SHALL start a phase only when the human runs its command. When a phase ends, the agent SHALL report the result, name the next command, and wait.

#### Scenario: Phase ends
- **WHEN** any phase finishes
- **THEN** the agent's report names exactly the next command and the agent takes no further action until the human runs a command

### Requirement: Brief starts from the human's words
`/brief` SHALL start from an intent the human writes: what, why, and when it is done. When the human has not given one, the agent SHALL ask them to write it and SHALL NOT draft it for them.

#### Scenario: Brief without intent
- **WHEN** the human runs `/brief` with no arguments
- **THEN** the agent asks the human to state what, why, and when it is done, and writes no draft

### Requirement: Brief asks at most three questions
During `/brief` the agent SHALL ask at most three questions. Each question SHALL change the plan depending on its answer and SHALL carry a recommended answer. The agent SHALL look up facts itself instead of asking for them.

#### Scenario: Intent with open decisions
- **WHEN** the intent leaves four or more decisions open
- **THEN** the agent asks only the three that change the plan most, each with a recommended answer

#### Scenario: Intent with no open decision
- **WHEN** the intent leaves no decision open
- **THEN** the agent asks no question and goes straight to proposing a size

### Requirement: Brief ends with a size proposal
`/brief` SHALL end with the brief restated in at most five lines and a proposed size, Small or Large, with the reason. The agent SHALL edit no file during `/brief`.

#### Scenario: Brief done
- **WHEN** the human's answers settle the brief
- **THEN** the report holds the restated brief, a Small or Large proposal with its reason, and the next command for that size, and no file has changed

### Requirement: Plan path follows the chosen size
A Small change SHALL be planned in one file `plans/<name>.md` holding the brief, tasks with done conditions, and a `## Review fixes` section. A Large change SHALL be planned with `/opsx:propose <name>`.

#### Scenario: Human picks Small
- **WHEN** the human picks Small for change `<name>`
- **THEN** the plan is written to `plans/<name>.md` and no `openspec/changes/<name>/` folder is created

#### Scenario: Human picks Large
- **WHEN** the human picks Large for change `<name>`
- **THEN** the next command named is `/opsx:propose <name>`

### Requirement: Build follows the approved plan only
After the human approves a plan, the agent SHALL name `/clear` and then the Build command. During Build the agent SHALL edit only what the plan's tasks name, SHALL tick a task only after its done condition is verified, and SHALL stop and ask when the plan and the code disagree.

#### Scenario: Plan and code disagree
- **WHEN** a task cannot be done as written because the code differs from the plan
- **THEN** the agent stops, reports the gap, and does not work around it

### Requirement: Explain-back follows Build
After Build the agent SHALL name `/explain-back <name>`. Explain-back SHALL show the flow of the change as one diagram with a file and line for each step, list at most five key decisions, and ask the human two questions about the flow, not about syntax. It SHALL edit no file.

#### Scenario: Build finished
- **WHEN** Build of change `<name>` finishes
- **THEN** the agent names `/explain-back <name>` as the next command, not `/code-review`

#### Scenario: Explain-back run
- **WHEN** the human runs `/explain-back <name>`
- **THEN** the agent shows the flow diagram and key decisions, asks one question on a failure path and one on a design decision, gives no hint, and waits

### Requirement: Explain-back corrects the human's answers
Explain-back SHALL judge each answer as correct, partly correct, or wrong. For a partly correct or wrong answer it SHALL give the right answer with the file and line to read. Then it SHALL name `/code-review`.

#### Scenario: Wrong answer
- **WHEN** the human's answer about a failure path is wrong
- **THEN** the agent says it is wrong, states what actually happens, and points to the file and line that handle it

### Requirement: Review fixes go into the plan
When the human picks findings from `/code-review` or `/ponytail-review`, the agent SHALL append them as unticked tasks under `## Review fixes` in the plan and name the Build command again. Findings the human did not pick SHALL NOT be fixed.

#### Scenario: Human picks two findings
- **WHEN** the human picks findings 2 and 5 of a review
- **THEN** the plan's `## Review fixes` section gains two unticked tasks, one per finding, each with a done condition, and no code changes before the next Build

#### Scenario: No fix left
- **WHEN** the human picks no finding, or all review-fix tasks are ticked
- **THEN** the agent names `/opsx:archive <name>` for a Large change, or reports the Small change as done, and then names `/clear`

### Requirement: Phase report carries evidence
At the end of each phase the agent SHALL list the commands it ran with their results, and what it did not check.

#### Scenario: Build ends
- **WHEN** the Build phase ends
- **THEN** the report lists each check command run with its result and names every check that was not run
