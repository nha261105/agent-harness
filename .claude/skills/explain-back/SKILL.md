---
name: explain-back
description: After Build and review, explain the change to the human in plain terms so they understand its flow before they decide the pending findings (Stop 3 of the workflow in AGENTS.md).
argument-hint: "<change-name> or plans/<name>.md"
---

Help the human understand what was built, then let them decide what is left. Follow these steps in order.

1. **Resolve the plan.** The argument names `openspec/changes/<name>/` or `plans/<name>.md`. When it is missing or ambiguous, list the candidates and ask.
2. **Read the change.** Read the plan and the diff of the change: `git diff` against the branch base plus the new files the tasks name. Without git, read the files the tasks name.
3. **Explain.** In plain words, with no jargon the repository does not already use:
   - **Summary:** what was built and why, in at most five lines.
   - **Flow:** one text diagram, entry point → each step → output or side effect, with `file:line` for each step.
   - **Decisions:** at most five key decisions, one line each with its reason.
   - **Pending findings:** the review findings kept for the human, numbered, each with your recommendation (fix or skip) and a one-line reason. Say "none" when there are none.
4. **One question (Large only).** Ask one question about the riskiest step in the flow: "If <step> fails or gets <unusual input>, what happens?" Give no hint, then wait. Do not grade the answer. When it matches the code, confirm it in one line; otherwise say what actually happens in at most two sentences, with the `file:line` to read. Skip this step for a Small change, or when the human says "skip".
5. **Open the floor.** Ask: "Anything still unclear, and which pending findings should I fix?" Answer questions until the human decides. Whenever the human signals that an explanation did not land, re-pitch it with the `wait-what` skill before going on.
6. **Edit no file in this skill.** Picked findings go under `## Review fixes` in the plan and back to Build, as `AGENTS.md` describes.
