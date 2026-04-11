---
description: Share your work for review — creates a pull request on GitHub
argument-hint: optional title for the pull request
---

Create a pull request (PR) so collaborators can review the work.

A pull request is like raising your hand and saying "I made some changes — can you look at them before we add them to the main project?"

Steps:
1. Check if there are uncommitted changes — if so, run /save first
2. Check if the current branch has been pushed — if not, push it
3. Check if a PR already exists for this branch — if so, tell the user and share the link
4. If no PR exists, create one:
   a. Use the user's title if provided, otherwise generate a short descriptive title
   b. Write the PR description in plain language with these sections:

      ## What this does (the simple version)
      [1-2 sentence summary anyone can understand]

      ### What changed
      [Bullet points explaining each change in plain language — no jargon]

      ### Why we did it
      [Why these changes matter]

      ### What this means for you
      [What's different for users or developers going forward]

   c. Create the PR using `gh pr create`
5. Share the PR link with the user

Important:
- Follow the plain-language communication rule from PROJECT_LESSONS.md
- Explain technical concepts in parentheses if they must be mentioned
- The PR description should be understandable by someone who doesn't code
