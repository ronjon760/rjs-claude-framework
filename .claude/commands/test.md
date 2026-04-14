---
description: Write and run tests for your code — tests first, then implementation
---

Help the user write tests and verify their code works correctly. Follow a test-first approach: write the test before writing the code it tests.

## Workflow

### Step 1: Understand what to test
Ask the user what feature or fix they're working on. If they've already described it, confirm your understanding in plain language: "So we're testing that [thing] does [behavior] — right?"

### Step 2: Write the test first
Write a test that describes the expected behavior. The test should:
- Be in the project's existing test framework (Jest, Vitest, pytest, Go test, etc.)
- Follow the project's existing test file conventions
- Test the specific behavior the user described
- Include edge cases (empty inputs, missing data, error scenarios)

### Step 3: Run the test — it should fail
Run the test. It must fail. This proves the test is real — it's checking something that doesn't work yet.

If the test passes immediately, it means either:
- The feature already works (tell the user)
- The test isn't checking the right thing (fix the test)

### Step 4: Write the code
Write the minimum code needed to make the test pass. Don't over-engineer — just enough to satisfy the test.

### Step 5: Run the test again — it should pass
Run the test. If it fails, fix the code (not the test) until it passes.

### Step 6: Clean up
Review the code for any obvious improvements. Keep the tests green.

### Step 7: Save progress
Suggest running `/save` to commit the working test + implementation together.

## Rules
- Always use the project's existing test framework — don't introduce a new one
- Put test files where the project already keeps them (check for existing patterns first)
- Name tests clearly: describe what behavior they verify, not what function they call
- If no test framework exists yet, suggest one appropriate for the stack and offer to set it up
- Explain results in plain language: "3 tests passed — the login flow works correctly" not "3/3 assertions satisfied"
