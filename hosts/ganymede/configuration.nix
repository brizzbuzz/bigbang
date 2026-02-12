{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.opnix.nixosModules.default
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/nixos
  ];

  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    users = ["ryan"];

    secrets = {
      protonWireguardConfig = {
        reference = "op://Homelab/ProtonVPN Wireguard Ganymede/notesPlain";
        path = "/etc/wireguard/proton.conf";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      portfolioEnv = {
        reference = "op://Homelab/Portfolio Secrets/notesPlain";
        path = "/var/lib/opnix/secrets/hyperbaric-portfolio.env";
        owner = "root";
        group = "root";
        mode = "0600";
        services = ["hyperbaric-portfolio"];
      };
    };

    systemdIntegration = {
      enable = true;
      services = [
        "hyperbaric-portfolio"
        "proton-wg"
      ];
      restartOnChange = true;
    };
  };

  host = {
    audiobookshelf.enable = true;
    name = "ganymede";

    gpu.nvidia.enable = true;
    immich.enable = true;
    jellyfin.server.enable = true;
    keyboard = "moonlander";
    portfolio = {
      enable = true;
      environmentFileSecrets = ["portfolioEnv"];
    };
    remote.enable = true;
    userManagement.enable = true;
  };

  system-limits = {
    enable = false;
  };

  # qBittorrent configuration (traffic routed via UniFi VPN policies)
  services.qbittorrent = {
    enable = true;
    webuiPort = 8080;
    torrentingPort = 6881;
    openFirewall = true;
    extraArgs = ["--confirm-legal-notice"];
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          LocalHostAuth = true;
          AuthSubnetWhitelistEnabled = true;
          AuthSubnetWhitelist = "127.0.0.1, ::1, 192.168.0.0/16, 172.16.0.0/12, 10.0.0.0/8";
        };
        Downloads = {
          SavePath = "/srv/torrents/complete";
          TempPathEnabled = true;
          TempPath = "/srv/torrents/incomplete";
        };
        Connection = {
          Interface = "proton-managed";
          InterfaceName = "proton-managed";
          PortRangeMin = 6881;
          PortRangeMax = 6881;
          UPnP = false;
          RandomPort = false;
        };
        BitTorrent = {
          Encryption = 1;
          AnonymousMode = true;
        };
      };
    };
  };

  users.users.qbittorrent.uid = 983;
  users.groups.qbittorrent.gid = 983;

  # Create torrent directories
  systemd.tmpfiles.rules = [
    "d /etc/wireguard 0700 root root -"
    "d /srv/torrents 0755 qbittorrent qbittorrent -"
    "d /srv/torrents/complete 0755 qbittorrent qbittorrent -"
    "d /srv/torrents/incomplete 0755 qbittorrent qbittorrent -"
  ];

  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet protonvpn {
        chain qbittorrent_mark {
          type route hook output priority -150; policy accept;
          meta skuid ${toString config.users.users.qbittorrent.uid} ip daddr != { 127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } mark set 0x1
          meta skuid ${toString config.users.users.qbittorrent.uid} ip6 daddr != { ::1, fc00::/7, fe80::/10 } mark set 0x1
        }

        chain qbittorrent_killswitch {
          type filter hook output priority 0; policy accept;
          meta skuid ${toString config.users.users.qbittorrent.uid} oifname != "proton-managed" ip daddr != { 127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } drop
          meta skuid ${toString config.users.users.qbittorrent.uid} oifname != "proton-managed" ip6 daddr != { ::1, fc00::/7, fe80::/10 } drop
        }
      }
    '';
  };

  systemd.services.proton-wg = {
    description = "ProtonVPN WireGuard (managed)";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      tmp_conf=$(${pkgs.coreutils}/bin/mktemp)
      ${pkgs.gnugrep}/bin/grep -v '^DNS' /etc/wireguard/proton.conf > "$tmp_conf"
      ${pkgs.coreutils}/bin/install -m 0600 -o root -g root "$tmp_conf" /etc/wireguard/proton-managed.conf
      ${pkgs.coreutils}/bin/rm -f "$tmp_conf"

      ${pkgs.wireguard-tools}/bin/wg-quick up /etc/wireguard/proton-managed.conf
    '';
    preStop = ''
      ${pkgs.wireguard-tools}/bin/wg-quick down /etc/wireguard/proton-managed.conf
    '';
  };

  systemd.services.proton-routing = {
    description = "Route marked qBittorrent traffic via ProtonVPN";
    after = ["proton-wg.service"];
    requires = ["proton-wg.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      ${pkgs.iproute2}/bin/ip route del default dev proton-managed 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip rule add fwmark 0x1 table 51820 priority 100 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip route add default dev proton-managed table 51820 2>/dev/null || true

      if ${pkgs.iproute2}/bin/ip -6 addr show dev proton-managed | ${pkgs.gnugrep}/bin/grep -q "inet6"; then
        ${pkgs.iproute2}/bin/ip -6 route del default dev proton-managed 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip -6 rule add fwmark 0x1 table 51820 priority 100 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip -6 route add default dev proton-managed table 51820 2>/dev/null || true
      fi
    '';
    preStop = ''
      ${pkgs.iproute2}/bin/ip -6 rule del fwmark 0x1 table 51820 priority 100 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip -6 route del default dev proton-managed table 51820 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip rule del fwmark 0x1 table 51820 priority 100 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip route del default dev proton-managed table 51820 2>/dev/null || true
    '';
  };

  systemd.services.proton-natpmpc = {
    description = "Maintain ProtonVPN NAT-PMP port forwarding";
    after = ["proton-wg.service" "proton-routing.service" "qbittorrent.service"];
    requires = ["proton-wg.service" "proton-routing.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
    };
    path = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.iproute2
      pkgs.libnatpmp
      pkgs.python3
      pkgs.systemd
    ];
    script = ''
      set -euo pipefail

      gateway="10.2.0.1"
      qb_config="/var/lib/qbittorrent/config/qBittorrent/qBittorrent.conf"
      current_port=""

      while true; do
        udp_output=$(natpmpc -a 1 0 udp 60 -g "$gateway" 2>&1 || true)
        udp_port=$(printf '%s\n' "$udp_output" | awk '/Mapped public port/ {print $4; exit}')

        tcp_output=$(natpmpc -a 1 0 tcp 60 -g "$gateway" 2>&1 || true)
        tcp_port=$(printf '%s\n' "$tcp_output" | awk '/Mapped public port/ {print $4; exit}')

        if [ -n "$udp_port" ] && [ "$udp_port" = "$tcp_port" ]; then
          if [ "$udp_port" != "$current_port" ] && [ -f "$qb_config" ]; then
            current_port="$udp_port"

            QBT_PORT="$udp_port" ${pkgs.python3}/bin/python3 - <<'PY'
import configparser
import os

config_path = "/var/lib/qbittorrent/config/qBittorrent/qBittorrent.conf"
port = os.environ["QBT_PORT"]

config = configparser.ConfigParser(interpolation=None)
config.optionxform = str
config.read(config_path)

if "Preferences" not in config:
    config["Preferences"] = {}

prefs = config["Preferences"]
prefs["Connection\\PortRangeMin"] = port
prefs["Connection\\PortRangeMax"] = port
prefs["Connection\\RandomPort"] = "false"
prefs["Connection\\UPnP"] = "false"

with open(config_path, "w", encoding="utf-8") as handle:
    config.write(handle)
PY

            ${pkgs.systemd}/bin/systemctl restart qbittorrent
          fi
        fi

        sleep 45
      done
    '';
  };

  systemd.services.qbittorrent = {
    after = [
      "proton-wg.service"
      "proton-routing.service"
    ];
    requires = [
      "proton-wg.service"
      "proton-routing.service"
    ];
  };

  # Enable PostgreSQL for home lab services and development
  services.postgresql = {
    enable = true;
    developmentMode = true;
    extensions = with config.services.postgresql.package.pkgs; [
      pgvector
    ];
    serviceDatabases = [
      "immich"
      "jellyfin"
    ];
    serviceUsers = [
      {
        name = "immich";
        database = "immich";
      }
      {
        name = "jellyfin";
        database = "jellyfin";
      }
    ];
    initialScript = pkgs.writeText "postgresql-init.sql" ''
      CREATE EXTENSION IF NOT EXISTS vector;
    '';
  };

  system.stateVersion = "24.05";
}
