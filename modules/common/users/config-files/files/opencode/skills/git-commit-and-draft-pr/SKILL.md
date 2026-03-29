---
name: git-commit-and-draft-pr
description: Create signed conventional commits, rely on the default SSH credentials when transport is needed, then push the branch and open a draft GitHub PR with gh.
---

Use this skill when the user wants to wrap up a branch for review with a clean conventional commit and optionally a draft PR.

## Goals

- Preserve the user's conventional commit workflow
- Keep commit signing enabled
- Prefer the default SSH credentials already configured for the environment
- Start feature work from the latest `main` whenever possible
- Push with standard `git`
- Open a draft PR with `gh`

## What this skill does

- Reviews the current branch state and summarizes what changed
- Proposes a conventional commit message that matches the repository style
- Creates a signed commit without weakening the user's signing rules
- Diagnoses SSH transport failures with minimal probing and no parallel auth workflow
- Pushes the branch and creates a draft PR when the user explicitly asks for a PR

## Commit workflow

1. Inspect the current branch, staged state, and diff.
2. Check whether the branch is based on the latest `origin/main`.
3. If the work has not started yet, prefer creating a fresh branch from the latest `main`.
4. If the branch already exists and is stale relative to `main`, prefer rebasing it onto the latest `origin/main` before opening a PR.
5. Summarize the changes in terms of intent, not just files touched.
6. Draft a conventional commit message that matches the repo's history.
7. Stage the relevant changes.
8. Create a signed commit without disabling signing.

## Branching rule

For GitHub workflows in this environment, prioritize working from the latest `main`.

- Before creating a new branch, fetch `origin/main` and branch from that tip.
- Before opening a PR from an existing branch, check whether it has drifted behind `origin/main`.
- If it is behind, prefer rebasing onto `origin/main` so the PR diff is as current and reviewable as possible.
- Do not leave a feature branch intentionally based on an old feature branch unless the user explicitly wants a stacked PR.

### Commit message guidance

- Prefer `feat:`, `fix:`, or `chore:`
- Include scope when it clarifies the change
- Focus on why the change exists
- Keep the subject concise and in imperative mood

## SSH and signing workflow

Prefer a no-probing happy path for commit signing and transport:

1. Inspect the effective Git configuration first with `git config --get gpg.format`, `git config --get gpg.ssh.program`, and `git config --get user.signingkey`.
2. Let `git commit` use the configured signer directly instead of trying to outsmart the existing Git setup.
3. For `git push`, `git fetch`, `gh`, or `ssh`, assume the environment's default SSH credentials should work first, whether they come from an agent-backed interactive setup or a headless `~/.ssh/config` plus key files.
4. Do not disable signing unless the user explicitly asks for it.

If an SSH transport command fails:

1. Verify that the default SSH path works with a direct command like `ssh -T git@github.com` or `git ls-remote origin`.
2. If the default path fails in an interactive environment, inspect `SSH_AUTH_SOCK` and verify identities with `ssh-add -L`.
3. If the default path fails in a headless environment, inspect `~/.ssh/config`, `IdentityFile`, and the expected key files before assuming an agent exists.
4. Retry the relevant `git`, `gh`, or `ssh` command with the minimal override needed, such as `git -c core.sshCommand='ssh -F ~/.ssh/config' ...`.

Prefer discovery in this order:

1. Effective Git signing configuration
2. Default SSH connectivity with no overrides
3. The current `SSH_AUTH_SOCK` when an interactive agent is expected
4. `~/.ssh/config` and default key files when a headless or file-based setup is expected

Do not read files outside the workspace during the happy path when Git and SSH already work with their default configuration.

## Draft PR workflow

Only do this when the user has explicitly asked to create a PR.

1. Confirm the branch state with `git status`, `git log`, and `git diff origin/main...HEAD`.
2. Confirm the branch is based on the latest practical `origin/main`; if not, prefer rebasing before pushing.
3. Push the current branch with `git push -u origin <branch>`.
4. Use `gh pr create --draft`.
5. Write a concise PR body with:
   - Summary
   - Validation steps
   - Deployment notes when relevant
6. Return the PR URL.

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
- If signing or transport fails, prefer small SSH config diagnostics over inventing a parallel auth workflow.
