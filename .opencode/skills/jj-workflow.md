# Jujutsu (jj) Version Control Workflow Skill

## Overview

This skill enables AI agents to effectively use Jujutsu (jj) for version control operations during development workflows. Jujutsu is a Git-compatible VCS that simplifies common workflows while maintaining full Git interoperability.

## Core Principles

1. **Work locally, push only with permission** - Agents should freely use jj for local version control but NEVER push to remotes without explicit user approval
2. **Describe work clearly** - Always provide detailed commit descriptions that explain the "why" behind changes
3. **Use operation log as safety net** - jj's operation log (`jj op log`) makes all operations reversible
4. **Keep working copy clean** - Regularly create new changes to organize work logically

## Key Concepts

### Changes vs Commits
- In jj, you work on **changes** (evolving pieces of work) rather than creating discrete commits
- The working copy (`@`) is always a change that can be described and refined
- Use `jj new` to start a new change when beginning a different logical unit of work

### Bookmarks (Branches)
- Jujutsu calls branches "bookmarks"
- Use `jj bookmark create <name>` instead of `git branch <name>`
- Bookmarks are just labels pointing to changes

### Operation Log
- Every jj operation is recorded in the operation log
- Use `jj op log` to see history of operations
- Use `jj undo` to reverse the last operation
- Operations are completely safe - you can't lose work

## Common Workflows

### 1. Starting Work on Changes

```bash
# Check current status
jj status

# View current change
jj log -r @

# Start working - files automatically tracked
# Edit files...

# Describe your work (can be done anytime)
jj describe -m "feat: add feature description

Detailed explanation of what changed and why.
Follows conventional commit format."

# Create a new change for next task
jj new
```

### 2. Organizing Multiple Changes

```bash
# Create multiple logical changes
jj new  # First feature
# ... edit files ...
jj describe -m "feat: first feature"

jj new  # Second feature
# ... edit files ...
jj describe -m "feat: second feature"

# View your stack
jj log

# Move between changes
jj edit <change-id>
```

### 3. Creating Bookmarks and Pull Requests

```bash
# Create a bookmark on current change
jj bookmark create feat/my-feature

# Set up remote tracking (required before first push)
jj bookmark track feat/my-feature --remote=origin

# ASK USER PERMISSION before pushing
# Only after explicit approval:
jj git push --bookmark feat/my-feature

# Create a PR using GitHub CLI (also requires permission)
# ASK USER: "May I create a pull request?"
# If approved:
gh pr create --title "feat: my feature" \
  --body "Description of changes..." \
  --base main \
  --head feat/my-feature
```

### 4. Keeping Work in Sync

```bash
# Fetch latest from remote
jj git fetch

# Create new work on top of latest main
jj new main@origin

# Check what changed
jj log -n 5
```

### 5. Handling Mistakes (Using Operation Log)

```bash
# Undo the last operation
jj undo

# View operation history
jj op log

# Restore to a specific operation
jj op restore <operation-id>

# Abandon a change you don't want
jj abandon <change-id>
```

## Best Practices for Agents

### DO:
- ✅ Use jj freely for local version control during development
- ✅ Create descriptive commit messages following conventional commit format
- ✅ Use `jj new` to separate logical units of work
- ✅ Run `jj status` frequently to understand current state
- ✅ Use `jj describe` to add/update descriptions as work evolves
- ✅ Fetch from remote with `jj git fetch` to stay current
- ✅ Use `jj undo` if you make a mistake - it's completely safe
- ✅ Run `alejandra .` before describing final changes
- ✅ Create bookmarks for features that will become PRs

### DON'T:
- ❌ **NEVER push to remote without explicit user permission**
- ❌ Don't create vague descriptions like "update files" or "fix things"
- ❌ Don't worry about making mistakes - operation log allows undo
- ❌ Don't use `jj git push` without user approval
- ❌ Don't forget to set up bookmark tracking before pushing
- ❌ Don't batch unrelated changes into one description

## Required User Permissions

### Always Ask Before:
1. **Pushing to remote** - `jj git push`
2. **Creating pull requests** - `gh pr create` (GitHub CLI)
3. **Force pushing** - `jj git push --force`
4. **Deleting bookmarks on remote** - `jj bookmark delete`
5. **Merging PRs** - `gh pr merge`

### No Permission Needed:
1. Local operations: `jj new`, `jj describe`, `jj edit`
2. Fetching: `jj git fetch`
3. Creating local bookmarks: `jj bookmark create`
4. Undoing operations: `jj undo`
5. Viewing state: `jj log`, `jj status`, `jj diff`

## Common Patterns

### Pattern: Incremental Feature Development

```bash
# Start feature work
jj new
# Edit files incrementally
jj describe -m "feat: add initial structure"

# Continue work in same change
# Edit more files
jj describe -m "feat: add initial structure and validation"

# Start next logical piece
jj new
# Edit files
jj describe -m "feat: add tests for new feature"
```

### Pattern: Multiple Related Changes

```bash
# Create first change
jj new
# Work on foundation
jj describe -m "refactor: extract common utilities"

# Build on top
jj new
# Use the utilities
jj describe -m "feat: implement feature using utilities"

# Check the stack
jj log
```

### Pattern: Collaborative Workflow with PR Creation

```bash
# Fetch latest work
jj git fetch

# Create bookmark for your feature
jj new main@origin
jj bookmark create feat/my-work

# Do work
jj describe -m "feat: implement my work

Detailed explanation of changes and motivation."

# Format code
alejandra .

# Validate build
nix flake check

# ASK USER: "Should I push this to remote and create a PR?"
# If yes:
jj bookmark track feat/my-work --remote=origin
jj git push --bookmark feat/my-work

# Create PR using GitHub CLI
gh pr create \
  --title "feat: implement my work" \
  --body "$(jj show -r @ --summary)" \
  --base main \
  --head feat/my-work

# Report the PR URL returned by gh
```

## Conflict Resolution

Jujutsu handles conflicts as first-class objects that can be resolved at any time:

```bash
# If you see a conflict after fetch/rebase
jj status  # Shows conflicted files

# Resolve using editor
jj resolve  # Opens interactive resolver

# Or manually edit conflict markers
# Edit files with <<<<<<< ======= >>>>>>>

# After resolving
jj describe -m "resolve: merge conflicts from main"

# Conflict resolution propagates to descendants automatically
```

## Checking User Identity

Before first commit, ensure user is configured:

```bash
# Check if configured
jj config list | grep user

# If not set, configure from git
jj config set --user user.name "$(git config user.name)"
jj config set --user user.email "$(git config user.email)"

# Update current change author if needed
jj metaedit --update-author
```

## Integration with Development Flow

### During Code Changes:

1. **Start**: `jj new` to begin new work
2. **Work**: Edit files normally
3. **Checkpoint**: `jj describe -m "..."` to save progress
4. **Continue**: Keep editing or `jj new` for next task
5. **Format**: `alejandra .` before finalizing
6. **Finalize**: Update description with final details

### Before Requesting Review:

1. **Verify**: `jj status` - clean working copy
2. **Format**: `alejandra .` - code formatted
3. **Test**: `nix flake check` - build succeeds
4. **Describe**: Clear, detailed commit message
5. **Bookmark**: `jj bookmark create feat/...`
6. **Ask Permission**: "May I push this to create a PR?"

## Troubleshooting

### Issue: "No author/committer set"
```bash
jj config set --user user.name "Your Name"
jj config set --user user.email "you@example.com"
jj metaedit --update-author
```

### Issue: "Concurrent modification"
```bash
jj git fetch  # Fetch again to sync
jj new main@origin  # Create new work on latest
```

### Issue: "Wrong parent for change"
```bash
jj rebase -d <new-parent>  # Move change to new parent
```

### Issue: "Made a mistake"
```bash
jj undo  # Reverse last operation
# Or
jj op log  # Find operation to restore to
jj op restore <operation-id>
```

## Using GitHub CLI for Pull Requests

After pushing a bookmark to remote, use `gh` CLI to create pull requests:

```bash
# Basic PR creation
gh pr create \
  --title "feat: brief description" \
  --body "Detailed description of changes" \
  --base main \
  --head feat/branch-name

# Use commit message as PR description
gh pr create \
  --title "feat: brief description" \
  --body "$(jj show -r @ --summary)" \
  --base main

# Interactive PR creation (opens editor)
gh pr create --fill

# Create draft PR
gh pr create --draft \
  --title "WIP: feature in progress" \
  --body "Early preview, not ready for review"
```

### Useful `gh pr` Commands

```bash
# View PR status
gh pr status

# List PRs
gh pr list

# View specific PR
gh pr view <number>

# Check PR checks/CI status
gh pr checks

# View PR diff
gh pr diff
```

## Example: Complete Feature Development Flow

```bash
# 1. Start work
jj git fetch
jj new main@origin
jj status

# 2. Implement feature
# ... edit files ...
jj describe -m "feat: add user authentication

- Implement JWT token generation
- Add login/logout endpoints
- Add middleware for protected routes"

# 3. Continue with tests
jj new
# ... write tests ...
jj describe -m "test: add authentication tests

- Test token generation
- Test login flow
- Test middleware protection"

# 4. Format and validate
alejandra .
nix flake check

# 5. Create bookmark
jj bookmark create feat/user-authentication

# 6. ASK USER
# "I've completed the authentication feature with tests. 
#  May I push this to create a pull request?"

# 7. If approved:
jj bookmark track feat/user-authentication --remote=origin
jj git push --bookmark feat/user-authentication

# 8. Create PR with GitHub CLI
gh pr create \
  --title "feat: add user authentication" \
  --body "$(jj log -r @ --no-graph -T 'description')" \
  --base main \
  --head feat/user-authentication

# 9. Report results
# "✅ Pull request created successfully!
#  PR #123: https://github.com/user/repo/pull/123"
```

## Quick Reference

```bash
# Status & Info
jj status              # Show working copy changes
jj log                 # Show change history
jj log -r @            # Show current change
jj diff                # Show diff of working copy
jj show <change>       # Show specific change

# Making Changes
jj new                 # Start new change
jj describe -m "..."   # Describe current change
jj edit <change>       # Switch to different change
jj abandon <change>    # Discard a change

# Bookmarks (Branches)
jj bookmark create <name>              # Create bookmark
jj bookmark list                       # List bookmarks
jj bookmark track <name> --remote=origin  # Track remote

# Sync (Ask permission before push!)
jj git fetch                          # Fetch from remote
jj git push --bookmark <name>         # Push bookmark (NEEDS PERMISSION)

# Safety Net
jj undo                               # Undo last operation
jj op log                             # View operation history
jj op restore <id>                    # Restore to operation

# Conflicts
jj resolve                            # Resolve conflicts interactively
```

## GitHub CLI Integration

The `gh` tool is available for GitHub operations. After pushing with jj, use gh to create PRs:

### Creating Pull Requests

1. **Push bookmark** (with permission): `jj git push --bookmark <name>`
2. **Create PR** (with permission): `gh pr create`
3. **Report URL**: Show the PR link returned by gh

### Example PR Creation Flow

```bash
# After getting user permission to push and create PR:

# 1. Push
jj git push --bookmark feat/my-feature

# 2. Create PR using commit description
gh pr create \
  --title "$(jj log -r @ --no-graph -T 'description.first_line()')" \
  --body "$(jj log -r @ --no-graph -T 'description')" \
  --base main

# 3. Capture and report PR URL
# gh automatically outputs the PR URL
```

### When to Use `gh pr create` vs Manual

- **Use `gh pr create`**: When user approves and you have all the info
- **Provide GitHub URL**: Let user create PR manually if they prefer
- **Always ask first**: Never create PRs without explicit permission

## Summary

Jujutsu simplifies version control by:
- Making all operations reversible via operation log
- Automatically tracking working copy changes
- Treating conflicts as first-class values
- Providing a cleaner mental model than Git

**Workflow with GitHub:**
1. Use jj freely for local version control during development
2. Ask permission before `jj git push`
3. Ask permission before `gh pr create`
4. Report PR URL to user after creation

Agents should use jj freely for local version control during development, but **always ask permission before pushing to remote repositories or creating pull requests**.
