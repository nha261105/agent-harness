---
name: explain-back
description: After Build and review, explain the change to the human in plain terms so they understand its flow before they decide the pending findings (Stop 3 of the workflow in AGENTS.md).
argument-hint: "<change-name> or plans/<name>.md"
---

Help the human understand what was built, then let them decide what is left. Follow these steps in order.

1. **Resolve the plan.** The argument names `openspec/changes/<name>/` or `plans/<name>.md`. When it is missing or ambiguous, list the candidates and ask.
2. **Read the change.** Read the plan, its planned flow (`## Flow` in `plans/<name>.md`, or the flow diagram in `design.md`), and the diff of the change: `git diff` against the branch base plus the new files the tasks name. Without git, read the files the tasks name.
3. **Explain.** In plain words, with no jargon the repository does not already use:
   - **Summary:** what was built and why, in at most five lines.
   - **Flow, planned against actual:** draw the actual flow from the diff in the same form as the planned one (follows the data, no code names), then list each step with its `file:line` and one mark: `✓` matches the plan, `⚠` differs (say how), `+` added without being planned, `−` planned but missing. When the plan has no planned flow, say so and draw only the actual one.
   - **Decisions:** at most five key decisions, one line each with its reason.
   - **Pending findings:** the review findings kept for the human, numbered, each with your recommendation (fix or skip) and a one-line reason. Add every `⚠`, `+`, or `−` step from the flow as a finding: the human either accepts it or has it fixed. Say "none" when there are none.
4. **Retell.** Ask the human to tell the flow back in two or three sentences in their own words, including what happens when <the riskiest step> fails or gets <unusual input>. Give no hint, then wait. Do not grade the answer. Confirm what matches the code in one line; for each part that does not, say what actually happens in at most two sentences, with the `file:line` to read. Skip this step only when the human says "skip".
5. **Open the floor.** Ask: "Anything still unclear, and which pending findings should I fix?" Answer questions until the human decides. Whenever the human signals that an explanation did not land, re-pitch it with the `wait-what` skill before going on.
6. **Edit no file in this skill.** Picked findings go under `## Review fixes` in the plan and back to Build, as `AGENTS.md` describes.
