# Spec Delta

## Purpose

Defines what the agent cannot read, edit, or push without the human in a repository that uses the harness on native Windows, and requires these limits to hold in every permission mode, including bypass permissions.

## ADDED Requirements

### Requirement: Agent cannot read .env files through its file tools
The agent's file tools SHALL be denied reading any `.env` or `.env.*` file in the repository, in every permission mode.

#### Scenario: Read tool on .env in bypass mode
- **WHEN** the session runs in `bypassPermissions` mode and the agent calls the Read tool on `.env`
- **THEN** the call is denied and the file content is not returned

### Requirement: Agent cannot read .env files through the shell
A shell command (Bash or PowerShell) that names a `.env` or `.env.*` file as a path SHALL be blocked before it runs, with a message telling the agent not to work around it. A command that only contains `.env` inside another word (for example `process.env.PORT` or `.venv`) SHALL NOT be blocked.

#### Scenario: PowerShell reads .env
- **WHEN** the agent runs `Get-Content .env` or `type config\.env.local`
- **THEN** the command is blocked and does not run

#### Scenario: Word that contains .env
- **WHEN** the agent runs `grep -rn process.env.PORT src` or `python -m venv .venv`
- **THEN** the guardrail does not block the command

### Requirement: Agent cannot read user credentials through its file tools
The agent's file tools SHALL be denied reading SSH keys, cloud and GitHub CLI credentials, git credentials, npm tokens, `*.pem` and `*.key` files, and `secrets/**`, in every permission mode.

#### Scenario: Read SSH key
- **WHEN** the agent calls the Read tool on a file under `~/.ssh/`
- **THEN** the call is denied

### Requirement: Every push needs the human's approval
Every `git push` the agent runs SHALL show the human an approval prompt, in every permission mode, including `bypassPermissions`. A push written in a form the approval rule does not match SHALL be blocked with a message to use the plain `git push` form.

#### Scenario: Plain push in bypass mode
- **WHEN** the session runs in `bypassPermissions` mode and the agent runs `git push origin main`
- **THEN** the human gets an approval prompt and the push runs only if they approve

#### Scenario: Disguised push
- **WHEN** the agent runs `git -C . push origin main`
- **THEN** the command is blocked and the message tells the agent to run `git push ...` instead

### Requirement: Agent cannot remove its own guardrails
The agent's file tools SHALL be denied editing `.claude/settings.json`, `.claude/hooks/**`, `CLAUDE.md`, and `CLAUDE.local.md`, in every permission mode.

#### Scenario: Agent edits settings in bypass mode
- **WHEN** the session runs in `bypassPermissions` mode and the agent tries to edit `.claude/settings.json`
- **THEN** the edit is denied and the file is unchanged

### Requirement: Build runs without routine prompts
Apart from `git push`, project settings SHALL NOT add approval prompts, so a Build in `bypassPermissions` mode runs without the human approving routine commands.

#### Scenario: Install during Build
- **WHEN** the session runs in `bypassPermissions` mode and the agent runs `npm install`
- **THEN** no approval prompt appears

### Requirement: A broken guardrail fails closed
When the shell guardrail cannot run or does not finish in time, the shell command SHALL be blocked rather than allowed.

#### Scenario: Guardrail script missing
- **WHEN** the guardrail script is missing or `powershell.exe` cannot start it
- **THEN** shell commands are blocked and the message names the guardrail
