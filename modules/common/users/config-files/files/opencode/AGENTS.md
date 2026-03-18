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
