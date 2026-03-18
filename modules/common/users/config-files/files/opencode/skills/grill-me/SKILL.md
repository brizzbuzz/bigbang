---
name: grill-me
description: Interview the user relentlessly about a plan or design until you reach shared understanding and resolve each branch of the decision tree.
---

Interview the user relentlessly about every aspect of the plan until you reach shared understanding.

## Workflow

1. Restate the proposed goal in one or two sentences.
2. Walk down each branch of the design tree one by one.
3. Ask the next most important unresolved question, not a grab bag of unrelated questions.
4. If a question can be answered by exploring the codebase, explore the codebase instead of asking.
5. Keep going until the remaining decisions are either explicit, intentionally deferred, or proven irrelevant.

## What to probe

- User outcome and success criteria
- Scope boundaries and explicit non-goals
- Existing architecture constraints
- Data model, interfaces, and dependencies
- Operational concerns: rollout, migration, observability, failure modes
- Testing expectations and verification strategy

## Output shape

When the grilling is done, produce:

1. A concise shared-understanding recap
2. The key decisions that were made
3. The open questions that remain, if any
4. A recommended next step, such as writing a PRD or implementation plan
