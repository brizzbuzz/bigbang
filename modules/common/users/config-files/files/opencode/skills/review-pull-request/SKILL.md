---
name: review-pull-request
description: Review a GitHub pull request with gh, inspect the real diff and surrounding code, and report findings to the user without ever commenting on the PR.
---

Use this skill when the user wants a context-aware PR review delivered privately in chat.

## Core rules

1. Use `gh` to gather PR metadata, commits, changed files, and review context.
2. Read the actual diff and surrounding repository code before forming conclusions.
3. Optimize for high-signal findings: correctness, regressions, missing tests, unclear ownership, security, migration risk, and maintainability.
4. Report findings only to the user.
5. Never post comments, reviews, approvals, or status changes to the PR.

## Hard safety rule

Under no circumstance should you run commands like:

- `gh pr review`
- `gh pr comment`
- `gh api` mutations against pull request comments or reviews

This skill is strictly read-only with respect to the PR itself.

## Review workflow

1. Identify the PR from the user's request, current branch, or explicit URL/number.
2. Use `gh pr view` to collect title, body, base branch, head branch, author, and changed file list.
3. Use `gh pr diff` or `git diff <base>...<head>` to inspect the exact changes under review.
4. Read the touched files and enough nearby code to understand intent and impact.
5. Check commit history to understand how the branch evolved.
6. Check whether the PR branch is behind the latest `main` and call that out if it makes the review stale or harder to trust.
7. If useful, inspect existing review comments with `gh` so you do not duplicate already-known concerns, but do not reply to them.
8. Summarize findings for the user in priority order.

## What to look for

- Correctness bugs and logic errors
- Broken edge cases and missing guards
- Incomplete migrations or rollout hazards
- API, schema, or config changes with downstream impact
- Security and secret-handling mistakes
- Missing or weak test coverage for risky changes
- Overly large or hard-to-review changes that should be split
- Naming or structure problems that obscure intent
- Divergence from established repo conventions
- A stale branch that should be rebased onto the latest `main` before review or merge

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
```

## Severity guidance

- `high`: likely bug, regression, security issue, or release blocker
- `medium`: meaningful maintainability or correctness risk that should likely be fixed
- `low`: polish, clarity, or follow-up improvement

## Review style

- Be specific and cite concrete files or behaviors.
- Prefer evidence over speculation.
- If something looks wrong but you cannot prove it from the diff alone, call it out as a question, not a defect.
- Keep the review concise unless the user asks for a full deep dive.
