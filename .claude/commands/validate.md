---
description: Run yoda's lint + test gate (stylua + plenary) and fix failures in place. Use before marking any logical unit of work complete.
argument-hint: ""
---

# Validate

Run `make lint` and `make test` to validate the working tree. Fix any failures before reporting success.

**This command does:** run lint, run tests, diagnose failures, apply minimal fixes, re-run.

**This command does NOT:** stage, commit, push, modify `Makefile` / `stylua.toml`, or skip failing tests.

## Steps

1. **Lint.** Run `make lint`.
   - If it passes, continue to step 2.
   - If it fails with formatting violations, run `make format` once, then re-run `make lint`.
   - If it still fails (real style issues, not auto-fixable), report each violation with file:line and stop for user input.

2. **Test.** Run `make test`.
   - If all tests pass, report `✓ Validation passed — <N> tests, <duration>` and stop.
   - If any test fails, continue to step 3.

3. **Diagnose each failure.**
   - Read the failure output (assertion, traceback, missing module, mocked dependency).
   - Identify the root cause. Never edit a test to pass unless the test is provably wrong — the implementation is the default suspect.
   - Apply the minimal fix.
   - Re-run `make test`.

4. **Iteration cap.** Stop after **3 unsuccessful fix attempts on the same failing test**. Report the remaining failure with diagnosis and attempted fixes — do not loop further. Escalate to the `nvim-debugger` agent.

5. **Final state.** Either:
   - `✓ Validation passed` with test count and duration, or
   - `✗ <test-name> remains failing after N attempts` with the diagnosis.

## Rules

- Never modify a test to make it pass without proving the test was wrong.
- Never `pending()`, `it.skip()`, comment out, or otherwise bypass a failing test.
- Never edit `Makefile`, `stylua.toml`, or `tests/minimal_init.lua` to make a failure go away.
- Never commit, stage, or push from this command.
- Lint failures inside `lua/utils/yaml_parser.lua` or `lua/utils/config_loader.lua` are expected to be skipped by `stylua.toml` (goto labels) — if stylua flags them, the config is the bug, not the file.

## When to run

- After completing a feature, bug fix, or refactor
- Before marking any TODO.md item complete
- Before opening a PR
- After any change to `lua/plugins/`, `lua/yoda/`, or test infrastructure

Skip (per `CLAUDE.md`) for: single-line edits, doc-only changes, whitespace, `.gitignore` tweaks, intermediate steps in a multi-step task.
