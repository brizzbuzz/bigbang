# Deployment and Flake Outputs

## Purpose

This capability defines how systems are built, evaluated, and deployed from the repository.

## Main Files

- `flake.nix`
- `flake/darwin.nix`
- `flake/shell.nix`

## Flake Outputs

The repo exposes:

- `darwinConfigurations`
- `deploy`
- `devShells`
- `nixosConfigurations`

## Darwin Outputs

The current Darwin outputs are:

- `pip`
- `dot`

Both are built from the shared `macme` base.

## NixOS Outputs

The current NixOS outputs are:

- `frame`
- `callisto`
- `ganymede`

Those appear in both `nixosConfigurations` and `deploy.nodes`, but with different purposes.

## Deployment Model

deploy-rs is the remote deployment interface for the Linux hosts. Local rebuilds use `nh`.

Current targets are:

- `frame` at `192.168.11.214`
- `callisto` at `192.168.11.200`
- `ganymede` at `192.168.11.39`

## Development Shell

The dev shell provides pinned project tooling such as:

- `alejandra`
- `deadnix`
- `deploy-rs`
- `git-cliff`
- `nh`
- `nurl`
- `tokei`
- `opnix`

## Typical Commands

- `nix develop`
- `nh darwin switch .`
- `nh os test .`
- `nh os switch .`
- `deploy .#<host>`
- `deploy --targets .#ganymede .#callisto`
- `nix flake check --show-trace`
- `nix develop -c alejandra .`
- `nix develop -c deadnix .`

## Current Rough Edge

Nix behavior is still configured in more than one place, but along a clearer boundary.

The main split is between:

- `modules/nixos/core.nix`
- `modules/nixos/maintenance.nix`

`core.nix` owns active Nix configuration, while `maintenance.nix` owns garbage collection and store optimization.
