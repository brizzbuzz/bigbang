# Ganymede

`ganymede` is the main backend workload and data host.

## Role

- remote server
- application host
- database host
- media and downloads host
- OpenCode host

## Key Host Settings

- `host.name = "ganymede"`
- `host.roles.remote = true`
- `host.hardware.gpu.nvidia.enable = true`
- `host.userManagement.enable = true`

## Users

`ganymede` currently carries two user profiles:

- `ryan` with the `personal` profile
- `odyssey` with the `company` profile

## What Runs Here

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
- OpenVPN-based torrent routing
- OpenCode for `ryan`
- OpenCode for `odyssey`
- ClickHouse
- PostgreSQL
- Spacebar
- NetBird personal client with setup-key enrollment

## Data Responsibilities

`ganymede` is where application state lives.

Examples:

- media under `/data/media`
- Spacebar backups under `/data/backups/spacebar`
- OpenCode backups under `/data/backups/opencode`
- PostgreSQL service databases for `immich`, `jellyfin`, and `spacebarchat`

## Relationship With Callisto

Most browser-facing access to `ganymede` does not hit it directly.

Instead:

- `callisto` terminates and routes public or LAN traffic
- `ganymede` serves the backend applications behind that ingress layer

`ganymede` is also a NetBird peer for private overlay access. Browser-facing services still primarily flow through `callisto` rather than direct peer access.

## NetBird

`ganymede` uses the `personal` NetBird client instance with setup-key enrollment.

NetBird SSH and SFTP are enabled for this peer.

## GPU Role

`ganymede` enables the NVIDIA module and is the only host in the repo currently configured with NVIDIA support.

## Main Code Paths

- `hosts/ganymede/configuration.nix`
- `modules/nixos/arr.nix`
- `modules/nixos/torrents.nix`
- `modules/nixos/vpn.nix`
- `modules/nixos/immich.nix`
- `modules/nixos/jellyfin.nix`
- `modules/nixos/audiobookshelf.nix`
- `modules/nixos/opencode.nix`
- `modules/nixos/clickhouse.nix`
- `modules/nixos/postgres.nix`
- `modules/nixos/netbird-personal-client.nix`
