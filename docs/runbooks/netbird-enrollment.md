# NetBird Enrollment

This runbook covers enrolling and checking peers in the self-hosted NetBird network at `netbird.rgbr.ink`.

## Safety Rules

- Do not print setup keys, tokens, NetBird private keys, or files under `/var/lib/opnix/secrets/`.
- Do not use the headless setup key for interactive laptops or desktops.
- Do not start `netbird-personal-login.service` on `frame`.
- Use `sudo` for the NixOS system-managed client instance because its socket and state are service-owned.

## NixOS Client Checks

Run these on a NixOS peer:

```sh
netbird-personal version
sudo netbird-personal status --detail
systemctl is-enabled netbird-personal-login.service || true
systemctl status netbird-personal.service netbird-personal-login.service --no-pager || true
```

Useful service logs:

```sh
sudo journalctl -u netbird-personal.service -n 200 --no-pager
sudo journalctl -u netbird-personal-login.service -n 160 --no-pager
sudo journalctl -u opnix-secrets.service -n 100 --no-pager
```

Redact setup keys, tokens, secrets, passwords, and private keys before sharing logs.

## Headless NixOS Enrollment

Headless hosts use `services.netbird-personal-client.enrollment = "setup-key"`.

This is the default mode.

Current setup-key hosts:

- `callisto`
- `ganymede`

Expected service behavior:

- `netbird-personal.service` is enabled and running
- `netbird-personal-login.service` is enabled
- the setup-key credential is loaded by systemd from OpNix material

Do not manually print or pass the setup key in a shell command.

If setup-key enrollment failed during activation, first check:

```sh
systemctl status opnix-secrets.service netbird-personal.service netbird-personal-login.service --no-pager || true
sudo netbird-personal status --detail
```

Common causes:

- OpNix failed before the setup-key file was available
- DNS failed during activation
- `netbird.rgbr.ink` could not resolve during client startup

## Interactive NixOS Enrollment

Interactive NixOS hosts use `services.netbird-personal-client.enrollment = "interactive"`.

Current interactive NixOS host:

- `frame`

Expected service behavior on `frame`:

- `netbird-personal.service` is enabled and running
- `netbird-personal-login.service` is masked or disabled
- no headless setup-key secret is declared for the host

Enroll interactively:

```sh
sudo netbird-personal up --no-browser
```

Copy the printed URL into a normal browser and complete login through the NetBird UI.

Verify after login:

```sh
sudo netbird-personal status --detail
```

The peer should also appear in the NetBird dashboard.

## Recover From Accidental Setup-Key Enrollment

If an interactive host such as `frame` was accidentally enrolled with the headless setup key:

1. Deploy config with `enrollment = "interactive"`.
2. Confirm `netbird-personal-login.service` is masked or disabled.
3. Deregister or remove the accidental peer registration.
4. Re-enroll with `sudo netbird-personal up --no-browser`.
5. Remove duplicate or stale peers from the NetBird dashboard if needed.

Deregister command when local cleanup is desired:

```sh
sudo netbird-personal deregister
```

## macOS Manual Clients

macOS NetBird clients are currently managed manually, not through nix-darwin.

Current macOS rollout state:

- `dot` is enrolled
- `pip` is considered enrolled for rollout purposes and should be enrolled manually when next used

Install the upstream NetBird macOS app manually, then use the app login flow against:

- `https://netbird.rgbr.ink`

After enrollment, verify the peer appears in the NetBird dashboard with the expected hostname.

Do not add the macOS NetBird client to the nix-darwin config unless the repository intentionally changes to declarative macOS client management later.

## Status Meanings

`Connected` means the peer is enrolled and connected.

`NeedsLogin` means the daemon exists but has not completed enrollment.

`SessionExpired` means the peer needs an interactive login refresh or re-enrollment.

Permission errors against `/run/netbird-personal/sock` usually mean the command was run as a normal user against the system-managed instance. Use `sudo`.
