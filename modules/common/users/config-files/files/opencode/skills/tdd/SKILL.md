---
name: tdd
description: Execute work with a strict red-green-refactor loop that tests behavior through public interfaces instead of implementation details.
---

Use test-driven development to improve implementation quality and keep the agent focused on externally visible behavior.

## Core principle

Tests should verify behavior through public interfaces, not implementation details. A refactor should not break a good test unless the observable behavior changed.

## Workflow

### 1. Plan before coding

- Confirm the public interface or behavior that will change.
- Confirm which behaviors matter most and deserve tests.
- Identify opportunities for deep modules with small interfaces and rich implementations.
- Decide what the first tracer bullet should prove.

### 2. Work one vertical slice at a time

For each behavior:

1. Write one failing test for one behavior.
2. Run the test and observe it fail.
3. Write the minimum code needed to make it pass.
4. Run the relevant tests again.
5. Repeat with the next behavior.

Do not write all tests first. Do not write speculative implementation ahead of the current failing test.

### 3. Refactor only at green

Once tests pass:

- Remove duplication
- Deepen shallow modules
- Simplify interfaces
- Improve naming and structure
- Re-run tests after each meaningful refactor step

Never refactor while red.

## Good test checklist

- Tests observable behavior
- Uses public interfaces only
- Would survive internal refactoring
- Avoids mocking internal collaborators unless there is a real boundary
- Reads like a specification of system behavior

## Per-cycle checklist

- One new behavior
- One new failing test
- Minimal passing implementation
- No speculative extras
- Fast feedback loop
