---
paths:
  - "**/lib/**"
---

# lib/ — shared foundation

- Shared helpers, services, constants, and types used by more than one feature.
- lib/ doesn't import from components/, app/, store/, or features/ — dependencies point inward.
- Search here before writing a new helper; extend an existing one instead of adding a near-duplicate.
- Keep service functions predictable: data in, result out, errors thrown or returned explicitly.
