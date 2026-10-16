---
paths:
  - "**/*.py"
---

# Python code

- Routes/views are thin: validate input, call a service, return a response. Business rules live in services; data access lives in models/repositories.
- Type-hint public functions. Use `snake_case` for files and functions, `PascalCase` for classes.
- Use the `logging` module, not `print()`, in application code.
- Tests live in `tests/`, mirroring the source layout, and run with `pytest`.
