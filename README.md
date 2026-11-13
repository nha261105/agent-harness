# Human-Gated Agent Harness

A setup for building software with Claude Code where **you decide and the agent does the work in between**. You say what to build, approve the plan, and confirm you understand the result. The agent reads the code, plans, builds, tests, reviews, explains, and ships through a pull request.

This repository is the template. You copy it into a real project and then work there.

- **Rules:** `AGENTS.md` is the only rulebook the agent follows. This README explains how the pieces fit, how to install them, and where to change them.
- **Tools:** Claude Code, [OpenSpec](https://github.com/Fission-AI/OpenSpec) for planning larger changes, and Orca for handing a Large build to a worker agent.

---

## At a glance

```
  YOU                         AGENT                                   YOU
  ───                         ─────                                   ───
  /brief "what"     ──►  reads code, asks ≤3 questions,
                         proposes size + planned data flow     ──►  ■ Stop 1  "ok"
                         (Large only: writes an OpenSpec plan) ──►  ■ Stop 2  "ok"
                         builds, runs tests, reviews itself,
                         explains what it built                ──►  ■ Stop 3  retell + "done"
                         archives, pushes, opens PR with auto-merge,
                         watches the pipeline, cleans up
```

You type only at the stops: answers, questions, "ok", and "done". Between the stops the agent runs every step by itself.

---

## Quick start

### 1. Machine (once)

| Need | Why |
| --- | --- |
| Linux or macOS with `bash` and `jq` | The guard hook runs on every shell command and needs both |
| Node.js 20.19+ and `npm install -g @fission-ai/openspec@latest` | The `/opsx:*` commands call the `openspec` CLI |
| `gh` (GitHub) or `glab` (GitLab), logged in | Checking open PRs, opening PRs, watching pipelines |
| Orca app with Orchestration on (Settings → Experimental) | Large changes are built by a worker started through Orca |

### 2. Install into a project

1. Copy `.claude/` (without `settings.local.json`), `AGENTS.md`, and `HARNESS-SETUP.md` into the project.
2. Open Claude Code there and say: *"Read `HARNESS-SETUP.md` and follow it."* The agent then:
   - initializes OpenSpec;
   - removes the extra files OpenSpec generates;
   - hides unused skills;
   - asks you what the project is, which command checks it (tests, lint), and which rules the code does not show;
   - reports on your CI;
   - deletes `HARNESS-SETUP.md` when it is done.
3. Restart Claude Code and run the checks below.

### 3. Check it works

- `/memory` lists `AGENTS.md`. Never run `/init`: it creates a `CLAUDE.md`, and Claude Code then stops reading `AGENTS.md`.
- `/skills` shows `opsx:update` as user-only, and `opsx:propose`, `opsx:apply`, `opsx:archive` as available to Claude.
- Ask Claude to run `cat .env`: the hook blocks it. Ask for `git push --dry-run`: an approval prompt appears.
- In auto mode (`Shift+Tab`), run `/brief` on a tiny change. You should only need to answer at Stop 1 and Stop 3.
- On GitHub or GitLab, protect `main`: changes only through PR/MR, required pipeline, auto-merge allowed. This is the only guard nothing can bypass.

---

## The workflow, step by step

### Choosing the size

| Size | When | Who builds | Plan lives in | Stops |
| --- | --- | --- | --- | --- |
| **Trivial** | A typo, a rename, one line | Agent, directly | Nowhere | None |
| **Small** | One module, no behavior described in `openspec/specs/`, nothing risky | The agent in your session | `plans/<name>.md` | 1 and 3 |
| **Large** | Anything bigger, or anything touching **data migration or deletion, auth or permissions, a public API or contract, payments, or security settings** (even one line) | A worker through `orca-delegate` | `openspec/changes/<name>/` | 1, 2 and 3 |

If you ask for a change without `/brief`, the agent asks you to type `/brief <what>` and waits.

### ① Brief: `/brief <what, or an issue link>`

The agent:
1. **Checks the previous change.** If there are uncommitted changes or an open PR/MR, it stops and tells you. Only a `fix/` for broken production may start while another change is open. If the previous PR has merged, it cleans up the old branch.
2. **Reads** the code, `openspec/specs/`, and open changes, read-only. For a **bug**, it finds the root cause with evidence (`file:line`, input, wrong output). It never plans a fix for a guessed cause.
3. **Asks** at most three questions, each with its recommended answer.
4. **Sends Stop 1** in your language, in a fixed layout:

```
## signup-validation · Small (one module, nothing risky)

What:          Reject sign-ups with an invalid email
Why:           Bad emails bounce the welcome mail (proposed)
Out of scope:  Checking that the address exists
Done when:     An invalid email shows an error and nothing is saved
Cause:         (bugs only) the form skips validation, src/signup.ts:42

Planned flow:
  [Form] --email--> [Check format] --bad--> [Show error]
                         │ ok
                         ▼
                    (DB: users) --> [Send welcome mail]   ✗ mail fails → user still saved

Tasks:
  1. Add the format check. Verify: npm test -- signup
  2. Show the error under the field. Verify: manual check in the browser

Say ok and I will build it.
```

**The planned flow** follows the data, not the code: input, each step, where data is stored, output. It uses no file or function names, so you can judge it without reading code. It must show at least one `✗` failure path. When no data moves (docs, wording, one config value), it says `Flow: none (<reason>)`.

**■ Stop 1.** You check the brief, the flow, and the size (for Small, also the tasks), then say "ok". After that, the agent cuts the branch `feat|fix|chore/<name>` from an up-to-date `main`.

### ② Plan (Large only): `/opsx:propose <name>`

The agent writes `openspec/changes/<name>/`:
- `proposal.md`: the problem, the intent, and what is out of scope;
- `specs/`: requirements, each with WHEN/THEN scenarios;
- `design.md`: hard-to-reverse decisions and the data-flow diagram;
- `tasks.md`: small tasks, each with a check.

The rules for these files live in `openspec/config.yaml`.

**■ Stop 2.** The agent shows a 5–10 line summary plus the flow, and you approve it. You can also name a different model, for example "build with opus high". After Stop 2 it is a good moment to `/clear`: the plan holds the state.

### ③ Build

- **Small:** the agent builds it in your session.
- **Large:** `orca-delegate` starts a worker (default `claude` / `claude-sonnet-5-5` / `medium`) that runs `/opsx:apply`. The agent answers the worker's questions and checks that the worker only touched the files the plan lists.

Either way:
- only the tasks in the plan are touched;
- a task is ticked only after its `Verify:` passes, then committed as `feat: <task>`, `fix: <task>` or `chore: <task>`;
- the agent stops at once if the plan and the code disagree;
- a bug starts with a test that reproduces it and fails, before the fix;
- after the last task, the agent runs the project's `Verify:` line from `AGENTS.md` and fixes any failure.

### ④ Review

1. `/code-review low` (Small) or `/code-review medium` (Large) looks for correctness bugs.
2. `/ponytail-review` looks for over-engineering: what can be deleted or replaced by something that already exists.

Confirmed bugs are fixed without asking: they are written under `## Review fixes` in the plan and built, two rounds at most. Design, scope, and deletion findings wait for you at Stop 3.

### ⑤ Explain: `/explain-back <name>`

One screen, in your language, in this order:

| Part | What you get |
| --- | --- |
| Summary | **Before → now**, and what a user notices |
| Flow | The actual data flow, drawn like the planned one, with no code names |
| Example run | One concrete input traced step by step to what the user sees |
| Planned vs actual | One row per step: `file:line` and a mark: `✓` as planned, `⚠` differs, `+` added, `−` missing |
| Decisions | Up to five, each with its reason |
| Pending findings | Review findings and every flow difference, each with a recommendation (fix or skip) |

**■ Stop 3.**
- **Retell:** you tell the flow back in 2–3 sentences, including what happens when the riskiest step fails. The agent confirms what is right and corrects what is not, with the `file:line` to read. Say "skip" to skip.
- **Decide:** you ask questions and pick which findings to fix. Picked ones go back to Build.
- **Re-explain:** if something does not land, say so or type `/wait-what`, and the agent re-explains it more simply.

### ⑥ Done

When you say "done":
1. A Large change is archived (`/opsx:archive <name>`, "Sync now"), which merges its specs into `openspec/specs/`, and the archive is committed.
2. The agent pushes the branch (you approve the push) and opens a PR/MR with auto-merge.
3. It watches the pipeline and reports. If the pipeline fails, it fixes it on the same branch.
4. After the merge, it switches to `main`, pulls, and deletes the local branch.

Then `/clear` before the next change.

---

## What you type

| You type | When | What happens |
| --- | --- | --- |
| `/brief <what>` | Starting any non-trivial change or bug | Brief, questions, Stop 1 |
| answers, `ok` | At Stop 1 and Stop 2 | The agent continues to the next step |
| `build with <model> <effort>` | At Stop 2 | Overrides the worker model for this change |
| your retelling, questions, finding numbers | At Stop 3 | Checks your understanding; picked findings are fixed |
| `skip` | At the retell question | Skips the retell |
| `/wait-what` | Any time an answer is unclear | The agent re-explains its last message more simply |
| `done` | After Stop 3 | Archive, push, PR with auto-merge, cleanup |
| `/clear` | After done, or after Stop 2 on Large | Fresh context; the plan files hold the state |
| `/handoff` | The session is long but the change is not done | Writes a handoff note; paste its last line into a new session |

---

## Git and deploy

```
main ──●──────────●──────────●────  production: every merge deploys
       ↑ PR/MR    ↑ PR/MR    ↑ PR/MR   auto-merge once the verify jobs pass, then the deploy job runs
     feat/a     fix/b      feat/c      one change at a time, each cut from main after the previous merge
                                       (only a fix/ for broken production may start while another is open)
```

- `main` is the only long-lived branch, and it is production. Nobody pushes to it or merges into it locally.
- Each change gets one branch: `feat/<name>`, `fix/<name>`, or `chore/<name>`.
- One commit per verified task.
- **Rollback:** revert the bad merge on a `fix/` branch and ship it like any change. Use `git revert -m 1 <merge commit>`, or drop `-m 1` for a squash merge.

The commands the agent runs for one change:

```bash
git switch main && git pull --ff-only && git switch -c feat/<name>
# ... one commit per verified task ...
git push -u origin feat/<name>                        # after "done"; you approve the push
gh pr create --base main --fill && gh pr merge --auto --squash                            # GitHub
glab mr create --target-branch main --fill --yes && glab mr merge --auto-merge --squash  # GitLab
gh pr checks --watch     # or: glab ci status --live
git switch main && git pull --ff-only && git branch -D feat/<name>   # after the merge
```

Step 5 of `HARNESS-SETUP.md` checks that your CI has verify jobs and a deploy on `main`. The final step lists the GitHub and GitLab settings to turn on.

---

## Guardrails

| Layer | What it stops | Can be bypassed by |
| --- | --- | --- |
| **Deny rules** in `.claude/settings.json` | Claude's file tools reading `.env`, keys, and credentials, and editing `.env`, `CLAUDE.md`, `CLAUDE.local.md` | A script that opens the files itself |
| **Ask rule** in `.claude/settings.json` | Every `git push` waits for your approval | A push written in another form (the hook catches the common ones) |
| **Hook** `.claude/hooks/guard.sh` (bash + jq, runs before every shell command) | Commands that name a `.env` path, and `git <options> push` (for example `git -C dir push`), which would slip past the ask rule. If the hook fails, it blocks | A script or alias that hides the path or the push |
| **Protected `main`** on GitHub/GitLab with a required pipeline | Any direct push to `main`, and any merge whose checks fail | Only a repository admin |

Only the last layer is a hard limit. Without an OS sandbox a script can still read `.env`, so keep real secrets out of the working tree.

Use auto mode day to day. Use bypass permissions only for a long build you leave unattended.

No deny rule covers `.claude/settings.json` or `.claude/hooks/`, so the agent can edit its own guardrails. Review every diff to them before you commit it.

`AGENTS.md` also tells the agent: when a guardrail blocks something, report it and never work around it.

---

## What is in the repository

```
AGENTS.md                  the rulebook: sizes, workflow and stops, guardrails, git, reporting
HARNESS-SETUP.md           installer the agent follows once in a new project, then deletes
plans/<name>.md            a Small change: Brief, Flow, Tasks (each with Verify:), Review fixes
openspec/
  config.yaml              project context and rules for Large-change documents
  specs/                   what the system does today (filled by archiving Large changes)
  changes/<name>/          a Large change: proposal, specs, design, tasks
  changes/archive/         finished Large changes
.claude/
  settings.json            deny and ask rules, and the hook
  hooks/guard.sh           the shell-command guard
  skills/                  the workflow steps (table below)
  commands/opsx/           propose, apply, archive, update (generated by OpenSpec; do not edit)
```

| Skill | Step | Started by |
| --- | --- | --- |
| `brief` | ① Brief and Stop 1 | You (`/brief`) |
| `orca-delegate` | ③ Build, Large | The agent |
| `tdd` | ③ Build: how to write tests worth keeping | The agent |
| `ponytail-review` | ④ Review: over-engineering | The agent |
| `explain-back` | ⑤ Explain and Stop 3 | The agent |
| `wait-what` | Re-explain more simply | You or the agent |
| `handoff` | Move to a new session | You (`/handoff`) |

`/code-review` is built into Claude Code. `/opsx:*` come from OpenSpec.

---

## Context and token cost

**When to reset.** The agent cannot see how full its context is, so it suggests a reset at fixed points. You run the command, and `/context` shows usage at any time.

| When | Where the state is | Use |
| --- | --- | --- |
| After "done" | The plan and the PR | `/clear` |
| After Stop 2 on Large | `openspec/changes/<name>/` | `/clear`, then: "Build `<name>`; Stop 2 is approved." |
| Mid-Build, mid-Review, or Stop 3 half decided, when the session is long | Partly only in the conversation | `/handoff`, then paste its last line into the new session |

**What costs context, largest first:**
- **Generated `opsx` commands.** `propose.md` and `archive.md` are about 170 and 265 lines. `openspec update` regenerates them, so trimming them by hand does not last.
- **`/code-review` level.** It is pinned to `low` and `medium`; higher levels start many reviewer subagents.
- **The worker on Large.** It reads the change folder from scratch, and the agent spends turns answering it.
- **Skill descriptions.** They load every session. `HARNESS-SETUP.md` step 3 hides unneeded ones via `skillOverrides` in `.claude/settings.local.json`; hide more there or in `~/.claude/settings.json`.
- **The diff, read three times:** by `/code-review`, `/ponytail-review`, and `/explain-back`.

---

## Changing the harness

| To change | Edit |
| --- | --- |
| What counts as Small or Large, the stops, review levels, git rules | `AGENTS.md` (loaded every turn, so keep it short) |
| The brief, its questions, the Stop 1 layout, the planned flow | `.claude/skills/brief/SKILL.md` |
| Rules for Large-change documents (proposal, specs, design, tasks) | `openspec/config.yaml`, and the template copy in `HARNESS-SETUP.md` |
| Worker agent, model, effort | `.claude/skills/orca-delegate/SKILL.md` |
| The Stop 3 explanation | `.claude/skills/explain-back/SKILL.md` |
| Guardrails | `.claude/settings.json`, `.claude/hooks/guard.sh` |

To add a step, add a line under Workflow in `AGENTS.md` and a skill in `.claude/skills/<name>/SKILL.md`. Never edit `.claude/commands/opsx/*.md`.

**Project-specific rules.** Add one only after Claude repeats the same mistake. Create `.claude/rules/<topic>.md`. Claude Code reads only the `paths` frontmatter, and a rule without `paths` loads every session.

```markdown
---
paths:
  - "src/api/**"
---
Validate every request body and return the shared error shape.
```

Hard limits belong in `.claude/settings.json` or the hook. Mechanical rules (formatting, banned imports) belong in a linter or CI.

**Upgrading a project with an older harness.** Commit first. Then:
1. Replace `.claude/settings.json`, `.claude/hooks/`, and every harness skill, and delete harness skills that no longer exist (such as `grilling`).
2. Keep `openspec/`, `.claude/rules/`, and the project's own skills.
3. Copy in `AGENTS.md` and `HARNESS-SETUP.md`, and tell the agent it is an upgrade. It merges your project text from the old `AGENTS.md` (in git) and cleans `settings.local.json`.

---

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| Every shell command is blocked, naming `guard.sh` | `jq` is missing, or the hook failed or timed out (it fails closed) | Install `jq`. Then `echo '{"tool_input":{"command":"ls"}}' \| bash .claude/hooks/guard.sh; echo $?` should print `0` |
| Claude ignores `AGENTS.md` | A `CLAUDE.md` exists here or in a parent directory (often from `/init`) | Delete it; `/memory` should list `AGENTS.md` |
| `openspec: command not found` | The CLI is not installed globally | `npm install -g @fission-ai/openspec@latest` |
| Deleted skills or commands come back | `openspec update` regenerated them | Delete them again, or change the profile with `openspec config profile` first (untested) |
| A hidden skill shows up again | Its `skillOverrides` entry is missing, misspelled, or in the wrong file | Check `/skills`; template entries are in `.claude/settings.local.json`, yours in `~/.claude/settings.json` |
| `/brief` says it cannot check open PRs | `gh` or `glab` is missing or not logged in | Install it and log in; until then `/brief` skips that check |

---

## Notes

- `HARNESS-SETUP.md` is the single source for the install steps and the `openspec/config.yaml` template. Keep this repository's `openspec/config.yaml` in sync with it.
- In a project, `openspec init` also creates `.agents/` for Antigravity. Leave it in place.
