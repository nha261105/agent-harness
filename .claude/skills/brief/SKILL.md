---
name: brief
description: "Start a piece of work from the human's own words: they state the intent, you ask at most three questions, then propose Small or Large."
disable-model-invocation: true
argument-hint: "what, why, done when"
---

Turn the human's intent into a brief, then propose a size. Follow these steps in order.

1. **Get the intent.** When the arguments do not state what, why, and when it is done, ask the human to write those 3–5 lines in their own words, then wait. Never draft the intent for them.
2. **Read the code.** Read the code the intent touches, read-only. Look facts up yourself and never ask the human for them.
3. **Ask.** Ask at most three numbered questions, only where the answer changes the plan. Follow each with `➡️` and your recommended answer plus a one-line reason. When nothing is open, say so and ask nothing.
4. **Propose a size (Stop 1).** After the answers, restate the brief in at most five lines and propose Small (one module, no change to behavior described in `openspec/specs/`) or Large, with the reason and a kebab-case `<name>`. End with: "Say ok and I will plan it." Then wait.
5. **Plan.** When the human says ok:
   - Large: run `/opsx:propose <name>` with the brief as input.
   - Small: write `plans/<name>.md` with three sections:
     - `## Brief`: the restated brief.
     - `## Tasks`: checkboxes in the form `- [ ] N. <task>. Verify: <command or observable check>`.
     - `## Review fixes`: empty.

   Then summarize the plan in 5–10 lines and wait for the human to approve it (Stop 2). After approval, continue with Build as `AGENTS.md` describes.
6. **No edits early.** Edit no file before the human says ok at Stop 1.
