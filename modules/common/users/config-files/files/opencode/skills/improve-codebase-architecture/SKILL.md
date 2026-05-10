---
name: improve-codebase-architecture
description: Explore a codebase for architectural friction, identify shallow-module pain, and propose deeper module boundaries that improve testability and agent navigation.
---

Use this skill to make a codebase easier to reason about, test, and evolve.

## Goals

- Find where understanding one concept requires bouncing between too many files.
- Identify shallow modules whose interface is almost as complicated as their implementation.
- Find seams where bugs hide in coordination logic rather than pure helper functions.
- Propose deeper, simpler boundaries.

## Semantic density contract

- Name the architectural force behind each recommendation: coupling, cohesion, ownership, data flow, lifecycle, trust boundary, deployment boundary, or test seam.
- Use concrete evidence: files, call paths, duplicated concepts, brittle invariants, hidden ordering requirements, or repeated agent navigation cost.
- Avoid vague architecture claims such as "cleaner" or "more maintainable" unless paired with the specific future change, test, or failure mode that becomes easier.
- Preserve tradeoffs. A strong recommendation should still name what it sacrifices.

## Workflow

1. Explore the codebase naturally and note where comprehension feels expensive.
2. Group friction into candidate refactor clusters.
3. Present the best candidates to the user before designing interfaces.
4. For the chosen candidate, describe the problem space and constraints.
5. Produce multiple interface options with different priorities.
6. Recommend the strongest option and explain why.
7. In this setup, prefer turning the chosen refactor into a Linear issue or RFC document.

## Candidate format

For each candidate, include:

- Cluster: the modules or concepts involved
- Why they are coupled
- What makes the current design shallow or brittle
- Test impact: what boundary tests become possible after the refactor
- Expected payoff: maintainability, correctness, speed, or agent navigability

## Interface design prompts

When producing options, aim for at least three distinct designs:

1. Minimum interface surface area
2. Maximum flexibility for extension
3. Fastest path for the common caller

Be opinionated in the recommendation. The user wants a strong read, not a menu with no guidance.
