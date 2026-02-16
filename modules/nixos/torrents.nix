{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.torrents;
  qb = cfg.qbittorrent;
  vpn = cfg.vpn;
  qbPasswordPath = "/var/lib/opnix/secrets/qbittorrent-webui-password";
  qbUsernamePath = "/var/lib/opnix/secrets/qbittorrent-webui-username";
  vpnConfigPath = "/etc/openvpn/proton.ovpn";
  vpnAuthPath = "/etc/openvpn/proton.auth";
in {
  options.services.torrents = {
    enable = lib.mkEnableOption "Enable torrenting services";

    qbittorrent = {
      webuiPort = lib.mkOption {
        type = lib.types.int;
        default = 8080;
        description = "qBittorrent WebUI port";
      };
      torrentingPort = lib.mkOption {
        type = lib.types.int;
        default = 6881;
        description = "qBittorrent torrenting port";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for qBittorrent";
      };
      savePath = lib.mkOption {
        type = lib.types.str;
        default = "/srv/torrents/complete";
        description = "Download destination for completed torrents";
      };
      tempPath = lib.mkOption {
        type = lib.types.str;
        default = "/srv/torrents/incomplete";
        description = "Temporary download location";
      };
      authSubnetWhitelist = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1, ::1, 192.168.0.0/16, 172.16.0.0/12, 10.0.0.0/8";
        description = "WebUI auth subnet whitelist";
      };
      userUid = lib.mkOption {
        type = lib.types.int;
        default = 985;
        description = "qBittorrent user UID";
      };
      groupGid = lib.mkOption {
        type = lib.types.int;
        default = 980;
        description = "qBittorrent group GID";
      };
      webuiUsernameSecretRef = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "1Password reference for the WebUI username";
      };
      webuiPasswordSecretRef = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "1Password reference for the WebUI password";
      };
    };

    vpn = {
      enable = lib.mkEnableOption "Enable VPN routing for torrents";
      instanceName = lib.mkOption {
        type = lib.types.str;
        default = "proton";
        description = "VPN instance name";
      };
      interfaceName = lib.mkOption {
        type = lib.types.str;
        default = "proton0";
        description = "VPN interface name";
      };
      openvpnConfigSecretRef = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "1Password reference for OpenVPN config";
      };
      openvpnAuthSecretRef = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "1Password reference for OpenVPN auth";
      };
      killswitchEnable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable VPN killswitch for torrent user";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = qb.webuiPasswordSecretRef != null;
        message = "services.torrents.qbittorrent.webuiPasswordSecretRef must be set.";
      }
      {
        assertion = (!vpn.enable) || (vpn.openvpnConfigSecretRef != null && vpn.openvpnAuthSecretRef != null);
        message = "services.torrents.vpn.openvpnConfigSecretRef and openvpnAuthSecretRef must be set when VPN is enabled.";
      }
    ];

    services.qbittorrent = {
      enable = true;
      webuiPort = qb.webuiPort;
      torrentingPort = qb.torrentingPort;
      openFirewall = qb.openFirewall;
      extraArgs = ["--confirm-legal-notice"];
      serverConfig = {
        LegalNotice.Accepted = true;
        Preferences = {
          WebUI = {
            LocalHostAuth = true;
            AuthSubnetWhitelistEnabled = true;
            AuthSubnetWhitelist = qb.authSubnetWhitelist;
          };
          Downloads = {
            SavePath = qb.savePath;
            TempPathEnabled = true;
            TempPath = qb.tempPath;
          };
          Connection = {
            PortRangeMin = qb.torrentingPort;
            PortRangeMax = qb.torrentingPort;
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

    users.users.qbittorrent.uid = qb.userUid;
    users.groups.qbittorrent.gid = qb.groupGid;

    systemd.tmpfiles.rules =
      [
        "d ${lib.dirOf qb.savePath} 0755 qbittorrent qbittorrent -"
        "d ${lib.dirOf qb.tempPath} 0755 qbittorrent qbittorrent -"
        "d ${qb.savePath} 0755 qbittorrent qbittorrent -"
        "d ${qb.tempPath} 0755 qbittorrent qbittorrent -"
      ]
      ++ lib.optional vpn.enable "d /etc/openvpn 0700 root root -";

    services.onepassword-secrets.secrets = lib.mkMerge [
      {
        qbittorrentWebuiPassword = {
          reference = qb.webuiPasswordSecretRef;
          path = qbPasswordPath;
          owner = "root";
          group = "root";
          mode = "0600";
        };
      }
      (lib.mkIf (qb.webuiUsernameSecretRef != null) {
        qbittorrentWebuiUsername = {
          reference = qb.webuiUsernameSecretRef;
          path = qbUsernamePath;
          owner = "root";
          group = "root";
          mode = "0600";
        };
      })
      (lib.mkIf vpn.enable {
        vpnOpenvpnConfig = {
          reference = vpn.openvpnConfigSecretRef;
          path = vpnConfigPath;
          owner = "root";
          group = "root";
          mode = "0600";
        };
        vpnOpenvpnAuth = {
          reference = vpn.openvpnAuthSecretRef;
          path = vpnAuthPath;
          owner = "root";
          group = "root";
          mode = "0600";
        };
      })
    ];

    services.onepassword-secrets.systemdIntegration.services =
      ["qbittorrent-webui-credentials"]
      ++ lib.optional vpn.enable "openvpn-${vpn.instanceName}";

    systemd.services.qbittorrent-webui-credentials = {
      description = "Set qBittorrent WebUI credentials";
      after = ["opnix-secrets.service"];
      requires = ["opnix-secrets.service"];
      wantedBy = ["qbittorrent.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      script = ''
                set -euo pipefail

                password_file="${qbPasswordPath}"
                username_file="${qbUsernamePath}"
                config_path="/var/lib/qBittorrent/config/qBittorrent/qBittorrent.conf"

                if [ ! -f "$password_file" ]; then
                  exit 1
                fi

                ${pkgs.coreutils}/bin/install -d -m 0750 "$(dirname "$config_path")"
                ${pkgs.python3}/bin/python3 - <<'PY'
        import base64
        import configparser
        import hashlib
        import os

        password_path = "${qbPasswordPath}"
        username_path = "${qbUsernamePath}"
        config_path = "/var/lib/qBittorrent/config/qBittorrent/qBittorrent.conf"

        with open(password_path, "r", encoding="utf-8") as handle:
            password = handle.read().strip()

        username = "admin"
        if os.path.exists(username_path):
            with open(username_path, "r", encoding="utf-8") as handle:
                value = handle.read().strip()
                if value:
                    username = value

        salt = os.urandom(16)
        dk = hashlib.pbkdf2_hmac("sha512", password.encode(), salt, 100000)
        encoded = f"@ByteArray({base64.b64encode(salt).decode()}:{base64.b64encode(dk).decode()})"

        config = configparser.ConfigParser(interpolation=None)
        config.optionxform = str
        config.read(config_path)

        if "Preferences" not in config:
            config["Preferences"] = {}

        prefs = config["Preferences"]
        prefs["WebUI\\Username"] = username
        prefs["WebUI\\Password_PBKDF2"] = encoded

        with open(config_path, "w", encoding="utf-8") as handle:
            config.write(handle)
        PY
      '';
    };

    systemd.services.qbittorrent = {
      after = ["qbittorrent-webui-credentials.service"];
      requires = ["qbittorrent-webui-credentials.service"];
    };

    services.vpn = lib.mkIf vpn.enable {
      enable = true;
      backend = "openvpn";
      instanceName = vpn.instanceName;
      interfaceName = vpn.interfaceName;
      configPath = vpnConfigPath;
      authPath = vpnAuthPath;
      routing = {
        enable = true;
        users = ["qbittorrent"];
      };
      killswitch.enable = vpn.killswitchEnable;
    };
  };
}
