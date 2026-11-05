---
name: brief
description: "Start a piece of work from the human's own words or an issue link: you ask at most three questions, then propose Small or Large."
disable-model-invocation: true
argument-hint: "what (why and done-when optional), or an issue link"
---

Turn the human's intent into a brief, then propose a size. Follow these steps in order.

1. **Get the intent.** Only "what" must come from the human: their own words, or an issue or ticket link they give, which you read. When there is no "what", ask for it and wait; never invent one. When why or done-when is missing, draft it from the code or the issue and mark it `(proposed)`.
2. **Read the code.** Read the code the intent touches, read-only. Look facts up yourself and never ask the human for them.
3. **Ask.** Ask at most three numbered questions, only where the answer changes the plan. Follow each with `➡️` and your recommended answer plus a one-line reason. When nothing is open, say so and ask nothing.
4. **Size.** Large when the work spans more than one module, changes behavior `openspec/specs/` describes, or touches data migration or deletion, auth or permissions, a public API or contract, payments, or security settings, even in one file. Otherwise Small. Pick a kebab-case `<name>`.
5. **Stop 1.** After the answers, restate the brief in four lines (What, Why, Out of scope, Done when) and give the size with its reason.
   - Small: add the numbered tasks, each in the form `N. <task>. Verify: <command or observable check>`. End with: "Say ok and I will build it." There is no Stop 2.
   - Large: end with: "Say ok and I will plan it."

   Then wait. Edit no file before the human says ok.
6. **After ok.**
   - Small: write `plans/<name>.md` with `## Brief`, `## Tasks` (the tasks as `- [ ]` checkboxes), and an empty `## Review fixes`, then continue with Build as `AGENTS.md` describes.
   - Large: run `/opsx:propose <name>` with the brief as input, summarize the plan in 5–10 lines, and wait for the human to approve it (Stop 2).
