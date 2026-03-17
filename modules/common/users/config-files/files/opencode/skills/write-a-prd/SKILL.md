---
name: write-a-prd
description: Turn a feature discussion into a structured PRD by interviewing the user, exploring the codebase, and recording the result in Linear.
---

Use this when the user wants to define a feature clearly before implementation.

## Workflow

1. Ask the user for a detailed description of the problem, constraints, and any solution ideas.
2. Explore the repo to verify assumptions and understand the current implementation.
3. Load and apply the `grill-me` skill if the plan is still fuzzy or underspecified.
4. Sketch the major modules, boundaries, and interface changes that would be required.
5. Confirm which behaviors deserve testing and where deep modules would simplify the design.
6. Write the PRD using the template below.
7. In this setup, prefer saving the PRD as a Linear document. If a linked issue is more useful, create one and link it to the document.

## PRD template

```md
## Problem Statement

Describe the user's problem from the user's point of view.

## Solution

Describe the proposed solution from the user's point of view.

## User Stories

1. As a <actor>, I want a <feature>, so that <benefit>

Include a long, concrete, numbered list that covers normal flows, edge cases, and operational realities.

## Implementation Decisions

- Major modules to build or modify
- Interface changes
- Architectural decisions
- Schema or contract changes
- Notable tradeoffs

Avoid brittle file-path-level detail unless the user explicitly asks for it.

## Testing Decisions

- Which behaviors matter most
- Which boundaries should be tested
- What good tests look like for this feature
- Prior art in the repo worth copying

## Out of Scope

Call out what this PRD intentionally does not cover.

## Further Notes

Any rollout, migration, UX, or operational notes.
```

## Linear guidance

- Prefer `linear_create_document` for the PRD artifact when available.
- Attach the document to the relevant project or issue when that context exists.
- If a matching project or initiative already exists, reuse it instead of creating a new one.
