# Tasks

All paths are relative to the repository root. Read `proposal.md`, `design.md`, and both files under `specs/` before starting. Run shell checks in PowerShell unless a task says otherwise.

## 1. Workflow skills

- [x] 1.1 Create `.claude/skills/brief/SKILL.md` with frontmatter `name: brief`, `description: Start a piece of work from the human's own words: they state the intent, you ask at most three questions, then propose Small or Large.`, `disable-model-invocation: true`, `argument-hint: "what, why, done when"`. Body, in this order:
  1. When the arguments do not state what, why, and when it is done, ask the human to write those 3–5 lines in their own words and wait. Never draft the intent for them.
  2. Read the code the intent touches, read-only. Look facts up yourself and never ask the human for them.
  3. Ask at most three numbered questions, only where the answer changes the plan, each followed by `➡️` with your recommended answer and a one-line reason. When nothing is open, say so and ask nothing.
  4. After the answers, restate the brief in at most five lines and propose Small (one module, no change to behavior described in `openspec/specs/`) or Large, with the reason. Name the next command: for Large `/opsx:propose <name>`; for Small, tell the human to say "plan it", and then write `plans/<name>.md`.
  5. The Small plan format is `## Brief` (the restated brief), `## Tasks` (checkboxes `- [ ] N. <task>. Verify: <command or observable check>`), and an empty `## Review fixes`. After writing it, name `/clear` and then "build plans/<name>.md".
  6. Edit no file before the human picks a size.

  Verify: `grep -cE "disable-model-invocation: true|at most three|Review fixes|plans/<name>.md" .claude/skills/brief/SKILL.md` prints at least 4.
- [x] 1.2 Create `.claude/skills/explain-back/SKILL.md` with frontmatter `name: explain-back`, `description: After Build, check that the human understands the flow of the change before review.`, `disable-model-invocation: true`, `argument-hint: "<change-name> or plans/<name>.md"`. Body, in this order:
  1. Resolve the plan: `openspec/changes/<name>/` or `plans/<name>.md`. When it is missing or ambiguous, list the candidates and ask.
  2. Read the plan and the diff of the change: `git diff` against the branch base plus new files the tasks name. Without git, read the files the tasks name.
  3. Show the flow as one text diagram (entry point → each step → output or side effect) with `file:line` per step, then at most five key decisions, one line each with its reason.
  4. Ask exactly two questions about the flow, not syntax: one on a failure path (what happens when a step fails or an unusual input arrives), one on a decision (why here and not elsewhere). Give no hint, then wait.
  5. Judge each answer as correct, partly correct, or wrong. For partly correct or wrong, give the right answer in at most two sentences with the `file:line` to read.
  6. Edit no file. End by naming `/code-review`.

  Verify: `grep -cE "disable-model-invocation: true|exactly two questions|file:line|/code-review" .claude/skills/explain-back/SKILL.md` prints at least 4.
- [x] 1.3 Delete `.claude/skills/grilling/`. Verify: `Test-Path .claude/skills/grilling` prints `False`.
- [x] 1.4 In `.claude/skills/tdd/SKILL.md`, delete the paragraph that starts "When the shape of that interface is itself in question", which names the uninstalled `codebase-design` skill. Verify: `grep -c codebase-design .claude/skills/tdd/SKILL.md` prints 0, and the `## Anti-patterns` heading still follows the "Ask: \"What's the public interface" paragraph.

## 2. Guardrails

- [x] 2.1 Create `.claude/hooks/guard.ps1`, compatible with Windows PowerShell 5.1, as described under "Hook runtime", "The hook forces the plain push form", and "The hook blocks `.env` only as a path token" in `design.md`. It reads stdin with `[Console]::In.ReadToEnd()`, parses it with `ConvertFrom-Json`, and takes `tool_input.command`. When the command is empty, it exits 0. It blocks (writes one line to stderr naming the rule, then `exit 2`) when either:
  - the command names a `.env` path token, using a regex equivalent to `(^|[\s"'/\\=])\.env(\.[\w.-]+)?(?=$|[\s"';|&)>])`; the message reads `Blocked by .claude/hooks/guard.ps1: .env files are off limits. Do not work around this; ask the human.`
  - `git` and `push` both appear as words and `push` is not directly after `git` (regex equivalent to `\bgit\b(?!\s+push\b).*\bpush\b`); the message reads `Blocked by .claude/hooks/guard.ps1: write the push as plain "git push ..." so the human gets the approval prompt.`

  Otherwise it exits 0. Verify by running each case with `'<json>' | powershell.exe -NoProfile -ExecutionPolicy Bypass -File .claude/hooks/guard.ps1; $LASTEXITCODE`, with `<json>` = `{"tool_name":"PowerShell","tool_input":{"command":"<cmd>"}}`. These must print 2: `Get-Content .env`, `type config\\.env.local`, `cat ./.env.example`, `git -C . push origin main`. These must print 0: `git push origin main`, `git status`, `grep -rn process.env.PORT src`, `python -m venv .venv`, and an empty command.
- [x] 2.2 Rewrite `.claude/settings.json`, keeping `$schema`:
  - `permissions.deny`: `Read(**/.env)`, `Read(**/.env.*)`, `Read(**/*.pem)`, `Read(**/*.key)`, `Read(secrets/**)`, `Read(~/.ssh/**)`, `Read(~/.aws/**)`, `Read(~/.config/gh/**)`, `Read(~/.git-credentials)`, `Read(~/.npmrc)`, `Edit(**/.env)`, `Edit(**/.env.*)`, `Edit(CLAUDE.md)`, `Edit(CLAUDE.local.md)`, `Edit(.claude/settings.json)`, `Edit(.claude/hooks/**)`.
  - `permissions.ask`: exactly `Bash(git push)`, `Bash(git push *)`, `PowerShell(git push)`, `PowerShell(git push *)`.
  - `enableAllProjectMcpServers`: `false`.
  - `hooks.PreToolUse`: one entry with matcher `Bash|PowerShell` and one handler: `type: "command"`, `command: "powershell.exe"`, `args: ["-NoProfile","-ExecutionPolicy","Bypass","-File","${CLAUDE_PROJECT_DIR}/.claude/hooks/guard.ps1"]`, `timeout: 10`, `onFailure: "block"`.

  This task removes the earlier `ask` entries for `rm`, `npm install`, `npx`, `orca orchestration worker-start`, and the `Edit` paths. Do it after 2.1: once saved, the agent can no longer edit this file. Verify: `Get-Content .claude/settings.json -Raw | ConvertFrom-Json` succeeds; `(… ).permissions.ask.Count` is 4; `deny` contains `Edit(.claude/settings.json)`; and `hooks.PreToolUse[0].hooks[0].onFailure` is `block`.
- [x] 2.3 In `.claude/skills/orca-delegate/SKILL.md`, replace "That command is in the `ask` list of `.claude/settings.json`, so the human confirms each launch." with "The human starts Build, so launch the worker only for the change and agent they named." 2.2 removes that `ask` entry, so the old sentence would be false. Verify: `grep -c "ask\` list" .claude/skills/orca-delegate/SKILL.md` prints 0.

## 3. Instructions and docs

- [x] 3.1 Replace the body of `AGENTS.md` below its maintainer comment, keeping the title, opening paragraph, and comment. Write these sections:
  - `## Choosing the path`: a single, plainly small edit goes straight through. Everything else starts with `/brief`, which ends with a Small or Large proposal; the human picks. Small: one module, no behavior that `openspec/specs/` describes; plan in `plans/<name>.md`. Large: `/opsx:propose <name>`. Keep the bug rule: find the root cause before changing product code, report cause, fix, and size, and the human picks the path.
  - `## Workflow`: keep the existing preamble ("The human controls every phase. Each phase starts when the human invokes it. When a phase ends, report the result, name the next command, and wait. When compacting, preserve the current phase, the change name, and what the human last approved."). Then the numbered phases:
    1. **Brief** (`/brief`).
    2. **Plan**: `/opsx:propose <name>` or `plans/<name>.md`. Done when the human approves; then name `/clear` and the Build command.
    3. **Build**: `/opsx:apply <name>` or "build plans/<name>.md"; another agent goes through Orca with `orca-delegate`. Work from the plan alone, edit only what its tasks name, tick a task only once its outcome is verified, and stop and ask when plan and code disagree. The human may switch on bypass permissions for this phase only. Done when every task is ticked; then name `/explain-back <name>`.
    4. **Explain-back** (`/explain-back <name>`): done when both questions are judged; then name `/code-review`.
    5. **Review** (`/code-review`, optionally `/ponytail-review`): the human picks findings. Append them as tasks under `## Review fixes` in the plan, then name the Build command again. With no fix left, name `/opsx:archive <name>` for Large (pick "Sync now") and then `/clear`.
  - `## Guardrails`: one paragraph. `.env` files and credentials are off limits, and every `git push` goes through the human's approval prompt. When a guardrail blocks a command, report it and do not work around it.
  - `## Gotchas` and `## Reporting`: unchanged.

  Verify: `(Get-Content AGENTS.md).Count` is at most 40; `grep -E "/brief|plans/<name>.md|/explain-back|Review fixes|Guardrails" AGENTS.md` matches each term; `grep -c grilling AGENTS.md` prints 0.
- [x] 3.2 Edit `HARNESS-SETUP.md`:
  - In step 2's check, replace the skill list with `brief`, `explain-back`, `handoff`, `orca-delegate`, `ponytail-review`, `tdd`, `wait-what`, and add "and `.claude/hooks/guard.ps1` exists".
  - In the Outcome list, add a bullet: "`.claude/settings.json` and `.claude/hooks/guard.ps1` are unchanged from the template."
  - In step 6's Vietnamese block, change item 4 to ``4. Thử `/brief`, rồi `/opsx:propose`, với một việc nhỏ.`` and add ``5. Trên GitHub, bật branch protection cho `main` (Settings → Branches): đây là lớp duy nhất chặn được mọi cách push.``

  Verify: `grep -c grilling HARNESS-SETUP.md` prints 0; `grep -cE "explain-back|guard.ps1|branch protection" HARNESS-SETUP.md` prints at least 3.
- [x] 3.3 Edit `README.md`:
  - In "Check it works", replace `/grilling` with `/brief`, and add a bullet: "In a session started with `claude --permission-mode bypassPermissions`, ask Claude to run `Get-Content .env`: the hook blocks it. Then ask for `git push --dry-run`: an approval prompt appears."
  - Add a `## Security model` section before `## Adding rules per project` with a three-row table (Layer, Stops, Can be bypassed by): deny rules; `guard.ps1` hook; GitHub branch protection (the only hard limit). Below the table add three sentences: without an OS sandbox, a script can still read `.env`, so keep real secrets out of the working tree; switch on bypass permissions only during Build; edits to `.claude/settings.json` and `.claude/hooks/` are the human's.
  - Add a Troubleshooting row: symptom "Every shell command is blocked and the message names guard.ps1"; cause "`powershell.exe` cannot run the hook, or the hook timed out, and `onFailure: block` fails closed"; fix "Run the hook by hand with a sample JSON (see the task list of change `redesign-harness-pair-workflow`) and fix the error it prints".

  Verify: `grep -c grilling README.md` prints 0; `grep -cE "Security model|guard.ps1|bypassPermissions" README.md` prints at least 3.
- [x] 3.4 Create `openspec/changes/archive/2026-10-09-complete-engineering-workflow/SUPERSEDED.md` with one paragraph: the outputs of this change (`plan-reviewer`, `verifier`, `review-change`, `grill-with-docs`, `domain-modeling`, the `diagnosing-bugs`/`surgical-patch` bug path, `/retro`) were rolled back by hand on 2026-10-09 and never synced to `openspec/specs/`; change `redesign-harness-pair-workflow` replaces its workflow. Verify: the file exists and `grep -c redesign-harness-pair-workflow` on it prints 1.

## 4. Integration check

- [x] 4.1 Confirm the change holds together end to end. Verify:
  - `openspec validate redesign-harness-pair-workflow --strict` passes.
  - `grep -rn "grilling" AGENTS.md README.md HARNESS-SETUP.md .claude` finds nothing.
  - Every skill or command named in `AGENTS.md` exists under `.claude/skills/` or `.claude/commands/opsx/`, or is built in (`/code-review`, `/clear`).
  - The hook cases in 2.1 still give the same exit codes.
  - Report as not checked: the bypass-mode check in `README.md` "Check it works", which needs the human to start a new session.
