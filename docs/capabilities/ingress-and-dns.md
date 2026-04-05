# Ingress and DNS

This capability is centered on `callisto`.

## Purpose

Ingress and DNS provide:

- public domain entrypoints
- internal LAN naming
- TLS termination
- reverse proxying to backend services
- ad, malware, and tracking filtering for LAN DNS clients

## Hosts Involved

- `callisto` hosts the ingress and DNS stack
- `ganymede` supplies most backend services that are exposed through it

## Main Modules

- `modules/nixos/caddy.nix`
- `modules/nixos/blocky.nix`
- `modules/nixos/networking.nix`
- `hosts/callisto/configuration.nix`

## Public Surface

Current public domains include:

- `rgbr.ink`
- `ryanbr.ink`
- `chat.rgbr.ink`

Current internal surface includes `*.lan.rgbr.ink`.

## Caddy Model

The Caddy module defines a higher-level abstraction under `services.web.caddy` for:

- root site handling
- subdomain reverse proxies
- standalone domains with explicit certificate secrets
- internal LAN sites with ACME DNS-01 certificates

`callisto` uses all of those modes.

## DNS Model

The Blocky module defines a higher-level abstraction under `services.dns.blocky` for:

- upstream DNS forwarding
- filtering lists and client groups
- caching behavior
- custom LAN hostname mappings

In practice, `callisto` uses it to publish the internal service names that point at the ingress IP.

## External Dependencies

- Cloudflare for DNS and certificate flows
- the local UniFi-backed LAN assumptions in `modules/nixos/networking.nix`
- 1Password and OpNix for TLS certificate and token delivery

## Current Notes

- `chat.rgbr.ink` is not handled by the generic Caddy abstraction alone; `hosts/callisto/configuration.nix` adds direct `services.caddy.virtualHosts` entries for multi-backend Spacebar routing.
- Internal DNS names are currently declared directly in the host config rather than generated from a separate inventory file.
