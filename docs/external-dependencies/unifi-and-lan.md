# UniFi and LAN

The repo assumes a specific LAN environment.

## What It Is Used For

- stable private addressing for the Colmena targets
- a local DNS resolver expectation in shared networking config
- workstation and server connectivity inside the homelab

## Where It Appears In Code

- `flake/nixos.nix` for deployment target IPs
- `modules/nixos/networking.nix` for the default nameserver `192.168.11.1`
- host configs with concrete private addresses such as `callisto` and `ganymede`

## Current Assumptions

- the homelab LAN lives on `192.168.11.0/24`
- `192.168.11.1` is the default resolver that the repo expects
- `callisto`, `ganymede`, and `frame` have stable private addresses used directly by deployment and proxy config

## Operational Importance

If the LAN addressing or upstream resolver changes, the repo will need updates in:

- Colmena target definitions
- reverse-proxy target definitions
- internal DNS mappings
- base networking defaults
