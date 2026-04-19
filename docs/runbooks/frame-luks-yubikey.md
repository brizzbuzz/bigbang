# Frame LUKS and YubiKey

Use this runbook when setting up `frame` from scratch again, re-enrolling a YubiKey after a reset, or checking how the current boot unlock flow works.

## Current Model

`frame` uses:

- Disko for partitioning
- a LUKS2 root volume on `/dev/nvme0n1p2`
- a mapped root device named `crypted`
- `systemd` initrd for boot-time unlock
- FIDO2 token unlock via `systemd-cryptenroll`
- passphrase fallback if the token is not present

The declarative host-side configuration lives in:

- `hosts/frame/configuration.nix`
- `hosts/frame/disko.nix`

## Declarative Config

`frame` needs all of the following in NixOS configuration:

- `boot.initrd.systemd.enable = true;`
- `boot.initrd.systemd.fido2.enable = true;`
- `boot.initrd.availableKernelModules = [ "usbhid" ];`
- `boot.initrd.luks.fido2Support = false;`
- `boot.initrd.luks.devices.crypted.crypttabExtraOpts = [ "fido2-device=auto" "token-timeout=10s" ];`

This keeps the old scripted-stage1 FIDO2 path disabled and lets `systemd-cryptsetup` handle the enrolled token.

## Rebuild

After changing the host config on `frame`, rebuild with:

`nr`

If the rebuild succeeds, the host side is ready for enrollment.

## Fresh Enrollment

Enroll the token on the existing LUKS device with touch-only unlock:

```bash
sudo systemd-cryptenroll /dev/nvme0n1p2 \
  --fido2-device=auto \
  --fido2-with-client-pin=no \
  --fido2-with-user-presence=yes \
  --fido2-with-user-verification=no
```

Expected behavior:

- the command asks for the current LUKS passphrase
- the token may ask for touch confirmation during enrollment
- the enrollment adds a new `fido2` slot to the LUKS header

To inspect the current slots:

```bash
sudo systemd-cryptenroll /dev/nvme0n1p2
```

The working state on `frame` is:

- `password`
- `recovery`
- `fido2`

## Recovery Key

Add a recovery key if needed:

```bash
sudo systemd-cryptenroll /dev/nvme0n1p2 --recovery-key
```

This prints a machine-generated fallback key. Store it somewhere safe if you intend to rely on it.

## If the YubiKey Already Has an Unknown FIDO2 PIN

The current key on `frame` is a `YubiKey 5C Nano`. If the token already has a FIDO2 PIN set and it is unknown, reset only the FIDO application before re-enrolling.

Inspect the FIDO state:

```bash
nix shell nixpkgs#yubikey-manager -c ykman fido info
```

Reset the FIDO app immediately after reinserting the key:

```bash
nix shell nixpkgs#yubikey-manager -c ykman fido reset -f
```

Notes:

- this must run within a few seconds after reinserting the key
- it wipes FIDO2 and U2F credentials on the YubiKey
- it clears the existing FIDO2 PIN

Verify reset state:

```bash
nix shell nixpkgs#yubikey-manager -c ykman fido info
```

## Boot Behavior

Expected boot behavior after enrollment:

1. With the YubiKey inserted, initrd prompts for the token and boot continues after touching the key.
2. Without the YubiKey inserted, boot waits briefly and then falls back to the normal LUKS passphrase prompt.

The early boot screen can look noisy or slightly broken even on the success path. On `frame`, that was normal during testing. If the token is present, try pressing the YubiKey before assuming boot failed.

## Verifying the Token Is Visible in Userspace

List FIDO2 devices:

```bash
systemd-cryptenroll --fido2-device=list
```

For the current `frame` setup, this should show the YubiKey as a usable FIDO2 token.

## Re-Enrollment Flow After a Reset or New Install

1. Rebuild `frame` with `nr`.
2. Confirm `systemd-cryptenroll --fido2-device=list` sees the key.
3. If needed, reset the YubiKey FIDO app.
4. Enroll the token with `systemd-cryptenroll`.
5. Verify slot state with `sudo systemd-cryptenroll /dev/nvme0n1p2`.
6. Reboot once with the token inserted.
7. Reboot once without the token to confirm passphrase fallback still works.
