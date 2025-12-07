{
  config,
  lib,
  ...
}: let
  cfg = config.host.caddy;

  # TLS configuration using OpNix 0.7.0 managed Cloudflare Origin certificates
  # Moved to inline usage to avoid early evaluation issues
  # Helper function to create a log block
  mkLogBlock = name: level: ''
    log {
      output file /var/log/caddy/${name}.log
      format console
      level ${level}
    }
  '';

  # Helper function to create the websocket matcher
  mkWebsocketMatcher = ''
    @websockets {
      header Connection *Upgrade*
      header Upgrade websocket
    }
  '';

  # Helper function to create a reverse proxy config for websockets
  mkWebsocketProxy = target: ''
    handle @websockets {
      reverse_proxy ${target} {
        transport http {
          keepalive 2m
          versions 1.1 2
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
  '';

  # Helper function to create a standard reverse proxy config
  mkReverseProxy = target: ''
    handle {
      # Add security headers
      header {
        # Enable cross-origin isolation
        Cross-Origin-Embedder-Policy "require-corp"
        Cross-Origin-Opener-Policy "same-origin"
        Cross-Origin-Resource-Policy "same-origin"
        X-Frame-Options "SAMEORIGIN"
        Referrer-Policy "strict-origin-when-cross-origin"
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-XSS-Protection "1; mode=block"
        Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=(), interest-cohort=()"
      }

      reverse_proxy ${target} {
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
        fail_duration 10s
        lb_try_duration 5s
        lb_policy first
      }
    }
  '';

  # Full proxy configuration with websocket support using specified TLS certificates
  mkProxyConfig = name: target: level: certPath: keyPath: ''
    tls ${certPath} ${keyPath}

    ${mkLogBlock name level}

    ${mkWebsocketMatcher}
    ${mkWebsocketProxy target}
    ${mkReverseProxy target}
  '';

  # Simple helper for static responses using specified TLS certificates
  mkStaticResponse = content: certPath: keyPath: ''
    tls ${certPath} ${keyPath}
    respond "${content}"
  '';

  # Default cert paths (for rgbr.ink domain)
  defaultCertPath = config.services.onepassword-secrets.secretPaths.sslCloudflareCert;
  defaultKeyPath = config.services.onepassword-secrets.secretPaths.sslCloudflareKey;

  # Base domain
  domain = cfg.domain;

  # Generate virtual hosts from services
  generateVirtualHosts = let
    # Root site
    rootSite = lib.optionalAttrs cfg.sites.root.enable {
      "${domain}" = {
        extraConfig = mkStaticResponse cfg.sites.root.content defaultCertPath defaultKeyPath;
      };
    };

    # Handle proxy sites with standard websocket support (subdomains of primary domain)
    proxySites =
      lib.mapAttrs' (
        name: site:
          lib.nameValuePair (
            if site.subdomain == ""
            then domain
            else "${site.subdomain}.${domain}"
          ) {
            extraConfig = mkProxyConfig name site.target site.logLevel defaultCertPath defaultKeyPath;
          }
      ) (lib.filterAttrs (_name: site: site.enable)
        cfg.sites.proxies);

    # Handle standalone sites with custom domains and their own TLS certs
    standaloneSites =
      lib.mapAttrs' (
        name: site:
          lib.nameValuePair site.domain {
            extraConfig =
              mkProxyConfig name site.target site.logLevel
              config.services.onepassword-secrets.secretPaths.${site.tlsCertSecret}
              config.services.onepassword-secrets.secretPaths.${site.tlsKeySecret};
          }
      ) (lib.filterAttrs (_name: site: site.enable)
        cfg.sites.standalone);
  in
    rootSite // proxySites // standaloneSites;
in {
  options.host.caddy = {
    # The enable and domain options are already defined in modules/common/host-info.nix

    sites = {
      root = {
        enable = lib.mkEnableOption "Enable root site";
        content = lib.mkOption {
          type = lib.types.str;
          default = "Hello, world!";
          description = "Content to display on root site";
        };
      };

      proxies = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Enable this proxy site";
            subdomain = lib.mkOption {
              type = lib.types.str;
              description = "Subdomain for this service";
            };
            target = lib.mkOption {
              type = lib.types.str;
              description = "Target address (host:port) for reverse proxy";
            };
            logLevel = lib.mkOption {
              type = lib.types.str;
              default = "INFO";
              description = "Log level for Caddy (DEBUG, INFO, WARN, ERROR)";
            };
          };
        });
        default = {};
        description = "Proxy sites configuration (subdomains of primary domain)";
      };

      standalone = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Enable this standalone site";
            domain = lib.mkOption {
              type = lib.types.str;
              description = "Full domain name for this site";
            };
            target = lib.mkOption {
              type = lib.types.str;
              description = "Target address (host:port) for reverse proxy";
            };
            tlsCertSecret = lib.mkOption {
              type = lib.types.str;
              description = "OpNix secret name for TLS certificate";
            };
            tlsKeySecret = lib.mkOption {
              type = lib.types.str;
              description = "OpNix secret name for TLS private key";
            };
            logLevel = lib.mkOption {
              type = lib.types.str;
              default = "INFO";
              description = "Log level for Caddy (DEBUG, INFO, WARN, ERROR)";
            };
          };
        });
        default = {};
        description = "Standalone sites with custom domains and TLS certificates";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Create log directory for Caddy
    system.activationScripts.caddyLogDir = ''
      mkdir -p /var/log/caddy
      chown caddy:caddy /var/log/caddy
    '';

    # Default configuration values
    host.caddy.sites.root.enable = lib.mkDefault true;

    # Default proxy configurations
    host.caddy.sites.proxies = lib.mkDefault {
      media = {
        enable = false;
        subdomain = "media";
        target = "ganymede.chateaubr.ink:8096";
        logLevel = "DEBUG";
      };
    };

    # Default standalone configurations
    host.caddy.sites.standalone = lib.mkDefault {};

    services.caddy = {
      enable = true;
      virtualHosts = generateVirtualHosts;
    };

    # Ensure Caddy starts after OpNix secrets are available
    systemd.services.caddy.after = ["opnix-secrets.service"];
    systemd.services.caddy.requires = ["opnix-secrets.service"];

    # Only open HTTPS port since we're using Cloudflare proxy
    networking.firewall.allowedTCPPorts = [443];
  };
}
