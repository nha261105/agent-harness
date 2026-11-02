---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS - not the current workspace.

Start the document with a "Workflow state" section, so the next session can resume at the right stop of the workflow in `AGENTS.md`:

- the change name and its size (Small or Large);
- the path of the plan (`plans/<name>.md` or `openspec/changes/<name>/`);
- the last stop the human passed, and what they approved there;
- for Large, the Orca worker's terminal handle, when one is still live;
- pending review findings, and the human's decisions on them so far;
- the next step to run.

Write "no workflow in progress" when there is none. End the document with the line the human should paste into the new session: "Read <path of this file> and continue from Workflow state."

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
