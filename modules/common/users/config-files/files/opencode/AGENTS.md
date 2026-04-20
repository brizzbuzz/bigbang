# OpenCode Personal Rules

## Skill Composition

- Treat global skills as reusable base capabilities.
- Treat repo-local skills as companion skills that enrich a base skill with project-specific goals, constraints, and vocabulary.
- Prefer distinct companion names such as `frontend-design-portfolio` or `product-manager-bigbang` instead of reusing the global skill name locally.
- When a task clearly matches a role skill, first look for the relevant global base skill and then look for any repo-local companion skill with the same role prefix.
- Companion skills should not restate the full base skill. They should add repo-specific context, relevant docs, constraints, and anti-patterns.

## Companion Skill Shape

- Start with what is unique about the repo.
- Reference the exact docs or files that matter.
- Add repo-specific success criteria, constraints, and anti-patterns.
- Keep the base skill responsible for durable best practices that should apply across repositories.

## Working Style

- Prefer loading only the skills and docs that are relevant to the current task.
- If both a base skill and a companion skill exist, use them together.
- If a companion skill references repo docs, read those docs before making a plan.

## Pull Requests

- Any request to create or open a pull request must load and follow the `git-commit-and-draft-pr` skill.
- Default to draft pull requests unless the user explicitly asks for ready-for-review.
- Pass pull request bodies to `gh` as clean rendered Markdown only.
- Never pass shell construction text such as `$(cat <<'EOF'`, `EOF`, or trailing `)` into a pull request title, body, or comment.
- Never post the pull request body template as a GitHub comment unless the user explicitly asks for that comment.

## Project Command Execution

- When a repository provides tooling through `flake.nix`, prefer running project commands via `nix develop` so they use the repo's pinned environment.
- For one-off execution, prefer `nix develop -c <command>` over assuming the tool is installed globally.
- This applies to project-specific tools such as `pnpm`, `deadnix`, `alejandra`, and similar commands exposed by the dev shell.
- If already inside an active `nix develop` shell, running the command directly is fine.
- Prefer host-global commands only when the command is clearly not provided by the project's flake or dev shell.
