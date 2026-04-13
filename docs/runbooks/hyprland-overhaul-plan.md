# Hyprland Overhaul Plan

This runbook tracks the phased overhaul of the Hyprland setup on `frame`.

The plan is intentionally iterative. Each phase ends at a clean stopping point so the system can be rebuilt, used, and evaluated before continuing.

## Goals

- [ ] Replace the current monolithic Hyprland setup with a modular, easier-to-evolve layout.
- [ ] Improve daily ergonomics before spending effort on additional theming.
- [ ] Adopt a cleaner keyboard-first workflow with explicit modes and fewer conflicts.
- [ ] Move to a static, task-based workspace model.
- [ ] Modernize launcher and notifications without destabilizing the session.
- [ ] Simplify wallpaper, idle, and host-specific behavior.

## Locked Decisions

- [x] Optimize for a balanced workstation workflow.
- [x] Use `walker` as the target launcher.
- [x] Use static task-based workspaces.
- [x] Keep moderate idle behavior.
- [x] Replace `dunst` with `swaynotificationcenter` (`swaync`) in a later phase.
- [x] Keep `waybar` as the bar.
- [x] Keep `swww` as the wallpaper mechanism.
- [x] Defer `pyprland` until the base redesign is stable.

## Target End State

- [ ] Hyprland config is split into focused fragments with a small top-level entrypoint.
- [ ] Global keybinds are compact and conflict-free.
- [ ] Submaps handle grouped actions like resize, media, and session control.
- [ ] Workspaces `1` through `10` have named task roles.
- [ ] `walker` handles launching.
- [ ] `swaync` handles notifications and history.
- [ ] `waybar` reflects workspace roles and workflow state.
- [ ] Wallpaper and idle logic are simpler and more deterministic.
- [ ] Host-specific monitor and hardware behavior is isolated from shared workflow config.

## Phases

### Phase 0: Baseline And Constraints

Purpose: confirm the target stack and document what the current setup is doing before changing behavior.

- [x] Review the current Hyprland config layout.
- [x] Identify conflicting or duplicated keybinds.
- [x] Review current session tools and startup behavior.
- [x] Cross-reference Hyprland docs and common community setups.
- [x] Lock target decisions for launcher, notifications, workspace model, and idle behavior.

Stop point:

- [x] No user-facing behavior changes required.
- [x] A phased implementation plan exists.

### Phase 1: Modularize The Hyprland Config

Purpose: change structure first while keeping behavior as close to current as possible.

Implementation checklist:

- [x] Create a top-level `hyprland.conf` entrypoint that only sources fragment files.
- [x] Split monitor definitions into `monitors.conf`.
- [x] Split keyboard, mouse, touchpad, and gesture settings into `input.conf`.
- [x] Split general, decoration, animations, layout, misc, and environment settings into `appearance.conf`.
- [x] Split current keybinds into `binds.conf` without redesigning them yet.
- [x] Split current window rules into `rules.conf`.
- [x] Split startup `exec-once` entries into `autostart.conf`.
- [x] Move palette and profile-specific visual overrides into `theme.conf` and `profile.conf`.
- [x] Keep `hypridle.conf` and `hyprlock.conf` functionally unchanged in this phase.
- [x] Update `modules/common/users/config-files/configs/hyprland.nix` to deploy the modular layout.
- [x] Remove the duplicated script-copy block in `configs/hyprland.nix`.
- [x] Preserve current script deployment and wallpaper palette behavior for now.

Validation checklist after rebuild:

- [x] Hyprland starts successfully.
- [x] `hyprctl reload` succeeds.
- [x] Waybar appears.
- [x] Rofi still launches.
- [x] Dunst still receives notifications.
- [x] Hyprlock still works.
- [x] Hypridle still locks, blanks, and suspends as before.
- [x] Wallpaper generation and switching still work.
- [x] Screenshot and recording scripts still work.
- [x] No visual regression appears in the current theme.

Stop point:

- [x] Config is modular and behavior is still mostly unchanged.

### Phase 2: Replace The Keybinding Model

Purpose: fix the largest day-to-day ergonomic problems first.

Implementation checklist:

- [ ] Remove all conflicting binds.
- [ ] Define a compact global key layer for core actions.
- [ ] Keep `SUPER+Return` for terminal.
- [ ] Move launcher access to `SUPER+Space`.
- [ ] Standardize window actions like close, float, and fullscreen.
- [ ] Keep workspace jump on `SUPER+1..0`.
- [ ] Keep send-to-workspace on `SUPER+Shift+1..0`.
- [ ] Reserve `SUPER+S` for scratchpad behavior.
- [ ] Introduce a resize submap.
- [ ] Introduce a session or power submap.
- [ ] Introduce a media submap.
- [ ] Introduce a window-management submap if still needed after simplification.
- [ ] Keep the binds mnemonic and learnable.

Validation checklist after rebuild:

- [ ] No duplicate keybinds remain.
- [ ] Core global binds feel predictable.
- [ ] Submaps enter and exit cleanly.
- [ ] Lock, reload, power, and recording all have unique bindings.
- [ ] No accidental regressions appear in common daily actions.

Stop point:

- [ ] Keyboard workflow is coherent even before swapping supporting tools.

### Phase 3: Introduce Static Task Workspaces

Purpose: make the workspace model intentional instead of generic.

Target workspace roles:

- [ ] `1` web
- [ ] `2` code
- [ ] `3` term
- [ ] `4` chat
- [ ] `5` docs
- [ ] `6` media
- [ ] `7` admin
- [ ] `8` scratch
- [ ] `9` remote
- [ ] `10` temp

Implementation checklist:

- [ ] Encode the static workspace model in Hyprland config.
- [ ] Align application rules with the target roles.
- [ ] Start with conservative assignments for browser, editor, chat, and media apps.
- [ ] Avoid over-automating edge-case applications initially.
- [ ] Update Waybar to show all 10 workspaces consistently.
- [ ] Make workspace names or icons reflect the role model.

Validation checklist after rebuild:

- [ ] Common apps land in the expected workspaces.
- [ ] Workspace switching still feels fast and predictable.
- [ ] All 10 workspaces are visible or meaningfully represented.
- [ ] Multi-monitor behavior remains acceptable.
- [ ] The static model feels better than the current ad hoc setup.

Stop point:

- [ ] Workspaces now match actual task flow.

### Phase 4: Replace Launcher And Notifications

Purpose: modernize the two interaction surfaces used constantly throughout the day.

Implementation checklist:

- [ ] Add `walker` to the package set.
- [ ] Remove `rofi` from the active Hyprland workflow.
- [ ] Add `swaynotificationcenter` to the package set.
- [ ] Remove `dunst` from the active Hyprland workflow.
- [ ] Add Walker config deployment.
- [ ] Add SwayNC config deployment.
- [ ] Update autostart to launch `swaync` instead of `dunst`.
- [ ] Update keybinds to open Walker with `SUPER+Space`.
- [ ] Add a keybind to toggle the notification center.
- [ ] Optionally add a keybind for do-not-disturb if it proves useful.
- [ ] Remove unused Rofi and Dunst deployment code after the new stack works.

Validation checklist after rebuild:

- [ ] Walker launches reliably.
- [ ] App launch feels faster and cleaner than Rofi.
- [ ] Notifications still appear.
- [ ] Notification history is accessible.
- [ ] Notification center toggle works.
- [ ] No duplicate notification daemons are running.

Stop point:

- [ ] Launcher and notification ergonomics are materially improved.

### Phase 5: Redesign Waybar Around Workflow

Purpose: make the bar support the workflow rather than just display minimal status.

Implementation checklist:

- [ ] Redesign the module layout around workspace and mode awareness.
- [ ] Keep workspaces on the left.
- [ ] Add a mode or submap indicator if practical.
- [ ] Keep clock centered unless testing shows a better layout.
- [ ] Add notification state integration on the right.
- [ ] Keep network, audio, battery, and tray available.
- [ ] Add power profile visibility if useful.
- [ ] Tune spacing and module hierarchy for the laptop display width.
- [ ] Preserve the synthwave identity while improving readability.

Validation checklist after rebuild:

- [ ] Workspace state is legible at a glance.
- [ ] Mode or submap state is obvious when active.
- [ ] Notification and audio widgets work correctly.
- [ ] The bar remains uncluttered on smaller widths.
- [ ] The new bar improves workflow instead of adding noise.

Stop point:

- [ ] The bar now communicates useful state and reduces friction.

### Phase 6: Simplify Wallpaper, Visuals, And Idle

Purpose: reduce background complexity and make the session calmer and more predictable.

Implementation checklist:

- [ ] Remove unused wallpaper tooling from the active path.
- [ ] Keep `swww` as the single wallpaper mechanism.
- [ ] Decide whether generated wallpaper should run on login or on demand.
- [ ] Remove the timer-based per-minute wallpaper regeneration if it is still present.
- [ ] Reduce blur intensity.
- [ ] Reduce shadow intensity if it still feels heavy.
- [ ] Shorten and simplify animations.
- [ ] Keep `misc:vfr = true` unless testing shows a problem.
- [ ] Split laptop-specific idle behavior from shared idle defaults.
- [ ] Keep moderate lock, DPMS, and suspend timings.

Validation checklist after rebuild:

- [ ] Wallpaper behavior is deterministic.
- [ ] The session feels lighter and more responsive.
- [ ] Idle behavior still matches expectations.
- [ ] No hardware-specific backlight errors appear in the wrong environment.
- [ ] Visual polish remains good without feeling overbuilt.

Stop point:

- [ ] Wallpaper, visuals, and idle behavior are simpler and lower-friction.

### Phase 7: Host-Aware Polishing

Purpose: isolate machine-specific concerns and decide whether extra tooling is justified.

Implementation checklist:

- [ ] Move monitor layout assumptions into host-aware overrides.
- [ ] Separate laptop-specific hardware behavior from shared workflow config.
- [ ] Add a clean local override path for monitor and device quirks.
- [ ] Remove packages and configs that are no longer used.
- [ ] Re-evaluate whether `pyprland` is still needed.
- [ ] Only add `pyprland` if native scratchpad behavior still feels limiting.

Validation checklist after rebuild:

- [ ] External monitor attach and detach behavior is sane.
- [ ] Shared config stays clean across hosts.
- [ ] Desktop-specific package selection matches actual usage.
- [ ] No unnecessary complexity remains from earlier phases.

Stop point:

- [ ] The shared desktop stack is clean and host-specific behavior is isolated.

## Testing Rhythm

Use this loop for every phase:

- [ ] Implement only one phase at a time.
- [ ] Rebuild the system.
- [ ] Log into Hyprland and test only the checklist for that phase.
- [ ] Record any friction before starting the next phase.
- [ ] Adjust the next phase if testing reveals a better direction.

## Recommended Phase Order

- [x] Phase 1: Modularize the Hyprland config.
- [ ] Phase 2: Replace the keybinding model.
- [ ] Phase 3: Introduce static task workspaces.
- [ ] Phase 4: Replace launcher and notifications.
- [ ] Phase 5: Redesign Waybar around workflow.
- [ ] Phase 6: Simplify wallpaper, visuals, and idle.
- [ ] Phase 7: Host-aware polishing.

## Deferred Until Proven Necessary

- [ ] `pyprland`
- [ ] dashboard-heavy widgets
- [ ] major lock-screen redesign
- [ ] replacing Waybar entirely
- [ ] broad theming experiments before core workflow is stable

## Notes

- [ ] Keep changes minimal within each phase.
- [ ] Prefer structural cleanup before adding new tools.
- [ ] Do not combine launcher, keybind, workspace, and visual overhauls in one rebuild.
- [ ] Revisit workspace role names only after real usage shows a problem.
