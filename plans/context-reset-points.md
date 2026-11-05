# context-reset-points

## Brief

Add points in the workflow where the agent reminds the human to reset context: suggest `/clear` after the human says done (always) and after Stop 2 on a Large change; suggest `/handoff` when the human says the session is long between stops.
Why: long sessions dilute the model's context and cost more tokens. The agent cannot measure its own context or type `/clear`, so it only reminds at fixed points and the human runs the command.
`handoff` keeps saving to the OS temporary directory and stays user-only: real work runs on the human's own machine, where that file survives between sessions.
Done when the harness, copied into another repository, has the agent remind `/clear` and `/handoff` at these points during a real change (checked by the human).

## Tasks

- [x] 1. In `AGENTS.md`, extend the "When compacting, ..." sentence of `## Workflow`, without adding a line: after the human says done, suggest `/clear` before the next change; after Stop 2 on a Large change, suggest `/clear`, since the plan holds the state; when the human says the session is long between stops, suggest `/handoff`. Verify: Grep finds `/clear` and `/handoff` in `AGENTS.md`, and Read shows at most 40 lines.
- [x] 2. In `README.md` under `## How it works`, add a `### Context` subsection: a table of when to use `/clear` (all state is in files: after done, after Stop 2 on Large) and `/handoff` (state still only in the conversation: mid-Build, mid-Review, or Stop 3 with findings half decided), and the line to type in the new session after `/clear` at Stop 2. Point to `AGENTS.md` for the rule. Verify: Grep finds `### Context` in `README.md`, and it states no rule that `AGENTS.md` does not.
- [x] 3. Push the changed files and this plan to branch `claude/great-allen-czquc2` through the GitHub MCP tools (this cloud session's assigned branch, PR nha261105/agent-harness#2). Verify: the push returns a commit SHA.

## Review fixes

- [x] 4. `AGENTS.md` said "when the human says the session is long between stops", but the README table also lists Stop 3 with findings half decided, which is at a stop. Say "before the change is done" instead. Verify: Read of `AGENTS.md` line 15 ends with "before the change is done."
