# Proposal

## Why

The harness gates every phase, but the gates only ask the human to approve. They do not check that the human understands what shipped, which is the delegation pattern that left developers with the lowest comprehension in Anthropic's 2026 study. The `grilling` interview asks many questions without making the work clearer. The permission setup has the opposite problem: it prompts so often during Build that the human wants to switch prompts off, yet its `.env` and push rules can be bypassed. This change keeps OpenSpec and makes three changes. Frame becomes a short brief written by the human. A new explain-back step after Build checks that the human understands the flow of the change. The guardrails hold when Build runs with bypass permissions.

## What Changes

- **BREAKING** Remove the `grilling` skill. A new user-invoked `/brief` skill replaces it: the human writes the intent in 3–5 lines, the agent asks at most three questions, each with a recommended answer, and then proposes a size (Small or Large).
- Two plan paths. A Small change is planned in a single `plans/<name>.md`. A Large change goes through `/opsx:propose`.
- A new user-invoked `/explain-back` skill runs after Build and before review. It shows the flow of the change as a diagram with the key decisions, asks the human two questions about the flow, and corrects the answers. The human does not write code by hand, and no Learning output style is used.
- Review fix loop: the findings the human picks are appended to the plan under `## Review fixes`, and Build runs again on them. Fixes are then recorded in the change folder, not only in chat.
- Guardrails for Windows without an OS sandbox, built so they still hold in `bypassPermissions` mode:
  - Deny rules block reading `.env` files and the usual credential locations.
  - Deny rules stop the agent from editing `.claude/settings.json` and `.claude/hooks/**`, so it cannot remove its own guardrails.
  - A PowerShell `PreToolUse` hook blocks shell commands that name a `.env` file, and blocks `git push` written in a form the `ask` rule does not match.
  - The `ask` list shrinks to `git push` only, so Build runs without prompts while every push still needs the human's approval.
- `AGENTS.md`, `HARNESS-SETUP.md`, and `README.md` describe the new workflow and the security model, including GitHub branch protection as the only hard boundary for `main`.
- Housekeeping found in review:
  - Mark the archived change `2026-10-09-complete-engineering-workflow` as superseded, because its outputs were rolled back.
  - Remove the dangling `codebase-design` reference from the `tdd` skill.

## Capabilities

### New Capabilities
- `engineering-workflow`: the phases a piece of work moves through (Brief, Plan, Build, Explain-back, Review with its fix loop), the Small and Large plan paths, and how each phase ends.
- `agent-guardrails`: what the agent cannot read, edit, or push without the human, and how these limits hold in every permission mode on Windows.

### Modified Capabilities
None. `openspec/specs/` is empty.

## Out of scope

- An OS-level sandbox, WSL2, or devcontainers. The human stays on native Windows.
- Process environment variables (`$env:*`, `printenv`). "Do not read env" here means `.env` files.
- Enforcing phase order with hooks (for example, blocking code edits during Plan).
- Changing `orca-delegate`, including its `--worktree current` setting.
- Setting up GitHub branch protection. It is a human action in each target repository; this change only documents it.
- Anything under `.agents/`, and the skill library at `../skills`.
- Changing the generated `/opsx:*` command files or `openspec/config.yaml`.

## Impact

- Added:
  - `.claude/skills/brief/SKILL.md`
  - `.claude/skills/explain-back/SKILL.md`
  - `.claude/hooks/guard.ps1`
  - `openspec/changes/archive/2026-10-09-complete-engineering-workflow/SUPERSEDED.md`
- Removed: `.claude/skills/grilling/`.
- Edited:
  - `.claude/settings.json`
  - `.claude/skills/tdd/SKILL.md`
  - `AGENTS.md`
  - `HARNESS-SETUP.md`
  - `README.md`
- Context cost: both new skills are user-invoked and cost nothing until typed. Removing `grilling` saves its description in every session.
- Every shell command now starts `powershell.exe` once for the hook, which adds about 0.2–0.5 s per command.
- No new dependency.
