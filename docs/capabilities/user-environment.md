# User Environment

This capability spans NixOS and Darwin systems.

## Purpose

The user environment layer provides:

- user account creation on NixOS
- profile-based package selection
- shell setup
- deployment of user config files
- shared editor, terminal, git, SSH, and OpenCode configuration

## Main Modules

- `modules/common/host-info.nix`
- `modules/common/users/accounts.nix`
- `modules/common/users/packages.nix`
- `modules/common/users/shell.nix`
- `modules/common/users/config-files/default.nix`

## Profile Model

Users are defined under `host.users`.

Each user is attached to a profile:

- `personal`
- `company`

Profile settings then control package groups and some user-facing configuration behavior.

## Config Deployment Model

The repo does not use Home Manager here.

Instead, it deploys user config files through activation scripts.

That includes configuration for:

- git
- SSH
- 1Password SSH agent integration
- Starship
- Zellij
- Nushell
- OpenCode
- Ghostty
- Helix
- direnv
- Hyprland user files on Linux desktop hosts

## Shell Model

The default shell arrangement is:

- Bash as the login shell bootstrap on Linux
- Nushell launched from interactive Bash
- Zsh also configured as an available shell environment

## Operator Commands

The `nr` and `nrr` helper commands are delivered through Nushell autoload scripts.

Those commands wrap:

- `darwin-rebuild switch` on Darwin
- `colmena apply-local` for local NixOS rebuilds
- `colmena apply` for remote deployment
