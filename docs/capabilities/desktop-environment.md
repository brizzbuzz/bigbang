# Desktop Environment

This capability is centered on `frame`.

## Purpose

The desktop environment capability provides:

- login and session startup
- Wayland desktop services
- audio and device support
- desktop applications and quality-of-life tooling

## Hosts Involved

- `frame` is the only host currently marked with `host.roles.desktop = true`

## Main Modules

- `modules/nixos/session.nix`
- `modules/nixos/userland.nix`
- `modules/nixos/audio.nix`
- `modules/nixos/hardware.nix`
- `modules/nixos/fingerprint-reader.nix`
- `modules/nixos/fonts.nix`
- `modules/nixos/gaming.nix`

## Session Model

The session stack is based on:

- `greetd` and `tuigreet` for login
- Hyprland for the compositor
- XDG portals for desktop integration
- `hyprpolkitagent` for privilege prompts
- PipeWire for audio

## Current Shape

Desktop behavior is now split along cleaner lines.

- `session.nix` owns login, Hyprland, portals, keyring, and polkit plumbing
- `userland.nix` owns desktop-facing tools, Thunar integration, power tooling, XDG user directories, and wallpaper automation
- device and media support still live in adjacent modules like `audio.nix`, `hardware.nix`, and `fingerprint-reader.nix`

This is a better boundary than before, but desktop changes can still span more than one file when they cross session, userland, audio, and hardware concerns.

## Hyprland Config Shape

The Hyprland user config is deployed through the activation-script-based user environment layer under `modules/common/users/config-files/`.

The current config is modular rather than monolithic.

- `hyprland.conf` is a small entrypoint that sources focused fragments
- `monitors.conf` contains monitor declarations
- `input.conf` contains keyboard, mouse, touchpad, and gesture settings
- `appearance.conf` contains general layout, decoration, animation, misc, and environment settings
- `theme.conf` contains the shared synthwave palette and visual color assignments
- `binds.conf` contains the global key layer
- `submaps.conf` contains grouped modal bindings for less-frequent actions
- `rules.conf` contains window rules
- `autostart.conf` contains session startup programs
- `profile.conf` contains personal overrides like spacing and wallpaper generation

This keeps workflow, appearance, startup behavior, and host-specific tuning easier to change independently.

## Current Interaction Model

The desktop is still based on Hyprland, Waybar, Rofi, Dunst, Hypridle, Hyprlock, and `swww`, but the keyboard workflow is now more deliberate.

The global layer is reserved for common actions:

- `SUPER+Return` launches `ghostty`
- `SUPER+Space` opens the launcher
- `SUPER+E` opens Thunar
- `SUPER+Q` closes the active window
- `SUPER+V` toggles floating
- `SUPER+F` toggles fullscreen
- `SUPER+H/J/K/L` moves focus
- `SUPER+Shift+H/J/K/L` moves windows
- `SUPER+1..0` switches workspaces
- `SUPER+Shift+1..0` sends the active window to a workspace
- `SUPER+S` toggles the special workspace scratchpad

Less-common actions now live in submaps instead of occupying prime global shortcuts.

- `SUPER+R` enters resize mode
- `SUPER+P` enters session mode for lock, suspend, exit, reboot, and poweroff
- `SUPER+M` enters media mode for playback and volume control
- `SUPER+W` enters window mode for pseudo and pin actions

This removes several previous keybind conflicts and makes the keyboard layer easier to reason about.
