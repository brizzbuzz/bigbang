{
  config,
  lib,
  ...
}: let
  cfg = config.host.blocky;
in {
  options.host.blocky = {
    enable = lib.mkEnableOption "Blocky DNS proxy and ad-blocker";

    port = lib.mkOption {
      type = lib.types.port;
      default = 53;
      description = "Port for incoming DNS queries";
    };

    upstreams = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "https://one.one.one.one/dns-query" # Cloudflare DoH
        "https://dns.google/dns-query" # Google DoH
      ];
      description = "Upstream DNS servers";
    };

    blocking = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable DNS blocking functionality";
      };

      lists = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://someonewhocares.org/hosts/zero/hosts"
            "https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/adservers.txt"
          ];
          malware = [
            "https://malware-filter.gitlab.io/malware-filter/urlhaus-filter-hosts.txt"
            "https://blocklistproject.github.io/Lists/malware.txt"
          ];
          tracking = [
            "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
            "https://blocklistproject.github.io/Lists/tracking.txt"
          ];
        };
        description = "Block lists organized by category";
      };

      clientGroups = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {
          default = ["ads" "malware" "tracking"];
        };
        description = "Client groups and their associated block categories";
      };
    };

    caching = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable DNS response caching";
      };

      minTime = lib.mkOption {
        type = lib.types.str;
        default = "5m";
        description = "Minimum cache time";
      };

      maxTime = lib.mkOption {
        type = lib.types.str;
        default = "30m";
        description = "Maximum cache time";
      };

      prefetching = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable DNS prefetching";
      };
    };

    customDNS = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable custom DNS mapping for local network";
      };

      mapping = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          "chateaubr.ink" = "192.168.11.1";
          "callisto.chateaubr.ink" = "192.168.11.10";
          "ganymede.chateaubr.ink" = "192.168.11.11";
        };
        description = "Custom DNS mappings for local domains";
      };
    };

    metrics = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Prometheus metrics";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 4000;
        description = "Port for metrics endpoint";
      };
    };

    logLevel = lib.mkOption {
      type = lib.types.enum ["trace" "debug" "info" "warn" "error"];
      default = "info";
      description = "Log level for Blocky";
    };
  };

  config = lib.mkIf cfg.enable {
    services.blocky = {
      enable = true;
      settings = {
        ports = {
          dns = cfg.port;
          http = cfg.metrics.port;
        };

        # Upstream DNS configuration
        upstreams.groups.default = cfg.upstreams;

        # Bootstrap DNS for DoH/DoT resolution
        bootstrapDns = {
          upstream = "https://one.one.one.one/dns-query";
          ips = ["1.1.1.1" "1.0.0.1"];
        };

        # Conditional upstream for local network
        conditional = {
          mapping = {
            "chateaubr.ink" = "192.168.11.1"; # Use UniFi router for local domains
          };
        };

        # Custom DNS mappings
        customDNS = lib.mkIf cfg.customDNS.enable {
          customTTL = "1h";
          mapping = cfg.customDNS.mapping;
        };

        # Blocking configuration
        blocking = lib.mkIf cfg.blocking.enable {
          blackLists = cfg.blocking.lists;
          clientGroupsBlock = cfg.blocking.clientGroups;

          # Block TTL and refresh settings
          blockTTL = "1m";
          refreshPeriod = "4h";
          downloadTimeout = "4m";
          downloadAttempts = 5;
          downloadCooldown = "10s";

          # Processing concurrency
          processingConcurrency = 4;

          # Block type - return NXDOMAIN for blocked queries
          blockType = "zeroIp";

          # Whitelist for common false positives
          whiteLists = {
            allowlist = [
              # Add common false positives here
              "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
            ];
          };
        };

        # Caching configuration
        caching = lib.mkIf cfg.caching.enable {
          minTime = cfg.caching.minTime;
          maxTime = cfg.caching.maxTime;
          prefetching = cfg.caching.prefetching;
        };

        # Prometheus metrics
        prometheus = lib.mkIf cfg.metrics.enable {
          enable = true;
          path = "/metrics";
        };

        # Query logging for debugging
        queryLog = {
          type = "console";
          target = "";
          logRetentionDays = 7;
        };

        # Log configuration
        log = {
          level = cfg.logLevel;
          format = "text";
          timestamp = true;
        };

        # Note: EDE and certspotter features not available in this Blocky version
      };
    };

    # Open firewall for DNS
    networking.firewall = {
      allowedTCPPorts = [cfg.port] ++ lib.optional cfg.metrics.enable cfg.metrics.port;
      allowedUDPPorts = [cfg.port];
    };

    # Ensure Blocky starts after network is ready
    systemd.services.blocky = {
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        # Add some additional hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
      };
    };
  };
}
