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

The root LUKS volume is configured for systemd-initrd unlock with an enrolled FIDO2 token as an alternative to the normal passphrase.

The main subvolumes are:

- `/`
- `/home`
- `/nix`
- `/persist`
- `/var/log`

## LUKS Unlock Model

- the root LUKS mapping is `crypted`
- the current encrypted partition is `/dev/nvme0n1p2`
- boot uses `systemd` initrd instead of the older scripted initrd path
- boot tries `fido2-device=auto` first, then falls back to passphrase after a short timeout
- the Disko `passwordFile` entry is only for provisioning and is not the runtime unlock mechanism

If the boot UI looks noisy or slightly alarming, that is expected. The successful path is to press the YubiKey when prompted by the initrd.

For rebuild, recovery, or re-enrollment steps, see `docs/runbooks/frame-luks-yubikey.md`.

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
- `docs/runbooks/frame-luks-yubikey.md`
