# git-branch-workflow

## Brief

Add a git workflow to the harness template: one change at a time, each on `feat/<name>`, `fix/<name>`, or `chore/<name>` cut from an up-to-date `dev`; when it is done, push and open a PR into `dev`; the next change starts only after the human merges that PR and `dev` is pulled again, even when the next change does not need the previous one.
Why: in a project, `main` must stay stable; `dev` collects finished changes, and only the human promotes `dev` to `main`. This repository is the template itself, so it gets no `dev` branch and keeps working from `main`.
Done when `AGENTS.md` has a Git section of at most three lines that describes this flow, `AGENTS.md` stays at or under 40 lines, and `HARNESS-SETUP.md` creates `dev` in the project it installs into.

## Tasks

- [x] 1. Add a `## Git` section to `AGENTS.md`, between Guardrails and Gotchas, with one paragraph of at most three lines: branch name from the change name, cut from `dev` (or `main` when the repository has no `dev`) after switching to it and `git pull --ff-only`, unless the environment assigns a branch; commit after each verified task; when the human says done, push and open a PR into that base; start the next change only after the human merges it; only the human merges and promotes `dev` to `main`, never locally. Verify: Read of `AGENTS.md` shows the section, and the file has at most 40 lines.
- [x] 2. In `HARNESS-SETUP.md`, add a step that, when the project uses git and has no `dev` branch, asks the human once and then creates `dev` from `main` and pushes it (through the `git push` approval prompt). Add the matching line to Outcome, and branch protection for `dev` to the Vietnamese next-steps block. Verify: Read shows the step, the Outcome line, and the next-steps item.
- [x] 3. In `README.md` under `## How it works`, add a `### Git` subsection with the branch diagram (`feat/*` and `fix/*` into `dev` by PR, `dev` into `main` by PR the human merges), the commands to start the next change, and one line saying this template repository has no `dev` and works from `main`. Point to `AGENTS.md` for the rule. Verify: Grep finds `### Git` in `README.md`, and it states no rule that the `AGENTS.md` section does not.
- [x] 4. Push the changed files and this plan to branch `claude/great-allen-czquc2` (the branch this cloud session was assigned), which keeps PR nha261105/agent-harness#2 into `main`. Verify: the push returns a commit SHA.

## Review fixes

- [x] 5. Step 5 of `HARNESS-SETUP.md` created `dev` with `git switch -c dev origin/main`, which left the human on `dev` with the copied harness files uncommitted. Create it on the remote with `git push origin origin/main:refs/heads/dev` instead, without switching branches. Verify: Read of step 5 shows no `git switch`.
