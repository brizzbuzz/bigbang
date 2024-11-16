# BigBang 🌌

A comprehensive NixOS and Darwin configuration system focused on developer productivity, system reliability, and seamless cross-platform compatibility.

## Overview

BigBang is a unified configuration system that manages:
- Multiple NixOS systems (Desktop & Server)
- macOS systems via nix-darwin
- Home Manager configurations
- Development environments
- Custom system services

## 🏗 System Configurations

### NixOS Hosts
- **frame**: Framework laptop configuration
- **gigame**: Gaming desktop with NVIDIA support
- **cloudy**: Server configuration with various services

### Darwin Hosts
- **macme**: macOS configuration with Homebrew integration

## 🚀 Features

### Core Infrastructure
- **Flake-based**: Modern Nix configuration using flakes
- **Colmena**: Declarative deployment system for multiple hosts
- **Home Manager**: Consistent user environment across all systems
- **nix-darwin**: macOS system configuration
- **Homebrew**: Managed via nix-homebrew for macOS

### Desktop Environment
- **Hyprland**: Wayland compositor with custom configuration
- **Waybar**: Status bar with system metrics
- **SDDM**: Display manager with Catppuccin theme
- **Various WM Tools**: wofi, wlogout, hyprlock, etc.

### Development Tools
- **NixVim**: Fully configured Neovim setup
- **Development Shells**: Via devenv
- **Git Integration**: Including signing and SSH configuration
- **Terminal Setup**:
  - Alacritty as terminal emulator
  - Nushell as primary shell
  - Starship prompt
  - Zellij terminal multiplexer

### Applications & Services
- **Attic**: Binary cache server
- **Jellyfin**: Media server
- **Minio**: S3-compatible object storage
- **Soft Serve**: Git server
- **Glance**: Dashboard for system monitoring
- **PostgreSQL**: Database server
- **Speedtest**: Network performance monitoring
- **Transmission**: Torrent client

### Security & System
- **1Password**: Password management with CLI and GUI
- **Polkit**: Authentication agent
- **YubiKey**: Hardware security key support
- **Tailscale**: VPN networking
- **Fingerprint Reader**: Biometric authentication
- **SSH**: Advanced SSH configuration

### Custom Elements
- **Overlays**: Custom package modifications
- **Derivations**: Custom package builds
  - speedtest-go
  - supermaven-nvim

## 🔧 Usage

### System Management
```nushell
# Apply local configuration
nr  # shorthand for sudo colmena apply-local

# Apply configuration to all hosts
nrr  # shorthand for sudo colmena apply --on
```

### Development Environment
```nushell
# Enter development shell
nix develop

# Available development tools:
- git-cliff  # Changelog generator
- nurl       # Nix URL fetcher
- tokei      # Code statistics
```

## 📁 Project Structure
```
.
├── flake.nix              # Main flake configuration
├── hosts/                 # Host-specific configurations
│   ├── cloudy/           # Server configuration
│   ├── frame/            # Framework laptop
│   ├── gigame/           # Gaming desktop
│   └── macme/            # macOS configuration
├── modules/              # Shared configuration modules
│   ├── common/          # Cross-platform modules
│   ├── darwin/          # macOS-specific modules
│   ├── derivations/     # Custom packages
│   ├── home-manager/    # User environment configuration
│   ├── nixos/          # NixOS-specific modules
│   └── overlays/       # Package modifications
└── secrets.json        # 1Password secrets configuration
```

## 🔐 Secrets Management
- Uses 1Password for secrets management
- Integrates with opnix for secure secret retrieval
- Supports various service credentials (Attic, Minio, Tailscale)

## 🎨 Theming
- Primary theme: Catppuccin Macchiato
- Consistent across:
  - Terminal
  - Editor
  - Desktop environment
  - System applications

## 🛠 Contributing
1. Fork the repository
2. Create a feature branch
3. Commit changes (following conventional commits)
4. Submit a pull request

## 📜 License
This project is open source and available under the MIT license.
