---
name: brief
description: "Start a piece of work from the human's own words or an issue link: you ask at most three questions, then propose Small or Large."
disable-model-invocation: true
argument-hint: "what (why and done-when optional), or an issue link"
---

Turn the human's intent into a brief, then propose a size. Follow these steps in order.

1. **Check the previous change.** In a git repository, run `git status --short`, and when `origin` exists, list the human's open pull requests (`gh pr list --author @me --state open`) or merge requests (`glab mr list --author=@me`). When you are still on a branch whose pull or merge request has merged, clean up as the Git section of `AGENTS.md` says. When there are uncommitted changes or an open one, name it and stop: `AGENTS.md` starts the next change only after the previous one has merged, except a fix for broken production. When the tool is missing or not logged in, say so and go on.
2. **Get the intent.** Only "what" must come from the human: their own words, or an issue or ticket link they give, which you read. When there is no "what", ask for it and wait; never invent one. When why or done-when is missing, draft it from the code or the issue and mark it `(proposed)`. When the intent reports a bug, it is a fix and needs a cause (step 3).
3. **Read.** Read the code the intent touches, `openspec/specs/`, and the open changes in `openspec/changes/` (not `archive/`), read-only. Look facts up yourself and never ask the human for them. For a bug, find the root cause: reproduce it or trace it to the line that is wrong, and keep the evidence (`file:line`, input, wrong output). When you cannot find it, say what you checked and ask; do not plan a fix for a guessed cause.
4. **Ask.** Ask at most three numbered questions, only where the answer changes the plan. Follow each with `➡️` and your recommended answer plus a one-line reason. When nothing is open, say so and ask nothing.
5. **Size.** Pick Small or Large by the rule in `AGENTS.md` ("Choosing the path"), and a kebab-case `<name>` not already used in `plans/` or `openspec/changes/`.
6. **Stop 1.** After the answers, send one message in this order, in the human's language, so they can scan it:
   - A heading `<name> · Small` or `<name> · Large`, with the reason for the size in a few words.
   - The brief, one labelled line each: What, Why, Out of scope, Done when, and for a bug a fifth line, Cause, with its evidence.
   - The planned Flow.
   - Small: the tasks. Large: nothing more.
   - The closing line.

   The planned **Flow** is a text diagram of 3 to 8 lines that follows the data, not the code. Show the input, each step and what the data becomes, where it is stored, and the output or side effect. Use no file, function, or class names, so the human can judge it without reading code. Mark at least one failure path with `✗` and say what happens then (for example, what is left half done). When the change moves no data (documentation, wording, one config value), write `Flow: none (<reason>)` instead.
   - Small: add the numbered tasks, each in the form `N. <task>. Verify: <command or observable check>`. For a bug, task 1 adds a test that reproduces it and fails before the fix (the `tdd` skill), and a later task makes it pass. End with: "Say ok and I will build it." There is no Stop 2.
   - Large: end with: "Say ok and I will plan it."

   Then wait. Edit no file before the human says ok.
7. **After ok.**
   - In a git repository, cut the branch first, as the Git section of `AGENTS.md` says: `git switch main`, `git pull --ff-only` (when `origin` exists), then `git switch -c <feat|fix|chore>/<name>` (`fix` for a bug). Use the branch the environment assigns instead, when it assigns one.
   - Small: write `plans/<name>.md` with `## Brief`, `## Flow` (the planned flow from Stop 1, as the human approved it), `## Tasks` (the tasks as `- [ ]` checkboxes), and an empty `## Review fixes`, then continue with Build as `AGENTS.md` describes.
   - Large: run `/opsx:propose <name>` with the brief, the cause for a bug, and the planned flow as input, summarize the plan in 5–10 lines, show the flow diagram from `design.md`, and wait for the human to approve it (Stop 2).
