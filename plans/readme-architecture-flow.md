# readme-architecture-flow

## Brief

Add to `README.md` a description of how the harness is built and how a change flows through it, so someone reusing the template understands it without reading every skill.
Cover: the layers of `.claude/` + `AGENTS.md` and when each one enters the agent's context; the full flow through the three stops for Small and Large; the token hotspots.
Write in English, describe and point to `AGENTS.md` instead of restating its rules, and add a Troubleshooting row for the hook on machines without `powershell.exe`.
Done when the new sections exist in `README.md`, every file they name exists, and they define no rule that `AGENTS.md` does not.

## Tasks

- [ ] 1. Add a `## How it works` section after the opening paragraph of `README.md`: a file tree of the harness, and a table of the layers (`AGENTS.md`, skill descriptions, skill and command bodies, `settings.json` + hook) with what each one does and when it costs context. Mark `brief`, `handoff` and `opsx:update` as not loaded until the human calls them. Verify: Grep finds `## How it works` in `README.md`, and every path in the tree matches a Glob result.
- [ ] 2. In the same section, add a text flow diagram from `/brief` through Stop 1, Plan, Stop 2, Build, Review, `/explain-back`, Stop 3, and archive or done, with the Small and Large branches and the skill or command loaded at each step. Point to `AGENTS.md` as the source of the rules. Verify: every step name in the diagram appears in `AGENTS.md` Workflow, and the diagram states no step or limit that `AGENTS.md` does not.
- [ ] 3. Add a `## Token cost` section listing the hotspots: the long generated `opsx` command files, `/code-review` reusing the last level typed, the second agent on Large, skill descriptions loaded every session (with the `skillOverrides` pointer already in the README), and the diff read three times across review and explain-back. Verify: Grep finds `## Token cost` in `README.md`, and each item names a file or setting that exists.
- [ ] 4. Add a Troubleshooting row: every Bash call is blocked on Linux, macOS, or Claude Code on the web because `powershell.exe` is missing and `onFailure: block` fails closed; the fix is the human's, since `.claude/settings.json` and `.claude/hooks/` are denied to the agent. Verify: Read of the Troubleshooting table shows the row, with the same column count as the other rows.
- [ ] 5. Push `README.md` and this plan to branch `claude/great-allen-czquc2` through the GitHub MCP tools (approved by the human, since the hook blocks every Bash call in this session). Verify: the MCP result returns a commit SHA on that branch.

## Review fixes
