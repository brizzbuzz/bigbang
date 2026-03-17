---
name: initial-system-setup
description: Recover or bootstrap a machine with a Ventoy USB, perform a minimal NixOS install, and prepare it for full flake-based remote deployment.
---

Use this when a machine is bricked, bare, or otherwise needs a clean bootstrap before the full declarative config can take over.

## High-level phases

1. Boot from a Ventoy USB containing a NixOS installer ISO.
2. Bring up networking.
3. Partition and mount disks, usually via Disko.
4. Install either a minimal NixOS system or the flake directly.
5. Reboot, verify SSH and sudo access, and prepare secrets.
6. Deploy the full host configuration from the management machine.

## Preferred path

If the hardware profile is already represented in the flake, prefer direct flake install over a temporary handwritten bootstrap.

## Checklist

- Networking works from the installer environment
- Disk layout is correct and mounted
- `nixos-install` or `nixos-install --flake` completes successfully
- User accounts and passwords are set
- SSH access works after reboot
- Secret bootstrap steps are complete
- Remote deployment succeeds

## Common failure areas

- Disk busy during Disko runs
- Missing network after first boot
- SSH not enabled or not reachable
- Flake install mismatch with target hardware
