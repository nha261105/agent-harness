# Proposal

## Why

The harness plans and checks against specs well, but a real engineering change still has gaps: no agreed check command, no review of the plan before code is written, no bug-finding review of the diff, no shared domain vocabulary, no rule for when to clear context, and no path for bugs. This change closes those gaps so the workflow runs end to end in any repository the harness is copied into.

## What Changes

- Frame starts with `/grill-with-docs` (the `grilling` interview plus `domain-modeling`, which keeps a `GLOSSARY.md` and offers ADRs only for hard-to-reverse decisions). Adds both skills from the local skill library. `wait-what` uses `GLOSSARY.md` again when it exists.
- A new read-only `plan-reviewer` subagent runs automatically at the end of Plan and reports findings with the plan. It checks for re-implementation of existing code, tasks without a runnable done condition, changes too large for one session, and tasks that touch out-of-scope items.
- Context boundaries: Frame and Plan share one context; after the human approves the plan, the agent names `/clear` and then `/opsx:apply <name>` as the next commands. A new tasks rule keeps each change small enough to build in one session.
- A new user-invoked `/review-change <name>` skill runs Verify on three axes: `verifier` (spec), the bundled `/code-review` (bugs), and `ponytail-review` (over-engineering). Spec and bug findings are must-fix; over-engineering findings are optional.
- A bug path: `/diagnosing-bugs` may create reproduction scripts, failing tests, and tagged debug logs, but no product-code fix. It stops with the root cause, a proposed fix, and its size; the human picks `surgical-patch` (small) or `/opsx:propose` (large).
- `HARNESS-SETUP.md` finds one check command in the target repository, runs it once, asks the human to confirm it, and writes it as a `Verify:` line in `AGENTS.md`; with no check command, it reports that instead. Its config check also fails on any OpenSpec warning.
- The Reporting section of `AGENTS.md` shrinks to the part that changes behavior: commands run with their results, and what was not checked.

## Capabilities

### New Capabilities
- `engineering-workflow`: the phases a change moves through, their commands, the context boundaries between them, the bug path, and the end-of-phase report.
- `plan-review`: the automatic read-only review of a change's planning artifacts before the human approves them.
- `change-review`: the human-started review of a built change on the spec, bug, and over-engineering axes.
- `harness-setup`: what `HARNESS-SETUP.md` establishes in a target repository, including the verify command and the config check.

### Modified Capabilities
None. `openspec/specs/` is empty.

## Out of scope

- Removing `"code-review": "user-invocable-only"` from `~/.claude/settings.json`. It is the human's personal file outside this repository; the human removes it after this change so `/review-change` can call `/code-review` on this machine. Target repositories need no such step.
- Making `ponytail` run automatically; it stays user-invoked.
- Anything under `.agents/`, and how Orca workers apply these skills.
- Git hooks, CI, and per-project `.claude/rules/` files.

## Impact

- Edited: `AGENTS.md`, `HARNESS-SETUP.md`, `README.md`, `openspec/config.yaml`, `.claude/skills/wait-what/SKILL.md`.
- Added: `.claude/agents/plan-reviewer.md`, `.claude/skills/review-change/SKILL.md`, `.claude/skills/domain-modeling/`, `.claude/skills/grill-with-docs/` (both copied from `D:/General/Agent-Skill/skills/mattpocock/`).
- Context cost: about 40 est. tokens per session for the `domain-modeling` description; `review-change` and `grill-with-docs` are user-invoked and cost nothing until typed.
