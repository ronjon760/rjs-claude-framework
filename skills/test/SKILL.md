---
name: test
description: Write and run tests test-first (TDD) — write a failing test for the behavior, then the minimum code to make it pass. Use when the user asks to add tests, test a feature or bug fix, or build something "test-first", or when a change needs proof that it works.
argument-hint: optional feature or behavior to test
---

# Test first

Help the user prove their code works by writing the test before the code it tests.

What to test, if given: $ARGUMENTS

## Workflow

1. **Agree on the behavior.** If it's unclear, ask what feature or fix they're working on. Confirm in plain language: "So we're testing that [thing] does [behavior] — right?"
2. **Write the test first.** Use the project's existing test framework and file conventions (look at existing tests before writing). Test the specific behavior described, plus the edge cases that matter — empty inputs, missing data, error paths.
3. **Run it and watch it fail.** A failing test proves it's checking something real. If it passes straight away, either the feature already works (tell the user) or the test isn't checking the right thing (fix the test).
4. **Write the minimum code** to make it pass. Just enough to satisfy the test.
5. **Run it again.** If it fails, fix the code rather than weakening the test.
6. **Tidy up** with the tests staying green.
7. **Suggest `/rjs:save`** to commit the test and the code together.

## Beyond unit tests

Passing tests show the pieces work; they don't always show the running app works. When the change is user-facing — a page, a form, an API endpoint — suggest Claude Code's built-in `/verify` to confirm the behavior in the running app.

## Guidelines

- Stay with the project's existing test framework. If there isn't one, suggest one that fits the stack and offer to set it up.
- Put test files where the project already keeps them.
- Name tests after the behavior they verify, not the function they call.
- Report results in plain language: "3 tests passed — the login flow works correctly", not "3/3 assertions satisfied".
