# Media and Downloads

This capability is centered on `ganymede`, with `callisto` acting as the browser-facing ingress layer.

## Purpose

The media and downloads stack provides:

- media library serving
- photo management
- audiobook and podcast hosting
- indexer and downloader orchestration
- torrent downloading with VPN-based routing

## Hosts Involved

- `ganymede` runs the applications
- `callisto` proxies the web interfaces

## Main Modules

- `modules/nixos/jellyfin.nix`
- `modules/nixos/immich.nix`
- `modules/nixos/audiobookshelf.nix`
- `modules/nixos/arr.nix`
- `modules/nixos/torrents.nix`
- `modules/nixos/vpn.nix`

## Services

The current stack includes:

- Jellyfin
- Immich
- Audiobookshelf
- Prowlarr
- Sonarr
- Radarr
- Lidarr
- Bazarr
- Jellyseerr
- qBittorrent

## Storage Model

The stack is built around the `/data` mount on `ganymede`.

Important locations include:

- `/data/media`
- `/data/torrents/complete`
- `/data/torrents/incomplete`
- `/data/immich`

## Coupling Inside The Stack

The Arr module deliberately coordinates with other modules:

- it can share a media group with qBittorrent when torrents are enabled
- it is expected to sit alongside Jellyfin for consumption of downloaded media

The torrent module can also enable the VPN module and route qBittorrent traffic through OpenVPN.

## Browser Access Pattern

The typical access path is:

`browser -> callisto -> ganymede`

That pattern applies to media, photos, books, the Arr interfaces, and torrents.
