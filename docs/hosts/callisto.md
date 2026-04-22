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
- Spacebar

## Domain Responsibilities

`callisto` is responsible for:

- `rgbr.ink`
- `ryanbr.ink`
- `chat.rgbr.ink`
- `*.lan.rgbr.ink`

## Spacebar Routing

`chat.rgbr.ink` is special.

Instead of a simple one-port reverse proxy, `callisto` routes:

- WebSocket traffic to the Spacebar gateway on `ganymede:13003`
- API traffic to the Spacebar API on `ganymede:13001`
- everything else to the Spacebar CDN on `ganymede:13002`

## How It Fits Into The System

`callisto` is the place where external access, internal naming, and service exposure are coordinated.

It is intentionally not the main application box. That split keeps edge responsibilities separate from workload and data responsibilities.

## Main Code Paths

- `hosts/callisto/configuration.nix`
- `modules/nixos/caddy.nix`
- `modules/nixos/blocky.nix`
- `modules/nixos/ventoy-web.nix`
