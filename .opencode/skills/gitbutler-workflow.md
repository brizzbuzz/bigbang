# GitButler (but) Version Control Workflow Skill

## Overview

This skill enables AI agents to use GitButler's CLI (`but`) for version control. GitButler is Git-compatible, supports virtual branches (multiple applied branches in one working directory), and provides an operation log for safe undo.

## Core Principles

1. **Local-first, remote only with permission** - Use `but` freely for local operations, but NEVER push or create PRs without explicit user approval.
2. **Prefer virtual branches** - Use applied branches to keep unrelated work separate without switching worktrees.
3. **Describe intent clearly** - Use conventional commit messages and focus on why changes were made.
4. **Use the operation log as a safety net** - GitButler snapshots every operation for easy rollback.
5. **Use JSON for scripting** - Prefer `--json` for automation and agent parsing.

## Key Concepts

### Virtual Branches (Applied Branches)
- Multiple branches can be applied at once in a single working directory.
- Unassigned changes can be staged to a specific branch using `but stage`.
- Each branch has its own staging area and commit history.

### Parallel vs Stacked Branches
- **Parallel**: independent branches applied at the same time.
- **Stacked**: branches that depend on each other; created with an anchor using `but branch new -a <parent> <child>`.

### Operation Log
- Every operation is recorded.
- Use `but oplog` to inspect history.
- Use `but undo` to roll back the latest operation.

## Common Workflows

### 1. Starting Work

```bash
# Status overview (default action of `but`)
but status

# Create a new branch
but branch new feat/my-change

# Assign changes to branch
but stage path/to/file.ts feat/my-change

# Commit all assigned + unassigned to the branch
but commit -m "feat: add meaningful change" feat/my-change
```

### 2. Parallel Branches

```bash
# Create multiple active branches
but branch new feat/alpha
but branch new feat/beta

# Stage and commit to a specific branch
but stage src/alpha.ts feat/alpha
but commit -m "feat: add alpha" feat/alpha
```

### 3. Stacked Branches

```bash
# Create a branch stacked on another
but branch new -a feat/alpha feat/alpha-ui

# Commit to stacked branch
but commit -m "feat: add alpha UI" feat/alpha-ui
```

### 4. Staging and Committing Specific Changes

```bash
# Stage by CLI IDs shown in `but status`
but stage h0,i0 feat/my-change

# Commit only staged changes
but commit -o -m "feat: commit staged only" feat/my-change

# Commit specific hunks/files directly
but commit -p h0,i0 -m "feat: targeted commit" feat/my-change
```

### 5. Editing Commits

```bash
# Amend a file into a commit and rebase dependents
but amend <commit-id> path/to/file.ts

# Absorb work into likely commits
but absorb

# Reword commit message
but reword <commit-id>

# Squash commits
but squash <commit-a> <commit-b>

# Move a commit in the stack
but move <commit-id> --before <target-commit>
```

### 6. Conflicts

```bash
# Resolve conflicts
but resolve
```

### 7. Operation History and Undo

```bash
but oplog
but undo
```

### 8. Remote Operations (Permission Required)

```bash
# Update applied branches from remote
but pull

# Push (REQUIRES USER PERMISSION)
but push <branch>

# Create a PR (REQUIRES USER PERMISSION)
but pr create
```

### 9. GUI Integration

```bash
# Open GitButler GUI for current repo
but gui
```

## Best Practices for Agents

### DO:
- ✅ Use `but status` frequently to understand the workspace.
- ✅ Use `but stage` to assign changes to the correct branch.
- ✅ Keep parallel and stacked branches organized.
- ✅ Use conventional commit messages (`feat:`, `fix:`, `chore:`).
- ✅ Use `but undo` if an operation goes wrong.
- ✅ Use `--json` for scripted or agent-driven flows.

### DON'T:
- ❌ Push to remote without explicit user permission.
- ❌ Create PRs without explicit user permission.
- ❌ Mix unrelated changes in the same branch or commit.
- ❌ Bypass GitButler with ad-hoc git commands unless needed for read-only inspection.

## Required User Permissions

Always ask before:
1. `but push` (remote updates)
2. `but pr` (PR creation or updates)
3. Any remote destructive action (force push, deleting remote branches)

No permission needed for:
1. Local operations: `but status`, `but diff`, `but stage`, `but commit`, `but branch new`
2. Local editing: `but amend`, `but reword`, `but squash`, `but move`, `but absorb`
3. Operation history: `but oplog`, `but undo`

## JSON Output for Agents

Use `--json` (or `-j`) for machine-readable output:

```bash
but status --json
but show --json <commit-id>
```

## Integration With Development Flow

1. **Start**: `but status`
2. **Branch**: `but branch new <name>` (use `-a` for stacked)
3. **Assign**: `but stage <file|id> <branch>`
4. **Commit**: `but commit -m "..." <branch>`
5. **Format**: `alejandra .`
6. **Verify**: `nix flake check`
7. **Ask**: permission to push or create PR

## Summary

GitButler enables parallel and stacked branch workflows in a single working directory. Agents should use `but` for local version control, keep changes separated, and **always ask permission before any remote or PR operation**.
