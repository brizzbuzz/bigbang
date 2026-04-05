# Architecture Overview

BigBang manages four kinds of systems:

- `frame`: the main NixOS desktop/workstation
- `callisto`: the ingress, DNS, and utility node
- `ganymede`: the backend workload and data node
- `macme`: the shared nix-darwin base used to build the `pip` and `dot` machines

At a high level, the repo splits into these layers:

- `flake.nix` and `flake/`: build, deployment, and flake outputs
- `hosts/`: host-specific system definitions
- `modules/common/`: shared host metadata, users, packages, shell, and config-file deployment
- `modules/nixos/`: NixOS capabilities and service modules
- `modules/darwin/`: nix-darwin-specific additions
- `modules/overlays/`: package overlays

## System Model

The most important architectural boundary is between `callisto` and `ganymede`:

- `callisto` is the front door
- `ganymede` is where most application workloads actually run

That split shows up throughout the repo:

- Caddy and Blocky live on `callisto`
- media services, databases, Spacebar, portfolio, and OpenCode live on `ganymede`
- `callisto` proxies public and internal traffic to `ganymede`

`frame` and the Darwin machines are operator and endpoint systems rather than shared service hosts.

## Shared Configuration Pattern

The repo uses a small shared host schema under `modules/common/host-info.nix`.

That schema defines:

- `host.name`
- `host.roles.desktop`
- `host.roles.remote`
- `host.hardware.gpu.nvidia.enable`
- user and profile metadata under `host.users` and `host.profiles`

Most shared behavior is then derived from that metadata.

Examples:

- desktop-only NixOS modules key off `host.roles.desktop`
- user management, packages, shell setup, and config-file deployment key off `host.userManagement.enable`
- NVIDIA setup keys off `host.hardware.gpu.nvidia.enable`

## Capability Areas

The live capability areas in the repo are:

- ingress and DNS
- media and downloads
- data services
- desktop environment
- user environment
- deployment and flake outputs
- AI and OpenCode

Those map more cleanly to the codebase than a module-by-module document set.

## Current Rough Edges

These are real properties of the repo today and are worth documenting rather than hiding.

- Nix behavior is now cleaner, but still intentionally split between `modules/nixos/core.nix` and `modules/nixos/maintenance.nix`.
- Desktop behavior is now cleaner, but still intentionally split between `modules/nixos/session.nix` and `modules/nixos/userland.nix`, with related device support still living in modules like `audio.nix`, `hardware.nix`, and `fingerprint-reader.nix`.
- `macme` is a shared Darwin base, but the concrete flake outputs are thin wrappers with almost no per-machine differentiation.
- Some high-level abstractions are intentionally thin. For example, host topology is mostly expressed directly in host configs rather than in a separate service graph.

Those rough edges are not necessarily bugs, but they are important context for anyone changing the repo.
