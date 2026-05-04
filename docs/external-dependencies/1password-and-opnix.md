# 1Password and OpNix

1Password and OpNix are core external dependencies for this repo.

## What They Are Used For

- delivery of host and service secrets
- SSH agent and SSH key workflows
- TLS certificates and API tokens for ingress
- application secrets for hosted services
- Kagi API key delivery
- OpenCode instance identity material
- NetBird server secrets and headless setup-key material

## Where They Appear In Code

- host-level `services.onepassword-secrets` blocks in `hosts/`
- `modules/nixos/opencode.nix`
- `modules/nixos/clickhouse.nix`
- `modules/nixos/torrents.nix`
- `modules/nixos/netbird-combined.nix`
- `modules/nixos/netbird-personal-client.nix`
- `modules/nixos/security.nix`
- shared config deployment under `modules/common/users/config-files/`

## Why This Matters

Many parts of the repo assume secrets arrive declaratively through OpNix.

If OpNix or 1Password delivery is broken, the impact can include:

- Caddy missing certificates or DNS token files
- OpenCode missing SSH or Kagi credentials
- torrent VPN configuration failing to materialize
- ClickHouse admin bootstrap failing
- security features such as U2F configuration missing expected files
- NetBird server startup failing because auth or store-encryption secrets are missing
- headless NetBird client enrollment failing because setup-key material is missing

## Current Pattern

The repo generally treats secrets as:

- referenced declaratively in code
- materialized onto the machine at known paths
- consumed by services or copied into user config where needed

NetBird uses this pattern for:

- `/var/lib/opnix/secrets/netbird-auth-secret`
- `/var/lib/opnix/secrets/netbird-store-encryption-key`
- `/var/lib/opnix/secrets/netbird-homelab-headless-setup-key`

Interactive clients such as `frame` should not depend on the reusable headless setup key.
