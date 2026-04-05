# Data Services

This capability is primarily centered on `ganymede`.

## Purpose

Data services provide persistent state and analytics-oriented infrastructure for the rest of the system.

## Hosts Involved

- `ganymede` runs PostgreSQL and ClickHouse
- `callisto` proxies ClickHouse for LAN access

## Main Modules

- `modules/nixos/postgres.nix`
- `modules/nixos/clickhouse.nix`

## PostgreSQL

The PostgreSQL module extends the base `services.postgresql` interface with:

- `developmentMode`
- `serviceDatabases`
- `serviceUsers`

On `ganymede`, PostgreSQL currently backs:

- Immich
- Jellyfin
- Spacebar

## ClickHouse

ClickHouse is enabled on `ganymede` and uses OpNix-delivered admin credential material.

It is exposed internally through `callisto` at `clickhouse.lan.rgbr.ink`.

## Backup and Persistence

The code currently defines a weekly Spacebar backup flow on `ganymede`.

That backup includes:

- a PostgreSQL dump
- a compressed archive of the Spacebar CDN files

## Current Notes

- PostgreSQL is clearly treated as shared platform infrastructure for multiple services.
- ClickHouse is currently more isolated and service-specific.
