# System Topology

## Roles

- `callisto` at `192.168.11.200` is the ingress and DNS node
- `ganymede` at `192.168.11.39` is the backend workload node
- `frame` at `192.168.11.214` is the main NixOS workstation
- `pip` and `dot` are Darwin machines built from the shared `macme` base

## Traffic Flow

The dominant traffic path is:

`client -> callisto -> ganymede`

Examples:

- `media.rgbr.ink` and `media.lan.rgbr.ink` terminate at `callisto`, then proxy to Jellyfin on `ganymede`
- `photos.rgbr.ink` and `photos.lan.rgbr.ink` terminate at `callisto`, then proxy to Immich on `ganymede`
- `chat.rgbr.ink` terminates at `callisto`, then routes by path and protocol to multiple Spacebar backends on `ganymede`

## Internal DNS

`callisto` runs Blocky and publishes the internal `lan.rgbr.ink` namespace.

Internal names are mapped directly in `hosts/callisto/configuration.nix`.

Important names include:

- `callisto.lan.rgbr.ink`
- `ganymede.lan.rgbr.ink`
- `portfolio.lan.rgbr.ink`
- `media.lan.rgbr.ink`
- `photos.lan.rgbr.ink`
- `books.lan.rgbr.ink`
- `prowlarr.lan.rgbr.ink`
- `sonarr.lan.rgbr.ink`
- `radarr.lan.rgbr.ink`
- `lidarr.lan.rgbr.ink`
- `bazarr.lan.rgbr.ink`
- `jellyseerr.lan.rgbr.ink`
- `torrents.lan.rgbr.ink`
- `opencode-ryan.lan.rgbr.ink`
- `opencode-odyssey.lan.rgbr.ink`
- `clickhouse.lan.rgbr.ink`
- `chat.lan.rgbr.ink`
- `dns.lan.rgbr.ink`
- `ventoy.lan.rgbr.ink`

## Public Domains

The current public domain surface is:

- `rgbr.ink`
- `chat.rgbr.ink`
- `ryanbr.ink`

`rgbr.ink` currently redirects to `ryanbr.ink` at the Caddy layer.

## Service Placement

Services primarily live in one of two places:

- edge services on `callisto`
- application and data services on `ganymede`

Edge services on `callisto`:

- Caddy
- Blocky
- Ventoy Web

Application and data services on `ganymede`:

- portfolio
- Immich
- Jellyfin
- Audiobookshelf
- Prowlarr
- Sonarr
- Radarr
- Lidarr
- Bazarr
- Jellyseerr
- qBittorrent
- OpenCode
- ClickHouse
- PostgreSQL
- Spacebar

## Operator Endpoints

Operator workflows happen from:

- `frame`
- `pip`
- `dot`

Those systems are for day-to-day use, editing, and deployment, not for hosting shared homelab workloads.
