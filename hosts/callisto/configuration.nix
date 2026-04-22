{
  config,
  inputs,
  lib,
  ...
}: let
  ingressIp = "192.168.11.200";
  backendIp = "192.168.11.39";
  lanDomain = "lan.rgbr.ink";
  ingressHost = "callisto.${lanDomain}";
  backendHost = "ganymede.${lanDomain}";

  internalSites = {
    portfolio = {
      enable = true;
      subdomain = "portfolio";
      target = "${backendIp}:7877";
      logLevel = "INFO";
    };
    media = {
      enable = true;
      subdomain = "media";
      target = "${backendIp}:8096";
      logLevel = "INFO";
    };
    photos = {
      enable = true;
      subdomain = "photos";
      target = "${backendIp}:2283";
      logLevel = "INFO";
    };
    books = {
      enable = true;
      subdomain = "books";
      target = "${backendIp}:13378";
      logLevel = "INFO";
    };
    prowlarr = {
      enable = true;
      subdomain = "prowlarr";
      target = "${backendIp}:9696";
      logLevel = "INFO";
    };
    sonarr = {
      enable = true;
      subdomain = "sonarr";
      target = "${backendIp}:8989";
      logLevel = "INFO";
    };
    radarr = {
      enable = true;
      subdomain = "radarr";
      target = "${backendIp}:7878";
      logLevel = "INFO";
    };
    lidarr = {
      enable = true;
      subdomain = "lidarr";
      target = "${backendIp}:8686";
      logLevel = "INFO";
    };
    bazarr = {
      enable = true;
      subdomain = "bazarr";
      target = "${backendIp}:6767";
      logLevel = "INFO";
    };
    jellyseerr = {
      enable = true;
      subdomain = "jellyseerr";
      target = "${backendIp}:5055";
      logLevel = "INFO";
    };
    torrents = {
      enable = true;
      subdomain = "torrents";
      target = "${backendIp}:18080";
      logLevel = "INFO";
    };
    opencodeRyan = {
      enable = true;
      subdomain = "opencode-ryan";
      target = "${backendIp}:4096";
      logLevel = "INFO";
    };
    opencodeOdyssey = {
      enable = true;
      subdomain = "opencode-odyssey";
      target = "${backendIp}:4097";
      logLevel = "INFO";
    };
    dns = {
      enable = true;
      subdomain = "dns";
      target = "localhost:4000";
      logLevel = "INFO";
    };
    ventoy = {
      enable = true;
      subdomain = "ventoy";
      target = "localhost:24680";
      logLevel = "INFO";
    };
    clickhouse = {
      enable = true;
      subdomain = "clickhouse";
      target = "${backendIp}:8123";
      logLevel = "INFO";
    };
  };

  internalDnsMappings =
    lib.mapAttrs'
    (
      _: site:
        lib.nameValuePair
        (
          if site.subdomain == ""
          then lanDomain
          else "${site.subdomain}.${lanDomain}"
        )
        ingressIp
    )
    internalSites
    // {
      "${ingressHost}" = ingressIp;
      "${backendHost}" = backendIp;
      "chat.${lanDomain}" = ingressIp;
    };
in {
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
    users = ["ryan"]; # TODO: Read from config

    # Fully declarative secrets configuration
    secrets = {
      # SSL certificates for Caddy (rgbr.ink)
      sslCloudflareCert = {
        reference = "op://Homelab/Cloudflare Origin Certs/rgbr.ink/cert";
        path = "/var/lib/caddy/ssl/cloudflare-origin.pem";
        owner = "caddy";
        group = "caddy";
        mode = "0644";
        services = ["caddy"];
      };

      sslCloudflareKey = {
        reference = "op://Homelab/Cloudflare Origin Certs/rgbr.ink/privateKey";
        path = "/var/lib/caddy/ssl/cloudflare-origin.key";
        owner = "caddy";
        group = "caddy";
        mode = "0600";
        services = ["caddy"];
      };

      # SSL certificates for Caddy (ryanbr.ink)
      sslRyanbrCert = {
        reference = "op://Homelab/Cloudflare Origin Certs/ryanbr.ink/cert";
        path = "/var/lib/caddy/ssl/ryanbr-origin.pem";
        owner = "caddy";
        group = "caddy";
        mode = "0644";
        services = ["caddy"];
      };

      sslRyanbrKey = {
        reference = "op://Homelab/Cloudflare Origin Certs/ryanbr.ink/privateKey";
        path = "/var/lib/caddy/ssl/ryanbr-origin.key";
        owner = "caddy";
        group = "caddy";
        mode = "0600";
        services = ["caddy"];
      };

      cloudflareDnsApiTokenEnv = {
        reference = "op://Homelab/Cloudflare Caddy DNS Token/notesPlain";
        path = "/var/lib/caddy/cloudflare-dns.env";
        owner = "caddy";
        group = "caddy";
        mode = "0600";
        services = ["caddy"];
      };
    };

    # Enable systemd integration for reliable service management
    systemdIntegration = {
      enable = true;
      services = ["caddy"];
      restartOnChange = true;
    };
  };

  # Create SSL directories for OpNix-managed certificates
  systemd.tmpfiles.rules = [
    "d /var/lib/caddy/ssl 0750 caddy caddy -"
  ];

  system-limits = {
    enable = false;
  };

  host = {
    name = "callisto";
    roles.remote = true;
    userManagement.enable = true;
  };

  services.web.caddy = {
    enable = true;
    domain = "rgbr.ink";
    sites = {
      root = {
        enable = false;
        content = "Hello from callisto!";
      };
      proxies = {
        media = {
          enable = true;
          subdomain = "media";
          target = "${backendIp}:8096";
          logLevel = "DEBUG";
        };

        # torrents = {
        #   enable = true;
        #   subdomain = "torrents";
        #   target = "${backendHost}:18080";
        #   logLevel = "INFO";
        # };
        blocky = {
          enable = true;
          subdomain = "dns";
          target = "localhost:4000";
          logLevel = "INFO";
        };
        photos = {
          enable = true;
          subdomain = "photos";
          target = "${backendIp}:2283";
          logLevel = "INFO";
        };
        books = {
          enable = true;
          subdomain = "books";
          target = "${backendIp}:13378";
          logLevel = "INFO";
        };
      };
      # Portfolio now served via standalone ryanbr.ink domain
      standalone = {
        portfolio = {
          enable = true;
          domain = "ryanbr.ink";
          target = "${backendIp}:7877";
          tlsCertSecret = "sslRyanbrCert";
          tlsKeySecret = "sslRyanbrKey";
          logLevel = "INFO";
        };
      };
    };

    internal = {
      enable = true;
      domain = lanDomain;
      sites = internalSites;
    };
  };

  # Spacebar reverse proxy: multi-backend routing (API, CDN, Gateway)
  # configured directly via services.caddy.virtualHosts since it needs
  # path/protocol-based routing across multiple backend ports
  services.caddy.virtualHosts."rgbr.ink" = {
    extraConfig = let
      certPath = config.services.onepassword-secrets.secretPaths.sslCloudflareCert;
      keyPath = config.services.onepassword-secrets.secretPaths.sslCloudflareKey;
    in ''
      tls ${certPath} ${keyPath}
      redir https://ryanbr.ink{uri} permanent
    '';
  };

  services.caddy.virtualHosts."chat.rgbr.ink" = {
    extraConfig = let
      certPath = config.services.onepassword-secrets.secretPaths.sslCloudflareCert;
      keyPath = config.services.onepassword-secrets.secretPaths.sslCloudflareKey;
    in ''
      tls ${certPath} ${keyPath}

      log {
        output file /var/log/caddy/chat.log
        format console
        level INFO
      }

      # WebSocket connections -> Gateway
      @websockets {
        header Connection *Upgrade*
        header Upgrade websocket
      }
      handle @websockets {
        reverse_proxy ${backendIp}:13003 {
          transport http {
            keepalive 2m
            versions 1.1
          }
          header_up Host {host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
          header_up X-Forwarded-Host {host}
          header_up Connection "Upgrade"
          header_up Upgrade "websocket"
          health_timeout 5s
        }
      }

      # API requests -> API server
      @api {
        path /api/* /.well-known/*
      }
      handle @api {
        reverse_proxy ${backendIp}:13001 {
          transport http {
            keepalive 2m
            versions 1.1 2
          }
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
          header_up X-Forwarded-Host {host}
          health_timeout 5s
        }
      }

      # Image proxy -> API server
      @imageproxy {
        path /imageproxy/*
      }
      handle @imageproxy {
        reverse_proxy ${backendIp}:13001 {
          transport http {
            keepalive 2m
            versions 1.1 2
          }
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
          header_up X-Forwarded-Host {host}
          health_timeout 5s
        }
      }

      # Everything else (attachments, avatars, etc.) -> CDN
      handle {
        reverse_proxy ${backendIp}:13002 {
          transport http {
            keepalive 2m
            versions 1.1 2
          }
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
          header_up X-Forwarded-Host {host}
          health_timeout 5s
        }
      }
    '';
  };

  services.caddy.virtualHosts."chat.lan.rgbr.ink" = {
    extraConfig = ''
      tls {
        dns cloudflare {$CLOUDFLARE_API_TOKEN}
        resolvers 1.1.1.1 1.0.0.1
      }

      log {
        output file /var/log/caddy/chat-lan.log
        format console
        level INFO
      }

      @websockets {
        header Connection *Upgrade*
        header Upgrade websocket
      }
      handle @websockets {
        reverse_proxy ${backendIp}:13003 {
          transport http {
            keepalive 2m
            versions 1.1
          }
          header_up Host {host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
          header_up X-Forwarded-Host {host}
          header_up Connection "Upgrade"
          header_up Upgrade "websocket"
          health_timeout 5s
        }
      }

      @api {
        path /api/* /.well-known/*
      }
      handle @api {
        reverse_proxy ${backendIp}:13001 {
          transport http {
            keepalive 2m
            versions 1.1 2
          }
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
          header_up X-Forwarded-Host {host}
          health_timeout 5s
        }
      }

      @imageproxy {
        path /imageproxy/*
      }
      handle @imageproxy {
        reverse_proxy ${backendIp}:13001 {
          transport http {
            keepalive 2m
            versions 1.1 2
          }
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
          header_up X-Forwarded-Host {host}
          health_timeout 5s
        }
      }

      handle {
        reverse_proxy ${backendIp}:13002 {
          transport http {
            keepalive 2m
            versions 1.1 2
          }
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
          header_up X-Forwarded-Host {host}
          health_timeout 5s
        }
      }
    '';
  };

  services.dns.blocky = {
    enable = true;
    customDNS = {
      enable = true;
      mapping = internalDnsMappings;
    };
    blocking = {
      enable = true;
      clientGroups = {
        default = ["ads" "malware" "tracking"];
        kids = ["ads" "malware" "tracking"];
      };
    };
    caching = {
      enable = true;
      minTime = "5m";
      maxTime = "30m";
      prefetching = true;
    };
    logLevel = "info";
  };

  services.tools."ventoy-web" = {
    enable = true;
    port = 24680;
    bindAddress = "0.0.0.0";
  };

  system.stateVersion = "24.05";
}
