# AGENTS.md

This repository is a human-gated agent harness: the human decides what to build and confirms they understand it; the agent runs the steps in between.

<!-- Maintainers: this repo is also a template for other projects; setup and reuse steps are in README.md and HARNESS-SETUP.md. HTML comments are stripped before Claude Code loads this file. -->

## Choosing the path

A single, plainly small edit (a typo, a rename, one line) goes straight through. Everything else starts with `/brief`, which ends with a Small or Large proposal. Small: one module, no behavior that `openspec/specs/` describes, and nothing touching data migration or deletion, auth or permissions, a public API or contract, payments, or security settings; you plan it in `plans/<name>.md` and build it yourself. Large: an OpenSpec change built by a worker through `orca-delegate`.

For a reported bug, find the root cause before changing product code. Report the cause, the proposed fix, and its size, then wait.

## Workflow

The human types only at the stops below (Small has Stop 1 and Stop 3, Large all three): answers, questions, and "ok". Between stops, run every step yourself without asking for a command. At each stop, report and wait. When compacting, preserve the change name, the last stop passed, and what the human approved. To keep context lean, suggest `/clear` after the human says done and after Stop 2 on a Large change (the plan holds the state), and suggest `/handoff` when the human says the session is long before the change is done.

1. **Brief** (`/brief`). **Stop 1:** the human confirms the brief and the size; for Small also the tasks, and after "ok" you write `plans/<name>.md` and go to Build.
2. **Plan** (Large only). Run `/opsx:propose <name>` and summarize the plan in 5–10 lines. **Stop 2:** the human approves the plan.
3. **Build.** Large: delegate with `orca-delegate`, answer the worker, and accept its result. Small: build it yourself. Edit only what the tasks name, tick a task only once its outcome is verified, and stop at once when plan and code disagree. After the last task, run the `Verify:` line of this file when it has one, and fix any failure before Review.
4. **Review.** Run `/code-review low` (Small) or `/code-review medium` (Large), then `/ponytail-review`. Fix correctness findings the review marks as confirmed without asking: append each under `## Review fixes` in the plan and build it (Large: send it back to the same worker). Stop after two fix rounds. Keep every other finding (design, scope, deletions) for Stop 3.
5. **Explain** (`/explain-back <name>`). **Stop 3:** the human asks questions and decides the pending findings. Picked findings go back to step 3. When the human says done: Large, run `/opsx:archive <name>` and pick "Sync now"; Small, report it done.

## Guardrails

`.env` files and credentials are off limits, and every `git push` goes through the human's approval prompt. When a guardrail blocks a command, report it and do not work around it.

## Git

`main` is the only long-lived branch and it is production: its pipeline runs the verify jobs and deploys when they pass. Name the branch `feat/<name>`, `fix/<name>`, or `chore/<name>` after the change, unless the environment assigns one, and cut it from `main` right after `git switch main` and `git pull --ff-only`. Commit after each verified task. When the human says done, push the branch and open a merge request (GitLab) or pull request (GitHub) into `main` with auto-merge on, so it merges and deploys once the pipeline passes; when the pipeline fails, fix it on the same branch. Start the next change only after the previous one has merged. Never push to `main` or merge into it locally.

## Gotchas

- Keep `AGENTS.md` as the only instruction file. A `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` in this directory or any directory above it (`/init` creates one) makes Claude Code read that file instead of this one.

<!-- Maintainers: the /opsx:* commands run the globally installed openspec CLI. Hard limits live in .claude/settings.json (permissions) and .claude/hooks/guard.ps1; this file guides, it does not enforce. -->

## Reporting

At each stop, list the commands you ran with their results, and what you did not check.
