---
name: git-commit-and-draft-pr
description: Create signed conventional commits, discover the active 1Password SSH agent when needed, then push the branch and open a draft GitHub PR with gh.
---

Use this skill when the user wants to wrap up a branch for review with a clean conventional commit and optionally a draft PR.

## Goals

- Preserve the user's conventional commit workflow
- Keep commit signing enabled
- Discover and use the active 1Password SSH agent for signing when needed
- Push with standard `git`
- Open a draft PR with `gh`

## What this skill does

- Reviews the current branch state and summarizes what changed
- Proposes a conventional commit message that matches the repository style
- Creates a signed commit without weakening the user's signing rules
- Diagnoses SSH signing failures by discovering the right 1Password agent socket from the local environment
- Pushes the branch and creates a draft PR when the user explicitly asks for a PR

## Commit workflow

1. Inspect the current branch, staged state, and diff.
2. Summarize the changes in terms of intent, not just files touched.
3. Draft a conventional commit message that matches the repo's history.
4. Stage the relevant changes.
5. Create a signed commit without disabling signing.

### Commit message guidance

- Prefer `feat:`, `fix:`, or `chore:`
- Include scope when it clarifies the change
- Focus on why the change exists
- Keep the subject concise and in imperative mood

## 1Password signing workflow

If `git commit` fails because SSH signing is enabled but the default agent has no identities:

1. Inspect the local environment instead of assuming a fixed path.
2. Check `~/.ssh/config` for `IdentityAgent` entries.
3. If needed, inspect the current `SSH_AUTH_SOCK` and compare it with the configured agent socket.
4. Verify identities are visible with `ssh-add -L` against the candidate socket before retrying the commit.
5. Run the relevant `git` or `gh` command with `SSH_AUTH_SOCK` pointed at the working socket.
6. Do not disable signing unless the user explicitly asks for it.

Prefer discovery in this order:

1. `IdentityAgent` from `~/.ssh/config`
2. The current `SSH_AUTH_SOCK`
3. A direct check that the candidate socket exposes the expected signing identity

Do not hardcode one machine's socket path into the workflow if it can be discovered at runtime.

## Draft PR workflow

Only do this when the user has explicitly asked to create a PR.

1. Confirm the branch state with `git status`, `git log`, and `git diff origin/main...HEAD`.
2. Push the current branch with `git push -u origin <branch>`.
3. Use `gh pr create --draft`.
4. Write a concise PR body with:
   - Summary
   - Validation steps
   - Deployment notes when relevant
5. Return the PR URL.

## PR body template

```md
## Summary
- <high-value change>
- <high-value change>

## Validation
- `<command>`
- `<command>`

## Deployment Notes
- <note, or say none>
```

## Safety rules

- Never use `--no-gpg-sign` or similar bypass flags unless the user explicitly requests it.
- Never force-push unless the user explicitly requests it.
- Prefer standard `git` workflows; do not assume GitButler or any alternate VCS tooling.
- If signing fails, diagnose the agent socket first rather than weakening the workflow.
