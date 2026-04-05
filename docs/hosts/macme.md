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

## Main Code Paths

- `hosts/macme/configuration.nix`
- `flake/darwin.nix`
- `modules/darwin/`
- `modules/common/`
