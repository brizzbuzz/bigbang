{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.netboot;

  stateDir = cfg.stateDir;
  tftpRoot = cfg.tftpRoot;

  assetList = [
    {
      name = "netboot.xyz.kpxe";
      url = "https://boot.netboot.xyz/ipxe/netboot.xyz.kpxe";
    }
    {
      name = "netboot.xyz.efi";
      url = "https://boot.netboot.xyz/ipxe/netboot.xyz.efi";
    }
  ];

  assetSyncScript = pkgs.writeShellApplication {
    name = "netboot-assets-sync";
    runtimeInputs = [pkgs.coreutils pkgs.curl];
    text =
      ''
        set -euo pipefail

        target_root="${tftpRoot}"
        mkdir -p "$target_root"

        fetch() {
          local url="$1"
          local name="$2"
          local tmp
          tmp="$(mktemp)"
          trap 'rm -f "$tmp"' EXIT
          ${pkgs.curl}/bin/curl --fail --silent --show-error --location "$url" --output "$tmp"
          install -m 0644 "$tmp" "$target_root/$name"
          rm -f "$tmp"
          trap - EXIT
        }

      ''
      + lib.concatStringsSep "\n"
      (map (asset: ''fetch "${asset.url}" "${asset.name}"'') assetList)
      + "\n";
  };
in {
  options.host.netboot = {
    enable = lib.mkEnableOption "Netboot (PXE) services via dnsmasq and netboot.xyz";

    interface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Network interface dnsmasq should bind to. Leave null to listen on all interfaces.";
    };

    serverIp = lib.mkOption {
      type = lib.types.str;
      default = "192.168.11.10";
      description = "IP address advertised as the netboot server (next-server / option 66).";
      example = "192.168.11.10";
    };

    router = lib.mkOption {
      type = lib.types.str;
      default = "192.168.11.1";
      description = "Default gateway/router to advertise to netboot clients.";
    };

    dhcpRange = lib.mkOption {
      type = lib.types.str;
      default = "192.168.11.0,proxy,255.255.255.0";
      description = "dnsmasq proxy DHCP range definition.";
      example = "192.168.1.0,proxy,255.255.255.0";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/netboot";
      description = "Base directory used to store netboot assets.";
    };

    tftpRoot = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/netboot/tftp";
      description = "Directory served via TFTP.";
    };

    tftpPort = lib.mkOption {
      type = lib.types.int;
      default = 69;
      description = "TFTP port exposed for clients.";
    };

    mirrorNetbootXYZ = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to mirror netboot.xyz boot artifacts locally.";
    };

    updateSchedule = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "weekly";
      description = "systemd OnCalendar expression used to refresh mirrored artifacts. Set to null to disable periodic refresh.";
      example = "daily";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.mirrorNetbootXYZ && (cfg.tftpRoot == ""));
        message = "host.netboot.tftpRoot must be defined when mirroring netboot.xyz artifacts.";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${stateDir} 0755 root root -"
      "d ${tftpRoot} 0755 root root -"
    ];

    networking.firewall.allowedUDPPorts = lib.mkAfter [cfg.tftpPort 4011];
    networking.firewall.allowedUDPPortRanges = lib.mkAfter [
      {
        from = 32768;
        to = 60999;
      }
    ];
    networking.firewall.trustedInterfaces = lib.mkAfter (lib.optional (cfg.interface != null) cfg.interface);

    services.dnsmasq = {
      enable = true;
      settings =
        {
          port = 0;
          log-dhcp = true;
          "dhcp-range" = cfg.dhcpRange;
          "dhcp-option" = [
            "option:router,${cfg.router}"
            "option:tftp-server,${cfg.serverIp}"
          ];
          "dhcp-option-force" = [
            "66,${cfg.serverIp}"
            "67,netboot.xyz.kpxe"
          ];
          "dhcp-match" = "set:ipxe,175";
          "dhcp-boot" = [
            "tag:#ipxe,netboot.xyz.kpxe"
            "tag:ipxe,https://boot.netboot.xyz/ipxe/netboot.xyz.ipxe"
          ];
          "pxe-prompt" = "\"Network Boot\",5";
          "pxe-service" = [
            "tag:ipxe,x86PC,\"iPXE\",https://boot.netboot.xyz/ipxe/netboot.xyz.ipxe"
            "x86PC,\"PXE Boot\",netboot.xyz.kpxe"
          ];
          "enable-tftp" = true;
          "tftp-root" = tftpRoot;
        }
        // lib.optionalAttrs (cfg.interface != null) {
          interface = [cfg.interface];
          "bind-interfaces" = true;
        };
    };

    systemd.services.dnsmasq = lib.mkIf cfg.mirrorNetbootXYZ {
      requires = ["netboot-assets.service"];
      after = ["netboot-assets.service"];
    };

    systemd.services.netboot-assets = lib.mkIf cfg.mirrorNetbootXYZ {
      description = "Synchronize netboot.xyz assets for TFTP";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${assetSyncScript}/bin/netboot-assets-sync";
        User = "root";
      };
    };

    systemd.timers.netboot-assets = lib.mkIf (cfg.mirrorNetbootXYZ && cfg.updateSchedule != null) {
      description = "Refresh netboot.xyz assets";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.updateSchedule;
        Persistent = true;
        Unit = "netboot-assets.service";
      };
    };
  };
}
