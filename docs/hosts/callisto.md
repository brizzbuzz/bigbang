# Callisto

`callisto` is the ingress, DNS, and utility node.

## Role

- remote server
- front door for public and LAN traffic
- internal DNS server
- utility host for rescue tooling

## Key Host Settings

- `host.name = "callisto"`
- `host.roles.remote = true`
- `host.userManagement.enable = true`

## What Runs Here

- Caddy via `services.web.caddy`
- Blocky via `services.dns.blocky`
- Ventoy Web via `services.tools."ventoy-web"`
- NetBird combined server and dashboard via `services.netbird-combined`
- NetBird personal client with setup-key enrollment
- OpNix-managed TLS material and Cloudflare token files

## What It Proxies

`callisto` exposes services that mostly run on `ganymede`.

That includes:

- portfolio
- Jellyfin
- Immich
- Audiobookshelf
- the Arr stack
- qBittorrent
- OpenCode instances
- ClickHouse

## Domain Responsibilities

`callisto` is responsible for:

- `rgbr.ink`
- `ryanbr.ink`
- `*.lan.rgbr.ink`
- `netbird.rgbr.ink`

## NetBird

`callisto` is both the NetBird control-plane host and a NetBird peer.

The control plane is exposed at `netbird.rgbr.ink` through a direct Caddy virtual host. That route handles dashboard traffic plus NetBird API, OAuth, relay, WebSocket, and gRPC paths.

The local peer uses setup-key enrollment and has NetBird SSH/SFTP enabled.

## How It Fits Into The System

`callisto` is the place where external access, internal naming, and service exposure are coordinated.

It is intentionally not the main application box. That split keeps edge responsibilities separate from workload and data responsibilities.

## Main Code Paths

- `hosts/callisto/configuration.nix`
- `modules/nixos/caddy.nix`
- `modules/nixos/blocky.nix`
- `modules/nixos/ventoy-web.nix`
- `modules/nixos/netbird-combined.nix`
- `modules/nixos/netbird-personal-client.nix`
