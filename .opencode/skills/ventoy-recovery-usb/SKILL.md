---
name: ventoy-recovery-usb
description: Set up and use a Ventoy Web UI service on NixOS to create rescue USB drives for machine recovery workflows.
---

Use this skill when a rescue USB is the fastest path to recover or bootstrap a machine.

## Intended workflow

1. Run `ventoy-web` as a systemd service on a NixOS host.
2. Expose it on the network so a browser can manage USB installation.
3. Install Ventoy to a USB drive.
4. Copy one or more rescue ISOs to the Ventoy data partition.
5. Boot the target machine from that USB.

## NixOS shape

- Package: `pkgs.ventoy`
- Service entry point: `ventoy-web`
- Typical bind: `0.0.0.0:24680`
- Firewall: allow the chosen TCP port

## Operational notes

- Ventoy needs elevated privileges to manage USB devices.
- Installing Ventoy erases the target USB drive.
- After installation, copy ISOs to the large Ventoy data partition, not the small EFI partition.
- If a newly written USB does not appear immediately, re-read the partition table.

## Verification

- Service is running
- Web UI is reachable from the browser
- USB device is detected
- ISO files are visible on the Ventoy data partition
- Target machine boots to the Ventoy menu
