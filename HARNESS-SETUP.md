# Harness setup

You are installing a human-gated agent harness into the repository you are in. Read this file fully, then work through the steps in order. Every step ends with a check; move on only when it passes. Delete this file only at the end.

## Outcome

Done when all of these hold:

- `AGENTS.md` is the only instruction file Claude Code reads here (no `CLAUDE.md` in this directory or above it).
- OpenSpec is initialized, `/opsx:propose`, `/opsx:apply`, `/opsx:archive`, and `/opsx:update` exist, and `/opsx:update` is user-only while the other three are not (the agent runs them itself, as `AGENTS.md` describes).
- `openspec/config.yaml` carries the human's project context and the rules below.
- No `openspec-*` skills remain under `.claude/skills/`.
- `.claude/settings.json` and `.claude/hooks/guard.ps1` are unchanged from the template.
- `AGENTS.md` carries a `Verify:` line with a check command the human confirmed, or your final report states that the repository has none.
- When the repository has a remote `origin`, your final report says whether its CI config has verify jobs and a deploy on `main`.
- This file is deleted, and your final report lists what changed, which commands ran, what you could not check, and ends with the human's next steps in Vietnamese (restart Claude Code, then `/memory` and `/skills`).

## 0. Preconditions

- Run `openspec --version`. When it is missing, ask the human before running `npm install -g @fission-ai/openspec@latest` (needs Node 20.19 or newer).
- Look for a `CLAUDE.md` in this directory and every parent directory. When one exists, stop and ask the human how to merge: Claude Code stops reading `AGENTS.md` while a `CLAUDE.md` exists, so the usual fix is a line `@AGENTS.md` inside that `CLAUDE.md`. The human makes that edit: `.claude/settings.json` denies you edits to `CLAUDE.md` and `CLAUDE.local.md`.
- Ask the human once: did this repository have its own `AGENTS.md` or `CLAUDE.md` before the copy? When yes, merge their content into the new `AGENTS.md` instead of replacing it.

## 1. Initialize OpenSpec

Run `openspec init --tools claude,antigravity`. Check: `openspec list --json` returns a `root` object. Skip this step when an `openspec/` directory already exists.

## 2. Remove what `init` generated beyond the harness

Delete `.claude/skills/openspec-*`, `.claude/commands/opsx/explore.md`, `.claude/commands/opsx/sync.md`, and `.claude/skills/grilling/` (left by an older harness). Leave the `.agents/` files `init` created; Antigravity reads them. Check: `.claude/skills/` holds no `openspec-*` entry and at least `brief`, `explain-back`, `handoff`, `orca-delegate`, `ponytail-review`, `tdd`, and `wait-what`, `.claude/hooks/guard.ps1` exists, and `.claude/commands/opsx/` holds `apply.md`, `archive.md`, `propose.md`, and `update.md`.

Do not run `openspec update` afterwards; it regenerates what you just removed.

## 3. Local settings

Create `.claude/settings.local.json` (merge when it exists, and remove any `opsx:propose`, `opsx:apply`, or `opsx:archive` entry an older harness left in `skillOverrides`, because the agent runs those itself) with:

```json
{
  "skillOverrides": {
    "opsx:update": "user-invocable-only",
    "init": "user-invocable-only",
    "anthropic-skills:docx": "user-invocable-only",
    "anthropic-skills:pptx": "user-invocable-only",
    "anthropic-skills:xlsx": "user-invocable-only",
    "anthropic-skills:pdf": "user-invocable-only",
    "anthropic-skills:google-workspace": "user-invocable-only",
    "anthropic-skills:morning": "user-invocable-only",
    "anthropic-skills:import-memory": "user-invocable-only",
    "anthropic-skills:deep-research": "user-invocable-only",
    "anthropic-skills:computer-use": "user-invocable-only",
    "anthropic-skills:built-in-browser": "user-invocable-only",
    "anthropic-skills:chrome-browser": "user-invocable-only",
    "dataviz": "user-invocable-only",
    "artifact-diagramming": "user-invocable-only",
    "plugin-authoring": "user-invocable-only"
  }
}
```

The entries after `opsx:update` hide account and built-in skills this harness never needs, to save context; `init` is hidden because it creates a `CLAUDE.md`. Keep `code-review` visible: the Review step uses it.

When the repository uses git and `.gitignore` lacks `.claude/settings.local.json`, add it. Check: the file parses as JSON.

## 4. Project text (ask the human)

- Ask for one or two sentences describing this repository. Replace the opening paragraph of `AGENTS.md` and the maintainer comment below it with them, dropping every mention of the template and of this file.
- Find one check command in this repository (package manifest scripts, task runners such as a Makefile, CI workflows) that runs its tests, lint, or typecheck. Run it once, show the human the result, and ask them to confirm it or name another (run that one once too). Write it as a line `Verify: <command>` directly under the opening paragraph of `AGENTS.md`. When the repository has no such command, write no `Verify:` line and say so in your final report.
- Ask which constraints cannot be read from the code (conventions, compatibility rules, anything surprising). Write `openspec/config.yaml` from the block below, putting only those constraints under the marked line.

```yaml
schema: spec-driven

# Project context: constraints an agent cannot infer by reading the repo.
context: |
  Language: English. Write every artifact in English, keeping OpenSpec keywords (SHALL, WHEN, THEN, ADDED Requirements) unchanged.
  The human reviews every plan before any code or file edit happens, and the implementer may be a different agent (Claude Code or Antigravity) that sees only the change folder.
  <project constraints from the human>

# Per-artifact rules: appear only in the matching artifact.
rules:
  proposal:
    - State the problem and the intent in plain terms a reviewer can approve or reject in two minutes.
    - Include an "Out of scope" section.
  specs:
    - Give every requirement at least one scenario in WHEN/THEN form that can be checked.
  design:
    - Record the decisions that were hard to reverse or had real alternatives, with the reason for each choice.
    - For each new dependency, record why the standard library, native platform features, and dependencies already installed do not cover the need.
  tasks:
    - Make each task small enough to finish and check on its own.
    - End each task with a verifiable done condition.
    - Write each task so an agent that never saw the conversation can carry it out from the change folder alone.
    - Before a task adds new code, check in order whether code in this repository, the standard library, native platform features, or dependencies already installed cover the need, and point the task there. A task adds new code only when none of these does.
    - Keep the change small enough to build in one session; plan larger work as several changes, starting with the smallest useful one.

# Per-operation guidance: advisory, not enforced.
operations:
  apply:
    guidance:
      - Work only on tasks listed in tasks.md.
      - Tick a task only after verifying its done condition.
      - When the plan and the code disagree, stop and report the gap to the human.
      - Before writing a new function, helper, or dependency, search this repository for one that already does the job, and reuse it.
  archive:
    guidance:
      - Summarize what shipped and any deviations before archiving.
```

Check: `openspec context --json` returns a `root` and prints no warning (a warning means a config rule was dropped; fix the config and rerun), and `AGENTS.md` no longer mentions `HARNESS-SETUP.md`.

## 5. Branch and pipeline

In `AGENTS.md`, `main` is production: each change is cut from `main`, reaches it through a merge request (GitLab) or pull request (GitHub) with auto-merge on, and deploys once the pipeline's verify jobs pass. Skip this step when the repository has no remote `origin`, and say so in your final report. Otherwise read `git remote get-url origin` to tell GitLab from GitHub, then read the CI config (`.gitlab-ci.yml`, or `.github/workflows/`) and report whether it has verify jobs and a deploy job that runs on `main` after them. Do not create or change the CI config or the platform settings here; those are the human's (step 7 lists the settings). Check: your final report names the platform and what the CI config has or lacks.

## 6. Delete this file

After steps 0 to 5 passed, remove `HARNESS-SETUP.md`.

## 7. Final report: end with the human's next steps

Report in a few lines: what changed, which commands ran and their results, and what you did not check. Then finish with this block in Vietnamese, worded as a request to the human, because only they can do it (Claude Code reads its configuration at session start, and the slash commands below are theirs to type). Keep the command names unchanged:

> **Việc bạn cần làm tiếp (setup chưa xong cho đến khi bạn làm các bước này):**
> 1. Khởi động lại Claude Code trong repo này.
> 2. Gõ `/memory` và kiểm tra `AGENTS.md` có trong danh sách.
> 3. Gõ `/skills` và kiểm tra `opsx:update` là user-only, `opsx:propose`, `opsx:apply`, `opsx:archive` thì không, và không còn skill `openspec-*` nào.
> 4. Bật auto mode (`Shift+Tab`), rồi thử `/brief` với một việc nhỏ: bạn chỉ cần trả lời và nói "ok" ở Stop 1 và Stop 3 (việc nhỏ không có Stop 2).
> 5. Bảo vệ `main` trên nền tảng của repo (đây là lớp duy nhất chặn được mọi cách push):
>    - GitLab: Settings → Repository → Protected branches: `main` với Allowed to push = No one, Allowed to merge = Maintainers. Settings → Merge requests: bật "Pipelines must succeed" và auto-merge.
>    - GitHub: Settings → General: bật "Allow auto-merge". Settings → Rules (hoặc Branches): với `main`, bắt buộc pull request và các status check verify phải xanh.
>    - Nếu báo cáo nói CI còn thiếu job verify hoặc deploy trên `main`, thêm chúng trước khi bắt đầu change đầu tiên.
