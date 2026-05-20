# Identity

Authentik is the homelab identity provider.

## Purpose

The identity capability provides:

- a canonical login surface for homelab applications
- user and group based application authorization
- MFA-backed daily administration
- a local break-glass path for emergency access
- proxy-provider decisions for applications that do not implement SSO directly

It does not replace the ingress or overlay-network layers. Caddy still terminates and routes HTTP traffic. NetBird still provides private transport and peer reachability.

## Hosts Involved

- `callisto` runs Authentik server and worker processes
- `callisto` exposes Authentik through Caddy
- `ganymede` hosts the Authentik PostgreSQL database and service user

## Main Modules

- `modules/nixos/authentik.nix`
- `modules/nixos/postgres.nix`
- `modules/nixos/caddy.nix`
- `hosts/callisto/configuration.nix`
- `hosts/ganymede/configuration.nix`

## Runtime Shape

The canonical browser-facing Authentik URL is:

- `https://auth.rgbr.ink`

The internal LAN name is:

- `https://auth.lan.rgbr.ink`

On `callisto`, Authentik listens locally on `127.0.0.1:9100`. Port `9000` is intentionally avoided because the NetBird server already uses it.

The Authentik database lives on `ganymede` and is reached from `callisto` over the LAN. Current deployment uses a LAN-local PostgreSQL path with explicit `sslmode=disable`; do not treat that as a public-network database pattern.

## Secret Model

Authentik secrets are delivered through 1Password and OpNix, not embedded into Nix store paths.

Current secret categories include:

- PostgreSQL service password
- Authentik environment material such as secret key and bootstrap/runtime settings

## Account Model

The durable administrative shape is:

- `ryan` is the daily administrative user and uses MFA
- `breakglass-admin` is a local-password emergency account
- bootstrap-only admin accounts should not persist after setup
- the built-in `authentik Admins` and `authentik Read-only` groups should be kept unless there is a deliberate migration plan

Paths in Authentik are organizational metadata, not permission boundaries. Access should be controlled with bindings, policies, and groups.

## Forward Auth Model

Forward auth is used for applications where Caddy should keep proxy ownership and Authentik should answer only the authorization question.

The request path is:

`browser -> Caddy on callisto -> Authentik embedded outpost -> backend application`

Caddy sends authorization checks to the embedded outpost under `/outpost.goauthentik.io/`. If the user is not authenticated or not authorized, the outpost starts the Authentik login flow. If access is granted, Caddy proxies to the backend application.

This pattern is useful for internal tools that need a uniform auth gate but do not need first-class OIDC integration yet.

## Current Use

OpenCode is the first internal application family protected by Authentik forward auth. The application instances still run on `ganymede`; Caddy and Authentik enforce access at `callisto` before traffic reaches those services.

## Operational Checks

Useful read-only checks:

```sh
curl -Ik https://auth.rgbr.ink/outpost.goauthentik.io/ping
systemctl status authentik authentik-worker caddy --no-pager
```

Expected outpost health is HTTP `204`.

If a protected application returns an Authentik-branded `404` from `/outpost.goauthentik.io/auth/...`, the embedded outpost is reachable but probably does not have the relevant provider selected.

## Future Work

Likely next steps:

- add Grafana as an internal Authentik-protected application
- migrate NetBird login to Authentik OIDC after the app model is proven
- make Authentik application/provider configuration declarative once the manual shape has stabilized
