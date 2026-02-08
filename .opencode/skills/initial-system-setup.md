# Initial System Setup Skill

## Overview

This skill covers the end-to-end process of recovering a bricked machine using a Ventoy USB and performing a minimal NixOS bootstrap that enables remote deployment of a full flake configuration.

## Prerequisites

- Ventoy USB created with a NixOS installer ISO
- Access to your flake repository (GitHub or local)
- Disko configuration for target machine in your flake
- Physical access to the target machine
- Network access (WiFi or Ethernet)

## Phase 1: Boot from Ventoy USB

1. Plug the Ventoy USB into the broken machine
2. Enter boot menu (F12/F11/ESC/DEL depending on hardware)
3. Select the USB device
4. Pick the NixOS ISO from Ventoy menu

## Phase 2: Connect to Network

**WiFi (wpa_cli):**
```bash
sudo systemctl start wpa_supplicant
wpa_cli

# In wpa_cli:
> add_network
0
> set_network 0 ssid "YourWiFiSSID"
> set_network 0 psk "YourWiFiPassword"
> enable_network 0
> quit

ping nixos.org
```

**Ethernet:**
```bash
ping nixos.org
```

## Phase 3: Partition with Disko

1. Clone your flake:
```bash
nix-shell -p git
git clone https://github.com/YOUR_USERNAME/YOUR_REPO /tmp/bigbang
cd /tmp/bigbang
```

2. Create a LUKS encryption password file (if your disko uses one):
```bash
echo "YOUR_STRONG_DISK_ENCRYPTION_PASSWORD" > /tmp/secret.key
chmod 600 /tmp/secret.key
```

3. Run Disko (this **wipes the disk**):
```bash
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko -- \
  --mode disko \
  /tmp/bigbang/hosts/<hostname>/disko.nix
```

4. Verify mounts:
```bash
lsblk
```

## Phase 4: Minimal NixOS Bootstrap

1. Generate hardware config:
```bash
sudo nixos-generate-config --root /mnt
```

2. Edit minimal configuration:
```bash
sudo nano /mnt/etc/nixos/configuration.nix
```

Add essentials:
```nix
{
  networking.hostName = "hostname";
  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  users.users.YOUR_USERNAME = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

3. Install minimal system:
```bash
sudo nixos-install
```

4. Set user password:
```bash
sudo nixos-enter --root /mnt
passwd YOUR_USERNAME
exit
```

5. Reboot:
```bash
sudo reboot
```

## Alternative: Direct Flake Install (Preferred)

If the target hardware matches your flake's hardware config, install directly with the flake instead of a minimal bootstrap:

```bash
sudo nixos-install --flake /tmp/bigbang#hostname
```

After install, set passwords for every user defined in the flake (and root if needed):

```bash
sudo nixos-enter --root /mnt
passwd root
passwd ryan
passwd Work
exit
```

This avoids a second deployment step and uses the flake as the definitive system configuration.

## Post-Reboot Checklist

- Unlock LUKS if prompted at boot.
- Log in as `ryan` (and `Work` if needed).
- If login fails, switch to TTY (`Ctrl+Alt+F2`) and log in there.
- Verify sudo works: `sudo -v`.
- Set OpNix token: `sudo opnix token set`.
- Confirm secret file exists: `ls -la /var/lib/opnix/secrets/`.
- Rebuild once to ensure everything is current: `sudo nixos-rebuild switch --flake /path/to/your/flake#frame`.

## Phase 5: Remote Deployment from Management Machine

1. Find the IP on the target:
```bash
ip addr show
```

2. Set up SSH key auth:
```bash
ssh-copy-id YOUR_USERNAME@TARGET_IP
ssh YOUR_USERNAME@TARGET_IP
exit
```

3. Update flake deployment config (colmena):
```nix
deployment = {
  targetHost = "192.168.1.XXX";
  targetUser = "YOUR_USERNAME";
  allowLocalDeployment = true;
  buildOnTarget = true;
};
```

4. Deploy full config:
```bash
colmena apply --on hostname
# Or: nrr hostname
```

5. Verify:
```bash
ssh YOUR_USERNAME@TARGET_IP
nixos-version
hostname
```

## Phase 6: Post-Installation

1. Set up static IP or DNS entry (optional):
   - Configure router DHCP reservation
   - Or add local DNS entry (e.g., `hostname.local`)
   - Update flake `targetHost` to use hostname instead of IP

2. Future deployments:
```bash
nrr hostname
```

## Common Issues

**SSH connection refused**:
```bash
systemctl status sshd
systemctl enable --now sshd
```

**Disko fails with "device busy"**:
```bash
sudo umount -R /mnt
```

**No IP after boot**:
```bash
ip addr show
ip route
```

## Disko Configuration Example

```nix
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["defaults" "umask=0077"];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-L" "nixos" "-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["subvol=root" "compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["subvol=home" "compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = ["subvol=persist" "compress=zstd" "noatime"];
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = ["subvol=log" "compress=zstd" "noatime"];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
```

## Time Estimates

- Creating Ventoy USB: 5-10 minutes
- Booting from USB: 1-2 minutes
- Network setup: 1-5 minutes
- Disko partitioning: 2-5 minutes
- Minimal install: 5-10 minutes
- Remote deployment: 5-15 minutes
- Total rescue operation: 30-45 minutes

## Success Checklist

- Machine boots from Ventoy USB
- NixOS installer ISO loaded
- Network connectivity established
- Disk encrypted and partitioned via Disko
- Minimal NixOS boots successfully
- SSH key authentication working
- Colmena deployment succeeds
- Machine boots into your full flake configuration
- User environment loads correctly
- Can SSH in with your user account
