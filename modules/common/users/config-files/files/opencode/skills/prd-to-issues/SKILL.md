---
name: prd-to-issues
description: Break a PRD into independently grabbable Linear issues using tracer-bullet vertical slices and explicit dependencies.
---

Break a PRD into thin, end-to-end slices that can be implemented and verified independently.

## Workflow

1. Locate the PRD. In this setup, prefer a Linear document, but a Linear issue or pasted PRD also works.
2. Read the PRD and explore the codebase enough to understand its integration points.
3. Draft vertical slices, not horizontal layer-by-layer tasks.
4. Present the proposed slices to the user for critique.
5. Refine until the granularity and dependency graph feel right.
6. Create the approved slices as Linear issues in dependency order.

## Vertical slice rules

- Each slice must cut through every necessary layer end to end.
- Each slice should be demoable or verifiable on its own.
- Prefer many thin slices over a few thick ones.
- Mark slices as AFK when an agent can complete them independently.
- Mark slices as HITL when they require design review, policy decisions, or human sign-off.

## Review format

Present each slice with:

- Title
- Type: AFK or HITL
- Blocked by
- User stories covered
- One-sentence explanation of what becomes demonstrably true after the slice lands

## Linear issue template

```md
## Parent PRD

<Linear document or issue reference>

## What to build

Describe the end-to-end behavior for this slice.

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

List prerequisite Linear issues, or say that it can start immediately.

## User Stories Addressed

- User story 3
- User story 7
```

## Linear guidance

- Reuse the relevant project, initiative, and labels if they already exist.
- Encode dependency relationships with blocking links when available.
- Keep titles short, specific, and implementation-ready.
