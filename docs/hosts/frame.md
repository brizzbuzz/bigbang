# Frame

`frame` is the main NixOS desktop and workstation.

## Role

- primary interactive Linux machine
- desktop host
- development and operator endpoint

## Key Host Settings

- `host.name = "frame"`
- `host.roles.desktop = true`
- `host.userManagement.enable = true`

## Notable Behavior

- uses the shared desktop stack under `modules/nixos/`
- enables `fwupd`
- installs Google Chrome
- pulls a Kagi API key through OpNix
- declares a NetworkManager Wi-Fi profile for the home network
- overrides the shared Hyprland monitor config with `hosts/frame/hypr/monitors.conf`

## Storage and Install Model

`frame` uses Disko and a LUKS-on-btrfs layout.

The main subvolumes are:

- `/`
- `/home`
- `/nix`
- `/persist`
- `/var/log`

## How It Fits Into The System

`frame` is not an infrastructure node.

It exists to:

- run the user desktop environment
- act as an endpoint into the homelab
- perform edits, local rebuilds, and deployments

## Main Code Paths

- `hosts/frame/configuration.nix`
- `hosts/frame/disko.nix`
- `hosts/frame/hypr/monitors.conf`
- `modules/nixos/default.nix`
- `modules/common/`
