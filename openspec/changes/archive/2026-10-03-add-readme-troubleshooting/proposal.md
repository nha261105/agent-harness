# Proposal

## Why

When setup breaks (a missing CLI, an ignored `AGENTS.md`, skills reappearing), the only record of the cause and the fix is the chat history. `README.md` covers setup, reuse, and verification but nothing for when verification fails. A short troubleshooting section lets the human fix these four known failures without rediscovering them.

## What Changes

- Add one `## Troubleshooting` section to `README.md`, between `## Check it works` and `## Notes`.
- Write it in English as a three-column table (Symptom, Cause, Fix) covering exactly these four failures:
  1. `/opsx:*` reports `openspec: command not found`: the CLI is not installed globally; run `npm install -g @fission-ai/openspec@latest`.
  2. Claude Code ignores `AGENTS.md`: a `CLAUDE.md` (for example one created by `/init`) exists in the project directory or above it; remove it.
  3. A skill that was hidden shows up again or costs tokens: check `/skills`; `skillOverrides` for account and built-in skills live in `~/.claude/settings.json`, and the four `opsx:*` entries live in `.claude/settings.local.json`.
  4. Deleted skills or commands come back after `openspec update`: the global OpenSpec profile is still `core` with delivery `both`; delete the regenerated files again, or change the profile with `openspec config profile` before running `openspec update`.

## Capabilities

### New Capabilities

None. This change edits documentation only and alters no system behavior, so the change sets `skip_specs: true` in `.openspec.yaml`.

### Modified Capabilities

None.

## Impact

- Touches `README.md` only.
- No code, configuration, dependencies, or commands change.

## Out of scope

- Any other section of `README.md`.
- New files, and any change to `AGENTS.md`, `.claude/`, or `openspec/config.yaml`.
- Antigravity-specific failures (not yet verified).
- Behavior that is intended rather than faulty, such as `ask` prompts for `npx` and `npm install`.
- Verifying that `openspec config profile` resolves failure 4; the fix names it as an option, not a tested result.
