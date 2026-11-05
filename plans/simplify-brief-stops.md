# simplify-brief-stops

## Brief

What: Simplify the brief and its stops: (1) merge Stop 1 and Stop 2 for Small (one message with brief, size, and tasks; one "ok"); (2) add risk-based sizing (data migration or deletion, auth or permissions, a public API or contract, payments, security settings → Large, even in one file); (3) add an `Out of scope:` line to the brief; (4) accept an issue or ticket link as the intent; (5) run the project `Verify:` line after the last task, before Review; (6) only "what" must come from the human; the agent drafts a missing why or done-when and marks it `(proposed)`.
Why: Fewer "ok"s and less retyping on small work, and safer sizing.
Out of scope: Large's two stops, review gating (change B), the `explain` rename and Surgical Changes (change C), the hook (change A), OpenSpec commands.
Done when: `.claude/skills/brief/SKILL.md`, `AGENTS.md` ("Choosing the path" and Workflow steps 1–3), and the README Flow describe exactly these six points, and `AGENTS.md` stays about its current length.

## Tasks

- [x] 1. Rewrite `.claude/skills/brief/SKILL.md`: intent needs only "what" from the human, in their words or as an issue/ticket link the agent reads; a missing why or done-when is drafted and marked `(proposed)`; the restated brief has What, Why, Out of scope, Done when; sizing includes the risk list; Small ends Stop 1 with the brief, size, and numbered tasks with `Verify:` in one message, and after "ok" writes `plans/<name>.md` and builds; Large keeps `/opsx:propose` and Stop 2; no file edits before "ok". Verify: Grep finds `(proposed)`, `Out of scope`, `issue`, and `migration` in the skill, and Read shows no step asking the human to approve a Small plan a second time.
- [x] 2. Edit `AGENTS.md`: add the risk list to "Choosing the path"; in Workflow, say Small has two stops (Stop 1 covers brief, size, and tasks) and Large has three; step 2 plans only Large; step 3 runs the `Verify:` line after the last task, when one exists, and fixes failures before Review. Verify: Grep finds `migration` and `Verify:` in `AGENTS.md`, Read shows no rule that contradicts the skill, and the file has at most 3 more lines than before.
- [x] 3. Update the README `### Flow` diagram (and any line in `README.md` that says Small has three stops or that the brief needs what, why, and done-when) to match tasks 1–2. Verify: Read of the Flow block shows Small going from Stop 1 straight to Build, and Grep finds no `what, why, done when` argument hint left in `README.md`.
- [x] 4. Push the changed files and this plan to branch `claude/practical-planck-udd0is` through the GitHub MCP tools (Bash is blocked by the hook; change A fixes that). Verify: the push returns a commit SHA.

## Review fixes

- [x] 5. The risk list in `.claude/skills/brief/SKILL.md` step 4 repeats `AGENTS.md` "Choosing the path"; point to `AGENTS.md` instead. Verify: Grep finds `migration` in `AGENTS.md` and not in the skill.
- [x] 6. `HARNESS-SETUP.md` step 7 still tells the human to say "ok" at 3 stops; say Stop 1 and Stop 3 for a Small change. Verify: Grep finds no `3 điểm dừng` in `HARNESS-SETUP.md`.
