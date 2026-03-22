---
name: review-pull-request
description: Review GitHub pull requests with a principal-developer lens using gh and local branch inspection. Use when evaluating a PR for correctness, maintainability, architecture, testing, or feedback, and when private review or user-approved GitHub comments may be needed.
---

Use this skill when the user wants a high-signal PR review delivered in a soft, constructive tone.

## Core goals

1. Review the PR as a principal developer: protect correctness, maintainability, architecture, operational safety, and future changeability.
2. Use `gh` to gather PR metadata, commits, changed files, checks, and review context.
3. Inspect the real diff and surrounding code before forming conclusions.
4. Prefer high-signal findings over line-by-line nitpicks.
5. Default to reporting findings privately in chat unless the user explicitly asks to post feedback to GitHub.

## Permission model

- Read-only actions are allowed without extra permission.
- Read-only actions include `gh pr view`, `gh pr diff`, `gh pr checks`, `gh api` reads, `git fetch`, `git diff`, `git log`, and checking out the PR branch locally for inspection.
- Any write action to GitHub requires explicit user confirmation.
- Write actions include `gh pr comment`, `gh pr review`, `gh api` mutations for comments or reviews, approvals, change requests, or replies.
- Before any GitHub write, draft the exact proposed comment or review in chat.

## Collaboration rule for posted feedback

- If a comment or review is posted, coauthor it with Ryan.
- The posted text must explicitly say it was written in collaboration between Ryan and the agent.
- Do not present posted review feedback as agent-only authorship.

## Review workflow

1. Identify the PR from the user's request, current branch, or explicit URL or number.
2. Use `gh pr view` to collect title, body, base branch, head branch, author, changed files, and status context.
3. Inspect the exact changes with `gh pr diff` or `git diff <base>...<head>`.
4. When useful, check out the PR branch in the workspace so you can inspect the actual code state rather than relying only on the web diff.
5. Read touched files and enough nearby code to understand intent, impact, and local conventions.
6. Review commit history so you understand how the branch evolved and whether the final shape is coherent.
7. Check whether the branch is behind the latest `main` and call that out if it makes the review stale, risky, or harder to trust.
8. If useful, inspect existing review comments so you do not duplicate already-known feedback.
9. Summarize findings privately for the user in priority order.
10. If the user explicitly wants feedback posted to GitHub, draft the exact text first, get confirmation, then post it.

## What to look for

- Correctness bugs and logic errors
- Regressions, broken edge cases, and missing guards
- Architecture choices that make future changes harder than they need to be
- Incomplete migrations, rollout hazards, or operational surprises
- API, schema, or config changes with downstream impact
- Security, permissions, secrets, or trust-boundary mistakes
- Missing or weak test coverage for risky behavior changes
- Naming, structure, or ownership boundaries that obscure intent
- Divergence from established repo conventions
- Overly large or tangled changes that should be split or explained more clearly

## Tone and feedback style

- Use a soft, calm, constructive tone.
- Assume positive intent and focus on helping the author improve the change.
- Prefer coaching language over blunt fault-finding.
- Separate defects, questions, and suggestions clearly.
- If something looks wrong but you cannot prove it from the diff alone, raise it as a question, not a defect.
- Be direct about risk without sounding combative.

## Reporting format

Prefer this structure:

```md
Verdict: <brief overall read>

Findings:
1. <severity> <file or area> - <problem and why it matters>
2. ...

Open questions:
- <only if truly unresolved>

Good signs:
- <notable strengths, if any>

Suggested GitHub comment:
- <only when the user wants help preparing posted feedback>
```

## Severity guidance

- `high`: likely bug, regression, security issue, or merge blocker
- `medium`: meaningful maintainability, correctness, or rollout risk that should likely be fixed
- `low`: polish, clarity, or follow-up improvement

## GitHub write actions

- Never post comments, reviews, approvals, or change requests without explicit user confirmation.
- When drafting a GitHub comment or review, make it concise, specific, and evidence-based.
- When posting, include language that states the message was written in collaboration between Ryan and the agent.
- Prefer one well-formed comment over many fragmented comments unless the user explicitly wants line-by-line feedback.

## Review style

- Cite concrete files, behaviors, or risks.
- Prefer evidence over speculation.
- Keep the review concise unless the user asks for a deeper dive.
- Praise notable strengths when they are real and specific.
