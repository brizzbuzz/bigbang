---
name: linux-ricing-bigbang
description: Iterate on this repo's Linux desktop environment with a disciplined stage, rebuild, screenshot, and refine workflow.
---

Use this skill when changing the user-facing Linux desktop experience in this repository.

## Repo context

- This repo contains the user's declarative desktop environment, not just isolated shell widgets.
- Desktop-facing work may span Hyprland config, Quickshell QML, user scripts, launchers, notifications, wallpaper behavior, fonts, terminal integration, and related user config under `modules/common/users/config-files/`.
- The desktop is delivered through Nix, so the real source of truth is the deployed system state after rebuild.

## Read first when relevant

- `AGENTS.md`
- `modules/common/users/config-files/configs/hyprland.nix`
- `modules/common/users/config-files/files/hypr/`
- `modules/common/users/config-files/files/quickshell/`
- any directly affected scripts, themes, fonts, or launcher config files

## Scope of this skill

Use it for work such as:

- Hyprland layout and behavior changes
- Quickshell bar, sidebar, popup, and widget refinement
- notification, launcher, screenshot, and clipboard tooling
- desktop interaction polish, theming, spacing, and visual hierarchy
- ricing workflow improvements that affect how changes are validated locally

## Core workflow

1. Review the current desktop-related config before changing anything. Do not assume the problem is isolated to one file or subsystem.
2. Make the smallest coherent change that improves the desktop experience.
3. Ensure any new or modified relevant files are staged in git before rebuilding when the workflow depends on Nix seeing tracked files.
4. Only run a rebuild if the user has explicitly granted permission in the current conversation.
5. Rebuild locally with `nix develop -c colmena apply-local --impure --sudo`.
6. After the rebuild completes, capture a fresh screenshot with `grim /tmp/quickshell-current.png` or another clearly named file.
7. Judge the live rendered result from the screenshot rather than reasoning only from source.
8. Iterate: adjust code, ensure files are staged if needed, rebuild again with permission, capture a new screenshot, and refine until the result is clearly better.

## Permission rule

- Rebuilds are not implicit. Even when this skill recommends the rebuild-and-screenshot loop, only run the rebuild command after the user has explicitly allowed it.
- If permission has not been granted, stop after code changes and explain that live validation requires rebuild permission.

## Validation guidance

- Treat screenshots as a required validation step for visual changes.
- When something looks wrong, confirm with a fresh screenshot before assuming the source of the problem.
- If a reload or deploy appears to fail, check `quickshell log --tail <n>` or the relevant runtime logs before guessing.
- If new files are added and the deployed result does not reflect them, check whether git staging/tracking is required for Nix to include them.

## Design guidance for this repo

- Preserve the user's aesthetic and workflow preferences instead of imposing generic desktop UI patterns.
- Favor clearer hierarchy, cleaner spacing, and fewer competing surfaces.
- Avoid duplicated controls across multiple shell surfaces unless duplication is clearly intentional.
- Prefer changes that improve the day-to-day interaction loop, not just isolated visual flourishes.

## Anti-patterns

- Do not treat the desktop as Quickshell-only when the issue may involve Hyprland, scripts, or deployment wiring.
- Do not stop at source edits for visual work without validating the live desktop.
- Do not rebuild without explicit user permission.
- Do not forget that tracked/staged file state can affect whether Nix sees newly added config files.
