# Macme

`macme` is the shared nix-darwin base for the Darwin machines.

## Role

- common macOS system definition
- operator endpoint base
- personal machine baseline for `pip` and `dot`

## Important Distinction

`macme` is not itself the exported flake output name.

The concrete Darwin outputs are:

- `pip`
- `dot`

Both currently build from the same shared `hosts/macme/configuration.nix` base and differ only by the flake output they select.

## What This Base Configures

- OpNix on Darwin
- WireGuard config material under `/etc/wireguard`
- manually installed NetBird client on enrolled macOS endpoints
- Kagi API key material
- nix-darwin system settings
- Homebrew enablement through `nix-homebrew`
- the shared user-management and config-file system from `modules/common/`

## Host Characteristics

- `aarch64-darwin`
- primary user `ryan`
- keyboard `voyager`

## How It Fits Into The System

The Darwin machines are operator and endpoint devices, not infrastructure nodes.

They exist to:

- access the homelab
- run the shared user environment
- perform development and administration tasks

## NetBird

`dot` is enrolled in the self-hosted NetBird network.

`pip` is also considered part of the NetBird rollout and should be enrolled manually when next used.

The macOS NetBird client is intentionally installed manually rather than through nix-darwin. Use the upstream macOS app and enroll through the UI against `https://netbird.rgbr.ink`.

Do not infer that NetBird client state is managed by this repository on macOS. The repo documents the expectation, but the app install and enrollment are operator-managed.

## Main Code Paths

- `hosts/macme/configuration.nix`
- `flake/darwin.nix`
- `modules/darwin/`
- `modules/common/`
