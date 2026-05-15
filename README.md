# BigBang

This repository defines the machines, shared modules, services, and operator workflows for the BigBang homelab.

Start in `docs/`:

- `docs/README.md` for the documentation home page
- `docs/SUMMARY.md` for the full table of contents

Common commands:

- `nix develop`
- `nh os test . --impure`
- `nh os switch . --impure`
- `nh darwin switch . --impure --hostname <host>`
- `deploy .#<host> -- --impure`
- `nix flake check --show-trace`
