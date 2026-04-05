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
