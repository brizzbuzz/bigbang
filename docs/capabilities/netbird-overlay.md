# NetBird Overlay

NetBird is the private overlay network for the homelab and operator endpoints.

## Purpose

The NetBird overlay provides:

- authenticated private peer access across enrolled machines
- a self-hosted management, signal, relay, and dashboard endpoint
- a path for operator devices to reach the homelab without depending only on LAN presence
- optional NetBird SSH and SFTP support for selected server peers

The LAN and ingress stack still matter. NetBird adds an overlay network; it does not replace the UniFi LAN, Blocky DNS, Caddy ingress, or Colmena target addressing.

## Current Rollout State

| Host | Role | NetBird status | Enrollment | Install source |
| --- | --- | --- | --- | --- |
| `callisto` | control plane, ingress, server peer | enrolled | setup key | declarative NixOS |
| `ganymede` | backend workload peer | enrolled | setup key | declarative NixOS |
| `frame` | Linux workstation peer | enrolled | interactive | declarative NixOS client, manual SSO |
| `dot` | macOS operator endpoint | enrolled | interactive/manual | manually installed macOS app |
| `pip` | macOS operator endpoint | enrolled for rollout purposes | interactive/manual | manually installed macOS app |

The macOS clients are intentionally not managed by nix-darwin right now. Install and enroll the upstream NetBird macOS app manually on those machines.

## Server Placement

`callisto` hosts the self-hosted NetBird control plane through `services.netbird-combined`.

The server module is `modules/nixos/netbird-combined.nix`.

The public NetBird domain is:

- `netbird.rgbr.ink`

The public management, signal, relay, dashboard, and admin surface is reached through:

- `https://netbird.rgbr.ink:443`

`callisto` uses a direct Caddy virtual host for `netbird.rgbr.ink` because NetBird needs more than a simple reverse proxy. The route handles gRPC, API, OAuth, relay, WebSocket proxy paths, well-known paths, and the dashboard.

## Client Placement

NixOS hosts use the `services.netbird-personal-client` module from `modules/nixos/netbird-personal-client.nix`.

The declarative client instance is named `personal`.

Important client paths and names:

- CLI: `netbird-personal`
- service: `netbird-personal.service`
- setup-key login service for headless hosts: `netbird-personal-login.service`
- runtime socket: `/run/netbird-personal/sock`
- state directory: `/var/lib/netbird-personal`
- config file: `/var/lib/netbird-personal/config.json`
- WireGuard interface: `nb-personal`

The generic `netbird` CLI is not expected to exist for the NixOS instance. Use `netbird-personal`.

## Enrollment Modes

`services.netbird-personal-client.enrollment` controls how a NixOS peer enrolls.

### Setup-Key Enrollment

`setup-key` is the default mode.

Use it for headless or server hosts.

Behavior:

- creates the OpNix-managed reusable headless setup key secret
- enables `netbird-personal-login.service`
- enrolls the peer without browser interaction
- keeps headless server enrollment declarative

Current setup-key hosts:

- `callisto`
- `ganymede`

### Interactive Enrollment

`interactive` is for laptops and desktops where a human should complete SSO or browser-based login.

Behavior:

- does not create the headless setup-key secret
- disables and masks `netbird-personal-login.service`
- keeps `netbird-personal.service` running
- requires manual enrollment with the instance CLI

Current interactive NixOS host:

- `frame`

Interactive enrollment command:

```sh
sudo netbird-personal up --no-browser
```

## Secrets

NetBird secrets are delivered by 1Password and OpNix.

Server secrets on `callisto`:

- `/var/lib/opnix/secrets/netbird-auth-secret`
- `/var/lib/opnix/secrets/netbird-store-encryption-key`

Reusable headless setup-key secret for setup-key clients:

- `/var/lib/opnix/secrets/netbird-homelab-headless-setup-key`

Do not print setup keys, tokens, NetBird private keys, or secret file contents during triage.

## External Dependencies

NetBird depends on:

- Cloudflare DNS for `netbird.rgbr.ink`
- Caddy on `callisto` for public TLS and routing
- 1Password and OpNix for server secrets and headless setup-key material
- working DNS during activation and enrollment
- upstream STUN, currently Cloudflare public STUN by module default

## Operational Checks

Useful read-only checks on NixOS clients:

```sh
netbird-personal version
sudo netbird-personal status --detail
systemctl status netbird-personal.service netbird-personal-login.service --no-pager || true
systemctl is-enabled netbird-personal-login.service || true
```

Expected behavior differs by enrollment mode:

- setup-key hosts should have `netbird-personal-login.service` enabled
- `frame` should have `netbird-personal-login.service` masked or disabled
- enrolled peers should appear in the NetBird dashboard

## Known Failure Modes

If `opnix-secrets.service` fails during activation, setup-key enrollment can fail because the login service depends on the setup-key credential.

If DNS is unavailable during activation, OpNix may fail to reach 1Password and NetBird may fail to resolve `netbird.rgbr.ink`.

If a client reports `NeedsLogin` or `SessionExpired`, the daemon is present but enrollment or session state is incomplete.

If a normal user runs `netbird-personal status`, socket permissions may prevent access. Use `sudo netbird-personal status --detail` for the system-managed instance.

## Future Work

Possible follow-up work:

- decide whether macOS NetBird should remain manually managed or become declarative later
- document stable NetBird peer names and tags once access policies mature
- add policy and ACL documentation after the peer model settles
