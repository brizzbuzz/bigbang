# Ventoy Web UI Rescue USB Skill

## Overview

This skill documents how to set up and use Ventoy Web UI as a systemd service on NixOS for creating rescue USB drives. This approach provides a simple, network-accessible web interface for installing Ventoy to USB drives and managing bootable ISOs.

## Context: Why Ventoy?

This solution was developed as an alternative to PXE netboot for rescuing bricked machines (specifically Framework laptops). Initial attempts using dnsmasq/TFTP netboot failed due to firmware incompatibilities with NixOS's netboot system (EFI stub hangs). Ventoy provides a simpler, more portable solution that works with any machine's standard UEFI/BIOS boot process.

## Architecture

### Components

1. **Ventoy Package**: Available in nixpkgs as `pkgs.ventoy` (requires `permittedInsecurePackages` due to version 1.1.10)
2. **ventoy-web Binary**: Web UI server included in the Ventoy package
3. **NixOS Module**: Custom module to run ventoy-web as a systemd service
4. **USB Drive**: Physical USB drive for Ventoy installation

### How It Works

- `ventoy-web` runs as a systemd service bound to `0.0.0.0:24680` (accessible from network)
- User accesses web UI from browser (e.g., `http://callisto.chateaubr.ink:24680`)
- Web UI allows selecting USB device and installing Ventoy bootloader
- After installation, user copies ISO files directly to the Ventoy USB partition
- Ventoy automatically detects and presents all ISOs in a boot menu

## Implementation

### Step 1: Module Structure

Create `modules/nixos/ventoy-web.nix`:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.host.ventoy-web;
in {
  options.host.ventoy-web = {
    enable = mkEnableOption "Ventoy Web UI service for USB drive management";

    port = mkOption {
      type = types.port;
      default = 24680;
      description = "Port for the Ventoy web interface";
    };

    bindAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "IP address to bind the web server to (0.0.0.0 for all interfaces)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.ventoy];

    systemd.services.ventoy-web = {
      description = "Ventoy Web UI";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.ventoy}/bin/ventoy-web -H ${cfg.bindAddress} -p ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "5s";

        # Ventoy needs root access to manage USB devices
        User = "root";
        Group = "root";

        # Security hardening (while still allowing USB access)
        PrivateTmp = true;
        NoNewPrivileges = false; # Ventoy needs full privileges for disk operations
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = ["/dev" "/sys"]; # Need access to USB devices
      };
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
```

### Step 2: Register Module

Add to `modules/nixos/default.nix` imports:

```nix
imports = [
  # ... other imports ...
  ./ventoy-web.nix
  # ... other imports ...
];
```

### Step 3: Configure Insecure Package

Add to `flake/nixos.nix` (or wherever pkgs is configured):

```nix
pkgs = import inputs.nixpkgs {
  system = "x86_64-linux";
  config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "ventoy-1.1.10"  # Required for Ventoy package
    ];
  };
  overlays = import ../modules/overlays;
};
```

### Step 4: Enable on Target Host

In `hosts/<hostname>/configuration.nix`:

```nix
host = {
  ventoy-web = {
    enable = true;
    port = 24680;
    bindAddress = "0.0.0.0";  # Bind to all interfaces for network access
  };
};
```

### Step 5: Deploy

```bash
# Deploy to target host (e.g., callisto)
nrr callisto

# Or for local deployment
nr
```

## Usage Workflow

### Creating a Rescue USB

1. **Verify Service Running**
   ```bash
   ssh <hostname> systemctl status ventoy-web
   ```

2. **Access Web UI**
   - Open browser: `http://<hostname>:24680` or `http://<ip-address>:24680`
   - Example: `http://callisto.chateaubr.ink:24680` or `http://192.168.11.200:24680`

3. **Plug USB Drive**
   - Physically connect USB drive to the server
   - Web UI should detect it automatically (may need to refresh partition table)

4. **Re-read Partition Table** (if USB not detected)
   ```bash
   ssh <hostname> 'sudo blockdev --rereadpt /dev/sdX'
   ```

5. **Install Ventoy**
   - Select USB device from dropdown in web UI
   - Click "Install" button
   - **Warning**: This erases all data on the USB drive!

6. **Add ISO Files**
   ```bash
   # Mount the Ventoy data partition
   ssh <hostname> 'sudo mkdir -p /mnt/ventoy && sudo mount /dev/sda1 /mnt/ventoy'
   
   # Download ISO(s) - example with NixOS
   ssh <hostname> 'cd /mnt/ventoy && sudo wget -O nixos-25.11-minimal-x86_64-linux.iso \
     https://channels.nixos.org/nixos-25.11/latest-nixos-minimal-x86_64-linux.iso'
   
   # Safely unmount
   ssh <hostname> 'sync && sudo umount /mnt/ventoy'
   ```

7. **Use Rescue USB**
   - Unplug USB from server
   - Plug into target machine (e.g., bricked laptop)
   - Boot from USB (usually F12/F11/ESC key)
   - Select ISO from Ventoy menu

### Finding the Latest NixOS ISO

Use Kagi search to find current releases:

```bash
# Search for latest NixOS
kagi_kagi_search_fetch "NixOS latest release download ISO 2025"

# Download URLs follow this pattern:
# Minimal: https://channels.nixos.org/nixos-25.11/latest-nixos-minimal-x86_64-linux.iso
# Graphical: https://channels.nixos.org/nixos-25.11/latest-nixos-graphical-x86_64-linux.iso
```

### Ventoy Partition Layout

After installation, Ventoy creates two partitions:

```
/dev/sda1  - Large exFAT partition (label: "Ventoy") - PUT ISOs HERE
/dev/sda2  - Small FAT32 partition (label: "VTOYEFI") - Bootloader (don't touch)
```

### Troubleshooting

**Partition not showing up after Ventoy install:**
```bash
ssh <hostname> 'sudo blockdev --rereadpt /dev/sda && sleep 2 && lsblk | grep sda'
```

**Service not accessible from network:**
```bash
# Check service status
ssh <hostname> 'systemctl status ventoy-web'

# Check firewall
ssh <hostname> 'sudo nft list ruleset | grep 24680'

# Check binding
ssh <hostname> 'sudo ss -tlnp | grep 24680'
```

**USB device not detected:**
```bash
# Check USB devices
ssh <hostname> 'lsusb'
ssh <hostname> 'lsblk'

# Check dmesg for USB insertion
ssh <hostname> 'dmesg | tail -20'
```

## Best Practices

### DO:
- ✅ Use latest stable NixOS ISO for rescue operations
- ✅ Keep multiple ISOs on one Ventoy USB (system rescue, diagnostics, OS installers)
- ✅ Label/name ISO files clearly in Ventoy partition
- ✅ Verify ISO checksums when possible
- ✅ Test boot on non-critical hardware first
- ✅ Keep Ventoy USB in accessible location for emergencies

### DON'T:
- ❌ Don't modify the VTOYEFI partition manually
- ❌ Don't remove USB without syncing/unmounting first
- ❌ Don't forget to backup important data before installing Ventoy
- ❌ Don't assume all machines will boot - test compatibility
- ❌ Don't use corrupted ISOs (verify downloads)

## Security Considerations

### Network Exposure
- Web UI has **no authentication** by default
- Only expose on trusted networks (e.g., home LAN)
- Consider adding reverse proxy with auth for untrusted networks

### Service Permissions
- Service runs as **root** (required for USB device management)
- Security hardening applied where possible:
  - `PrivateTmp = true` - Isolated /tmp
  - `ProtectHome = true` - No home directory access
  - `ProtectSystem = "strict"` - Read-only filesystem
  - `ReadWritePaths = ["/dev" "/sys"]` - Only necessary paths writable

### USB Drive Security
- Ventoy USB is read-only during boot (ISOs not modified)
- Consider encrypting sensitive ISOs if needed
- Physical access to USB = full boot access to any machine

## Advanced Usage

### Adding Multiple ISOs

Ventoy supports multiple ISOs and presents them all in a boot menu:

```bash
# Mount Ventoy
ssh <hostname> 'sudo mount /dev/sda1 /mnt/ventoy'

# Download multiple ISOs
ssh <hostname> 'cd /mnt/ventoy && \
  sudo wget nixos.iso && \
  sudo wget ubuntu.iso && \
  sudo wget archlinux.iso && \
  sudo wget clonezilla.iso'

# Organize in folders (optional)
ssh <hostname> 'cd /mnt/ventoy && \
  sudo mkdir linux diagnostics && \
  sudo mv nixos.iso ubuntu.iso archlinux.iso linux/ && \
  sudo mv clonezilla.iso diagnostics/'

ssh <hostname> 'sudo umount /mnt/ventoy'
```

### Custom Ventoy Configuration

Ventoy supports plugins and themes via `ventoy.json`:

```bash
# Create custom config
cat > ventoy.json << 'EOF'
{
  "theme": {
    "enabled": "true",
    "file": "/ventoy/theme/theme.txt"
  },
  "menu_alias": [
    {
      "image": "/linux/nixos-25.11-minimal-x86_64-linux.iso",
      "alias": "NixOS 25.11 (Minimal)"
    }
  ]
}
EOF

# Upload to Ventoy USB
scp ventoy.json <hostname>:/mnt/ventoy/ventoy/ventoy.json
```

### Remote ISO Management Script

For frequent updates, create a helper script:

```bash
#!/usr/bin/env bash
# update-rescue-usb.sh

HOST="callisto"
MOUNT="/mnt/ventoy"

# Mount
ssh "$HOST" "sudo mkdir -p $MOUNT && sudo mount /dev/sda1 $MOUNT"

# Download latest NixOS
ssh "$HOST" "cd $MOUNT && sudo wget -O nixos-latest.iso \
  https://channels.nixos.org/nixos-25.11/latest-nixos-minimal-x86_64-linux.iso"

# Unmount
ssh "$HOST" "sync && sudo umount $MOUNT"

echo "✅ Rescue USB updated with latest NixOS ISO"
```

## Comparison with Netboot

### Ventoy USB Advantages
- ✅ Works with any firmware (no PXE boot compatibility issues)
- ✅ Portable - no server infrastructure needed
- ✅ Multiple ISOs on one USB
- ✅ No network dependency during boot
- ✅ Faster boot times (local USB vs network)

### Netboot Advantages
- ✅ No physical access needed to target machine
- ✅ Centralized management of boot images
- ✅ Multiple machines can boot simultaneously
- ✅ No USB drive to lose/damage

### When to Use Each
- **Ventoy USB**: Physical access available, firmware compatibility issues, portable rescue
- **Netboot**: Remote machines, infrastructure with reliable network, multiple machines

## Integration with Existing Systems

This module integrates with the broader NixOS rescue infrastructure:

```nix
# Example: Complete rescue server configuration
host = {
  # Netboot server (for compatible machines)
  netboot = {
    enable = true;
    interface = "enp100s0";
    serverIp = "192.168.11.200";
  };
  
  # Ventoy Web UI (for incompatible machines or portable rescue)
  ventoy-web = {
    enable = true;
    port = 24680;
    bindAddress = "0.0.0.0";
  };
};
```

## References

- **Ventoy Official**: https://www.ventoy.net/
- **NixOS Downloads**: https://nixos.org/download/
- **ventoy-web CLI**: `ventoy-web --help` shows `-H` (host) and `-p` (port) options
- **Blog Post**: https://haseebmajid.dev/posts/2023-09-29-setup-ventoy-on-nixos/

## Quick Reference

```bash
# Service management
systemctl status ventoy-web
systemctl restart ventoy-web
journalctl -u ventoy-web -f

# USB operations
lsblk | grep sda                    # Check USB detection
sudo blockdev --rereadpt /dev/sda   # Re-read partitions
sudo mount /dev/sda1 /mnt/ventoy    # Mount Ventoy data partition
sudo umount /mnt/ventoy             # Unmount
sync                                # Flush writes

# Web UI access
http://<hostname>:24680             # Web interface
http://<ip-address>:24680           # Direct IP access

# ISO management
cd /mnt/ventoy && ls -lh            # List ISOs on USB
wget -O filename.iso <url>          # Download ISO
rm filename.iso                     # Remove ISO
```

## End-to-End: Rescuing and Installing NixOS on a Broken Machine

This section documents the complete workflow for using Ventoy USB to rescue a bricked machine and install your NixOS flake configuration on it.

### Prerequisites

- ✅ Ventoy USB created with NixOS installer ISO (see above)
- ✅ Your NixOS flake repository on GitHub
- ✅ Disko configuration for target machine in your flake
- ✅ Physical access to broken machine
- ✅ Network access (WiFi or Ethernet)

### Phase 1: Boot from Ventoy USB

1. **Plug Ventoy USB into broken machine**
2. **Power on and enter boot menu** (usually F12, F11, ESC, or DEL during startup)
3. **Select USB drive** from boot menu
4. **Select NixOS ISO** from Ventoy menu
5. **Boot into NixOS live environment**

### Phase 2: Connect to Network

**For WiFi:**
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

# Verify connection
ping nixos.org
```

**For Ethernet:**
```bash
# Usually works automatically via DHCP
ping nixos.org
```

### Phase 3: Partition with Disko

1. **Clone your flake:**
   ```bash
   nix-shell -p git
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO /tmp/bigbang
   cd /tmp/bigbang
   ```

2. **Create LUKS encryption password:**
   ```bash
   # Create password file (Disko uses this for encryption)
   echo "YOUR_STRONG_DISK_ENCRYPTION_PASSWORD" > /tmp/secret.key
   chmod 600 /tmp/secret.key
   ```

3. **Run Disko to partition and encrypt:**
   ```bash
   # This will WIPE the disk and create encrypted partitions
   sudo nix --experimental-features "nix-command flakes" run \
     github:nix-community/disko -- \
     --mode disko \
     /tmp/bigbang/hosts/<hostname>/disko.nix
   
   # Example for a machine called "frame":
   sudo nix --experimental-features "nix-command flakes" run \
     github:nix-community/disko -- \
     --mode disko \
     /tmp/bigbang/hosts/frame/disko.nix
   ```

4. **Verify partitions are mounted:**
   ```bash
   lsblk
   # Should show partitions mounted at /mnt, /mnt/boot, /mnt/home, etc.
   ```

### Phase 4: Minimal NixOS Installation (Bootstrap)

The goal here is to install just enough NixOS to boot and allow remote deployment.

1. **Generate basic hardware config:**
   ```bash
   sudo nixos-generate-config --root /mnt
   ```

2. **Edit minimal configuration:**
   ```bash
   sudo nano /mnt/etc/nixos/configuration.nix
   ```

   Add these essentials (keep the rest of the generated config):
   ```nix
   # Add to the configuration
   {
     networking.hostName = "hostname";  # Match your flake hostname
     networking.networkmanager.enable = true;
     
     services.openssh.enable = true;
     
     users.users.YOUR_USERNAME = {
       isNormalUser = true;
       extraGroups = [ "wheel" "networkmanager" ];
     };
     
     # Critical for remote deployment
     nix.settings.experimental-features = [ "nix-command" "flakes" ];
   }
   ```

3. **Install minimal system:**
   ```bash
   sudo nixos-install
   # This will prompt for root password - set it
   ```

4. **Set user password:**
   ```bash
   sudo nixos-enter --root /mnt
   passwd YOUR_USERNAME
   exit
   ```

5. **Configure passwordless sudo for deployment:**
   ```bash
   sudo nixos-enter --root /mnt
   
   # Check if /etc/sudoers includes .d directory
   grep -i "includedir" /etc/sudoers
   
   # If not present, add it:
   echo "" >> /etc/sudoers
   echo "## Read drop-in files from /etc/sudoers.d" >> /etc/sudoers
   echo "@includedir /etc/sudoers.d" >> /etc/sudoers
   
   # Create user sudoers file
   mkdir -p /etc/sudoers.d
   echo "YOUR_USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/YOUR_USERNAME
   chmod 440 /etc/sudoers.d/YOUR_USERNAME
   
   exit
   ```

6. **Reboot:**
   ```bash
   sudo reboot
   # Remove USB drive when prompted
   ```

### Phase 5: Remote Deployment from Management Machine

After the machine boots into the minimal NixOS install:

1. **Find the machine's IP address:**
   
   On the target machine:
   ```bash
   ip addr show
   # Look for inet address on wlan0 (WiFi) or eth0/enp* (Ethernet)
   ```
   
   Or scan your network from management machine:
   ```bash
   nmap -sn 192.168.1.0/24  # Adjust subnet to your network
   ```

2. **Set up SSH key authentication:**
   ```bash
   # From your management machine
   ssh-copy-id YOUR_USERNAME@TARGET_IP
   
   # Test SSH works without password
   ssh YOUR_USERNAME@TARGET_IP
   exit
   ```

3. **Update flake with target IP:**
   
   Edit `flake/nixos.nix`:
   ```nix
   hostname = {
     imports = [../hosts/hostname/configuration.nix];
     deployment = {
       targetHost = "192.168.1.XXX";  # Use actual IP
       targetUser = "YOUR_USERNAME";
       allowLocalDeployment = true;
       buildOnTarget = true;
     };
   };
   ```

4. **Deploy your full flake configuration:**
   ```bash
   # From your management machine
   git add flake/nixos.nix
   git commit -m "feat: add hostname deployment config"
   git push
   
   # Deploy using Colmena
   colmena apply --on hostname
   # Or use your alias: nrr hostname
   ```

5. **Wait for deployment:**
   - First deployment will take 5-15 minutes
   - Machine may reboot during switch
   - SSH connection may drop temporarily
   - Check target machine's screen for progress

6. **Verify deployment:**
   ```bash
   # After deployment completes, SSH back in
   ssh YOUR_USERNAME@TARGET_IP
   
   # Check system info
   nixos-version
   hostname
   
   # Verify your user environment loaded
   echo $SHELL
   ls ~/.config/
   ```

### Phase 6: Post-Installation

1. **Set up static IP or DNS entry** (optional but recommended):
   - Configure router DHCP reservation
   - Or set up local DNS entry (e.g., `hostname.local`)
   - Update flake's `targetHost` to use hostname instead of IP

2. **Remove manual sudo config:**
   
   Your flake should manage sudo via `security.sudo.wheelNeedsPassword = false`. The manual sudoers config will be replaced on next deployment, or you can manually remove it:
   ```bash
   ssh YOUR_USERNAME@TARGET_IP
   sudo rm /etc/sudoers.d/YOUR_USERNAME
   # Your flake's security config will handle this going forward
   ```

3. **Future deployments:**
   ```bash
   # From management machine, just run:
   nrr hostname
   
   # All changes are now declarative in your flake
   ```

### Common Issues and Solutions

#### Issue: Machine boots but wrong IP address

**Solution:** Check both WiFi and Ethernet interfaces. Some machines may connect via unexpected interface:
```bash
ip addr show  # Check all interfaces
ip route      # Check default route
```

#### Issue: SSH connection refused

**Solution:** Verify sshd is running:
```bash
# On target machine
systemctl status sshd
systemctl enable --now sshd
```

#### Issue: Colmena deployment hangs on "stopping services"

**Cause:** Some services may not stop cleanly, or machine is rebooting.

**Solution:** 
- Wait 5-10 minutes for potential reboot
- Check target machine's screen for status
- If truly stuck, manually reboot target machine
- Re-run deployment: `nrr hostname`

#### Issue: sudo still asks for password during deployment

**Cause:** The `@includedir /etc/sudoers.d` line is missing from `/etc/sudoers`.

**Solution:** 
```bash
ssh YOUR_USERNAME@TARGET_IP
su -
grep -i "includedir" /etc/sudoers
# If missing, add:
echo "" >> /etc/sudoers
echo "@includedir /etc/sudoers.d" >> /etc/sudoers
exit
```

#### Issue: Disko fails with "device busy"

**Cause:** Existing partitions are mounted or in use.

**Solution:**
```bash
# Unmount all partitions
sudo umount -R /mnt
# Or force if needed
sudo umount -f -R /mnt
# Rerun Disko
```

#### Issue: Can't find machine's IP after boot

**Solutions:**
1. **Check router's DHCP leases** (via router admin page)
2. **Check ARP table** from management machine:
   ```bash
   arp -a | grep -i VENDOR_NAME
   ```
3. **Use serial console** (if available on target hardware)
4. **Boot back into USB** and check network config

### Disko Configuration Example

Example encrypted btrfs layout with best practices:

```nix
{
  # Description of target disk
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";  # Adjust to your disk
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "1G";  # Larger for multiple generations
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
                  allowDiscards = true;      # Enable TRIM for SSDs
                  bypassWorkqueues = true;   # Better SSD performance
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
                      swap.swapfile.size = "32G";  # Adjust to your RAM
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

  # Needed for boot
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
```

### Time Estimates

- **Creating Ventoy USB**: 5-10 minutes
- **Booting from USB**: 1-2 minutes
- **Network setup**: 1-5 minutes
- **Disko partitioning**: 2-5 minutes
- **Minimal install**: 5-10 minutes
- **Remote deployment**: 5-15 minutes (first time)
- **Total rescue operation**: 30-45 minutes

### Success Checklist

- ✅ Machine boots from Ventoy USB
- ✅ NixOS installer ISO loaded
- ✅ Network connectivity established
- ✅ Disk encrypted and partitioned via Disko
- ✅ Minimal NixOS boots successfully
- ✅ SSH key authentication working
- ✅ Colmena deployment succeeds
- ✅ Machine boots into your full flake configuration
- ✅ User environment loads correctly
- ✅ Can SSH in with your user account

## Summary

The Ventoy Web UI module provides:

1. **Network-accessible USB management** - No need for direct server access
2. **Simple deployment** - Single NixOS module with minimal configuration
3. **Reliable rescue solution** - Works with problematic firmware that fails PXE boot
4. **Multi-ISO support** - One USB for multiple operating systems/tools
5. **Declarative configuration** - Fully integrated with NixOS module system

**The complete rescue workflow:**
1. Create Ventoy USB with NixOS ISO
2. Boot broken machine from USB
3. Use Disko for encrypted partitioning
4. Install minimal NixOS bootstrap
5. Remote deploy full flake configuration via Colmena
6. Machine is fully recovered and declaratively configured

This approach proved "astonishingly easy" compared to complex netboot debugging and provides a reliable fallback for rescue operations.
