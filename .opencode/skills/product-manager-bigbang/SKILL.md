---
name: product-manager-bigbang
description: Repo-specific companion skill for applying the global product-manager workflow to this Nix-based homelab and machine-management repository.
---

Use this skill alongside the global `product-manager` skill when planning or structuring work in this repository.

## Repo context

- This repo manages hosts, shared Nix modules, overlays, and user config for a personal or homelab environment.
- Work often spans host definitions in `hosts/`, shared modules in `modules/`, and user config deployment under `modules/common/users/`.
- Changes may affect local rebuilds, remote deployments, secrets handling, or cross-host consistency.

## Read first when relevant

- `AGENTS.md`
- `flake.nix`
- `modules/common/users/config-files/configs/opencode.nix`
- host or module files directly affected by the request

## Product-management guidance for this repo

- Prefer issues and plans that are scoped to one host, one shared module, or one deployable behavior change at a time.
- Call out which hosts or user profiles are affected.
- Include validation expectations such as `nix flake check --show-trace`, `alejandra .`, `deadnix .`, `nr`, or `nrr <host>` when they matter.
- Treat secrets, bootstrap steps, and machine recovery work as operationally sensitive and document them carefully.
- Favor thin vertical slices that end in a verified host behavior, not abstract refactors with no deployable outcome.

## Semantic density for this repo

- Preserve host names, module paths, profile names, commands, secrets boundaries, and deploy targets in planning artifacts.
- Name the operator-visible behavior that changes, not just the Nix file that will be edited.
- Record validation state explicitly: not run, proposed, passed, failed with output, blocked by permission, or requires `nr`/`nrr <host>`.
- For recovery or bootstrap work, include rollback or next-safe-action notes instead of generic risk language.

## Artifact guidance

- Use a Linear document when a change needs operational context, rollout notes, or recovery guidance.
- Use a Linear issue when the work is implementation-ready and can be verified in one focused slice.
- Create a project only when multiple issues contribute to one user-visible or operator-visible outcome.

## Anti-patterns

- Do not write tickets that ignore which hosts or modules are impacted.
- Do not create vague infrastructure tasks with no verification plan.
- Do not bury deployment or rollback notes in chat if they belong in the Linear artifact.
