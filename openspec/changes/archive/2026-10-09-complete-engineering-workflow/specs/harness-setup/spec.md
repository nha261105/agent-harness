# Spec Delta

## Purpose

Defines what following `HARNESS-SETUP.md` establishes in a target repository beyond OpenSpec initialization: the verify command agents rely on and a config check that catches OpenSpec warnings.

## ADDED Requirements

### Requirement: Setup records one verify command
Setup SHALL find one check command in the target repository from its manifests, task runners, or CI configuration, run it once, ask the human to confirm it, and write it to `AGENTS.md` as a single line `Verify: <command>`.

#### Scenario: Repository has checks
- **WHEN** the target repository defines test, lint, or typecheck commands
- **THEN** setup runs the chosen command once, shows its result, and after the human confirms writes `Verify: <command>` to `AGENTS.md`

#### Scenario: Human rejects the command
- **WHEN** the human rejects the proposed command
- **THEN** setup writes the command the human names instead, after running it once

### Requirement: Setup reports a missing verify command
When the target repository has no check command, setup SHALL report that in its final report and SHALL NOT write a `Verify:` line.

#### Scenario: No checks exist
- **WHEN** the target repository defines no test, lint, typecheck, or build command
- **THEN** the final report states that no verify command exists and `AGENTS.md` has no `Verify:` line

### Requirement: Config check fails on warnings
Setup's config check SHALL pass only when `openspec context --json` returns a `root` and OpenSpec prints no warning.

#### Scenario: Config has an invalid rule
- **WHEN** `openspec/config.yaml` contains a rule OpenSpec cannot parse
- **THEN** the config check fails and setup fixes the config before continuing
