---
name: orca-delegate
description: Delegate the Build of an approved Large OpenSpec change to a worker agent through Orca, then send review fixes back to the same worker. Use after the human approves the plan at Stop 2.
---

Start the worker with `orca orchestration worker-start --worktree current --agent claude --model claude-sonnet-5-5 --effort medium --spec "<spec>" --json`. When the human named another agent or model, use theirs (`--agent` takes an Orca agent id such as `claude`, `codex`, or `antigravity`). Keep the terminal handle from the result.

- Write the spec so a worker that never saw the conversation can finish from it: Target (`/opsx:apply <name>`), Change, Constraints, Ownership (the exact files it may create or edit), and Observable acceptance.
- Make the acceptance a command that has already run successfully in this environment.
- Tell the worker to ask the coordinator the moment the plan and reality disagree.
- Wait with `orca orchestration check --wait`, answer the worker's questions, and compare the files `worker_done` lists with the Ownership before accepting.
- Keep the worker until review is done. To send review fixes, start a new dispatch on the same terminal (`worker-start --terminal <handle> --worktree current --spec "<fix tasks>"`). Release it with `orca orchestration worker-release` when no fix is left.

**When Orca is not available.** Orca is the default. Only when `orca` is not installed, Orchestration is off, or `worker-start` fails, tell the human which one and ask whether to build with a Claude Code subagent instead. After their ok, start one subagent with the Agent tool (general-purpose, in this working tree, no worktree isolation) and the same spec, with the coordinator's questions going in its final report instead of `ask`. Send review fixes to the same subagent with SendMessage, and check the files it changed against the Ownership the same way.
