# Cloudflare

Cloudflare is a first-class external dependency for the ingress stack.

## What It Is Used For

- public DNS for the configured domains
- DNS-01 validation for internal ACME certificates
- origin certificate material used by Caddy
- API token access for DNS automation

## Where It Appears In Code

- `hosts/callisto/configuration.nix`
- `modules/nixos/caddy.nix`
- OpNix-managed secret references for TLS certificates and Cloudflare token files

## Current Responsibilities

Cloudflare currently supports:

- `rgbr.ink`
- `ryanbr.ink`
- `lan.rgbr.ink` certificate issuance flows

## Operational Importance

If Cloudflare DNS or token delivery is broken:

- public ingress can degrade
- internal ACME certificate issuance can fail
- Caddy reloads that depend on certificate material can fail
