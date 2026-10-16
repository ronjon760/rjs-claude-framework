# Security baseline (applies everywhere)

- Secrets come from environment variables. Add every new variable to `.env.example` with a placeholder value, never a real one.
- Treat all input — request bodies, query strings, uploaded files, webhook payloads, LLM output — as untrusted. Validate it at the boundary.
- Check authorization on the server for every action that reads or changes someone's data, not just in the UI.
- Use parameterized queries or the ORM; never build SQL or shell commands from strings containing user input.
- Don't log passwords, tokens, or personal data.
- When adding a dependency, prefer well-maintained packages and say why it's needed.
- Changes to login, payments, permissions, file uploads, or data exports deserve a `/security-review` before merging.
