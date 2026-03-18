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

Prefer a no-probing happy path for commit signing:

1. Inspect the effective Git configuration first with `git config --get gpg.format`, `git config --get gpg.ssh.program`, and `git config --get user.signingkey`.
2. If `gpg.ssh.program` points at the 1Password signer, let `git commit` use it directly instead of trying to discover an SSH agent first.
3. Only diagnose `SSH_AUTH_SOCK` when an SSH transport operation needs it (`git push`, `gh`, `ssh`) or when signing still fails after confirming the Git config.
4. Do not disable signing unless the user explicitly asks for it.

If an SSH transport command fails because the default agent has no identities:

1. Inspect the current `SSH_AUTH_SOCK`.
2. Verify identities are visible with `ssh-add -L` against the current socket.
3. If that still fails, then inspect `~/.ssh/config` for `IdentityAgent` entries.
4. Retry the relevant `git`, `gh`, or `ssh` command with `SSH_AUTH_SOCK` pointed at the working socket.

Prefer discovery in this order:

1. Effective Git signing configuration
2. The current `SSH_AUTH_SOCK`
3. `IdentityAgent` from `~/.ssh/config` as a last-resort diagnostic

Do not read files outside the workspace during the happy path when Git is already configured to use the 1Password signer directly.

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
