{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.vpn;
  vpnEnabled = cfg.enable && cfg.backend == "openvpn";
  instanceName = cfg.instanceName;
  interfaceName = cfg.interfaceName;
  routingUsers = cfg.routing.users;
  userUids = map (user: toString config.users.users.${user}.uid) routingUsers;
  uidSet = lib.concatStringsSep ", " userUids;
  allowV4 = lib.filter (cidr: !(lib.hasInfix ":" cidr)) cfg.killswitch.allowCidrs;
  allowV6 = lib.filter (cidr: lib.hasInfix ":" cidr) cfg.killswitch.allowCidrs;
  allowV4Set = lib.concatStringsSep ", " allowV4;
  allowV6Set = lib.concatStringsSep ", " allowV6;
  runConfigPath = "/run/vpn/${instanceName}.ovpn";
  authPathValue =
    if cfg.authPath == null
    then ""
    else cfg.authPath;
  openvpnConfig = lib.concatStringsSep "\n" [
    "config ${runConfigPath}"
  ];
in {
  options.services.vpn = {
    enable = lib.mkEnableOption "VPN support";

    backend = lib.mkOption {
      type = lib.types.enum ["openvpn"];
      default = "openvpn";
      description = "VPN backend implementation.";
    };

    instanceName = lib.mkOption {
      type = lib.types.str;
      default = "proton";
      description = "OpenVPN instance name used in systemd units.";
    };

    interfaceName = lib.mkOption {
      type = lib.types.str;
      default = "proton0";
      description = "OpenVPN tunnel interface name.";
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      description = "Absolute path to the OpenVPN config file (.ovpn).";
    };

    authPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Absolute path to the auth-user-pass file.";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start the OpenVPN instance at boot.";
    };

    extraOpenvpnArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra OpenVPN config directives to append.";
    };

    routing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable UID-based routing via the VPN interface.";
      };

      table = lib.mkOption {
        type = lib.types.int;
        default = 51820;
        description = "Routing table ID for VPN traffic.";
      };

      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Usernames routed via the VPN interface.";
      };
    };

    killswitch = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable a VPN killswitch for selected users.";
      };

      allowCidrs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "127.0.0.0/8"
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
          "::1"
          "fc00::/7"
          "fe80::/10"
        ];
        description = "CIDRs exempt from the killswitch (local/LAN ranges).";
      };
    };
  };

  config = lib.mkIf vpnEnabled {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.configPath;
        message = "services.vpn.configPath must be an absolute path.";
      }
      {
        assertion = cfg.authPath == null || lib.hasPrefix "/" cfg.authPath;
        message = "services.vpn.authPath must be an absolute path when set.";
      }
      {
        assertion = !(cfg.routing.enable || cfg.killswitch.enable) || cfg.routing.users != [];
        message = "services.vpn.routing.users must be set when routing or killswitch is enabled.";
      }
    ];

    services.openvpn.servers.${instanceName} = {
      config = openvpnConfig;
      autoStart = cfg.autoStart;
    };

    systemd.services."vpn-config-${instanceName}" = {
      description = "Prepare OpenVPN config for ${instanceName}";
      wantedBy = ["openvpn-${instanceName}.service"];
      before = ["openvpn-${instanceName}.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -eu

        ${pkgs.coreutils}/bin/install -d -m 0750 /run/vpn
        if [ -n "${authPathValue}" ]; then
          ${pkgs.gnused}/bin/sed \
            -e '/update-resolv-conf/d' \
            -e '/^script-security/d' \
            -e '/^up /d' \
            -e '/^down /d' \
            -e '/^auth-user-pass/d' \
            "${cfg.configPath}" > "${runConfigPath}"
        else
          ${pkgs.gnused}/bin/sed \
            -e '/update-resolv-conf/d' \
            -e '/^script-security/d' \
            -e '/^up /d' \
            -e '/^down /d' \
            "${cfg.configPath}" > "${runConfigPath}"
        fi

        ${lib.optionalString (cfg.authPath != null) ''
          printf '%s\n' "auth-user-pass ${cfg.authPath}" >> "${runConfigPath}"
        ''}
        printf '%s\n' "dev ${interfaceName}" >> "${runConfigPath}"
        printf '%s\n' "dev-type tun" >> "${runConfigPath}"

        ${lib.concatStringsSep "\n" (map (line: "printf '%s\\n' \"${line}\" >> \"${runConfigPath}\"") cfg.extraOpenvpnArgs)}

        ${pkgs.coreutils}/bin/chmod 0600 "${runConfigPath}"
      '';
    };

    systemd.services."openvpn-${instanceName}" = {
      requires = ["vpn-config-${instanceName}.service"];
      after = ["vpn-config-${instanceName}.service"];
    };

    systemd.services."vpn-routing-${instanceName}" = lib.mkIf cfg.routing.enable {
      description = "Route selected users via VPN (${instanceName})";
      after = ["openvpn-${instanceName}.service"];
      requires = ["openvpn-${instanceName}.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail

        ip="${pkgs.iproute2}/bin/ip"
        table="${toString cfg.routing.table}"
        dev="${interfaceName}"

        i=0
        while [ "$i" -lt 15 ]; do
          if "$ip" link show "$dev" >/dev/null 2>&1; then
            break
          fi
          sleep 1
          i=$((i + 1))
        done

        ${lib.concatStringsSep "\n" (map (uid: ''"$ip" rule add uidrange ${uid}-${uid} table main priority 50 2>/dev/null || true'') userUids)}
        ${lib.concatStringsSep "\n" (map (cidr: lib.concatStringsSep "\n" (map (uid: ''"$ip" rule add uidrange ${uid}-${uid} to ${cidr} table main priority 50 2>/dev/null || true'') userUids)) allowV4)}
        ${lib.concatStringsSep "\n" (map (uid: ''"$ip" rule add uidrange ${uid}-${uid} table "$table" priority 100 2>/dev/null || true'') userUids)}
        ${lib.optionalString (allowV6 != [] && userUids != []) ''
          ip6="${pkgs.iproute2}/bin/ip"
          ${lib.concatStringsSep "\n" (map (cidr: lib.concatStringsSep "\n" (map (uid: ''"$ip6" -6 rule add uidrange ${uid}-${uid} to ${cidr} table main priority 50 2>/dev/null || true'') userUids)) allowV6)}
        ''}
        "$ip" route replace default dev "$dev" table "$table" 2>/dev/null || true
      '';
      preStop = ''
        ip="${pkgs.iproute2}/bin/ip"
        table="${toString cfg.routing.table}"
        dev="${interfaceName}"

        ${lib.concatStringsSep "\n" (map (uid: ''"$ip" rule del uidrange ${uid}-${uid} table main priority 50 2>/dev/null || true'') userUids)}
        ${lib.concatStringsSep "\n" (map (cidr: lib.concatStringsSep "\n" (map (uid: ''"$ip" rule del uidrange ${uid}-${uid} to ${cidr} table main priority 50 2>/dev/null || true'') userUids)) allowV4)}
        ${lib.concatStringsSep "\n" (map (uid: ''"$ip" rule del uidrange ${uid}-${uid} table "$table" priority 100 2>/dev/null || true'') userUids)}
        ${lib.optionalString (allowV6 != [] && userUids != []) ''
          ip6="${pkgs.iproute2}/bin/ip"
          ${lib.concatStringsSep "\n" (map (cidr: lib.concatStringsSep "\n" (map (uid: ''"$ip6" -6 rule del uidrange ${uid}-${uid} to ${cidr} table main priority 50 2>/dev/null || true'') userUids)) allowV6)}
        ''}
        "$ip" route del default dev "$dev" table "$table" 2>/dev/null || true
      '';
    };

    networking.nftables = lib.mkIf cfg.killswitch.enable {
      enable = lib.mkDefault true;
      ruleset = lib.mkAfter ''
        table inet vpn_killswitch_${instanceName} {
          chain output_killswitch {
            type filter hook output priority 0; policy accept;
            ${lib.optionalString (allowV4 != [] && userUids != []) "meta skuid { ${uidSet} } ip daddr != { ${allowV4Set} } oifname != \"${interfaceName}\" drop"}
            ${lib.optionalString (allowV6 != [] && userUids != []) "meta skuid { ${uidSet} } ip6 daddr != { ${allowV6Set} } oifname != \"${interfaceName}\" drop"}
          }
        }
      '';
    };
  };
}
