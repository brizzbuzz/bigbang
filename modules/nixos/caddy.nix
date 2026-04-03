{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.web.caddy;

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

    handle_errors {
      @upstreamUnavailable expression `{http.error.status_code} == 502 || {http.error.status_code} == 503 || {http.error.status_code} == 504`
      respond @upstreamUnavailable "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>Service waking up</title><style>body{margin:0;font-family:ui-sans-serif,system-ui,sans-serif;background:#0b1220;color:#e5edf7;display:grid;place-items:center;min-height:100vh}main{max-width:38rem;padding:2rem}.box{background:#121b2d;border:1px solid #27324a;border-radius:16px;padding:2rem;box-shadow:0 20px 60px rgba(0,0,0,.35)}h1{margin:0 0 .75rem;font-size:2rem}p{margin:.5rem 0;line-height:1.5;color:#b7c4d6}code{background:#0f1726;padding:.15rem .4rem;border-radius:6px;color:#fff}</style></head><body><main class=\"box\"><h1>That service is not reachable right now.</h1><p>The app behind <code>{host}</code> did not answer in time.</p><p>This usually means the service is restarting, sleeping, or temporarily unhealthy. Wait a few seconds and reload.</p></main></body></html>" 503
    }
  '';

  mkStaticTlsConfig = certPath: keyPath: ''
    tls ${certPath} ${keyPath}
  '';

  mkAcmeDnsTlsConfig = dnsProvider: dnsApiTokenEnvVar: resolvers: ''
    tls {
      dns ${dnsProvider} ${"{$" + dnsApiTokenEnvVar + "}"}
      ${lib.optionalString (resolvers != []) "resolvers ${lib.concatStringsSep " " resolvers}"}
    }
  '';

  # Full proxy configuration with websocket support using supplied TLS configuration
  mkProxyConfig = name: target: level: tlsConfig: ''
    ${tlsConfig}

    ${mkLogBlock name level}

    ${mkWebsocketMatcher}
    ${mkWebsocketProxy target}
    ${mkReverseProxy target}
  '';

  # Simple helper for static responses using specified TLS certificates
  mkStaticResponse = content: tlsConfig: ''
    ${tlsConfig}
    respond "${content}"
  '';

  # Default cert paths (for rgbr.ink domain)
  defaultCertPath = config.services.onepassword-secrets.secretPaths.sslCloudflareCert;
  defaultKeyPath = config.services.onepassword-secrets.secretPaths.sslCloudflareKey;
  defaultStaticTlsConfig = mkStaticTlsConfig defaultCertPath defaultKeyPath;

  # Base domain
  domain = cfg.domain;

  # Generate virtual hosts from services
  generateVirtualHosts = let
    # Root site
    rootSite = lib.optionalAttrs cfg.sites.root.enable {
      "${domain}" = {
        extraConfig = mkStaticResponse cfg.sites.root.content defaultStaticTlsConfig;
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
            extraConfig = mkProxyConfig name site.target site.logLevel defaultStaticTlsConfig;
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
              (mkStaticTlsConfig
                config.services.onepassword-secrets.secretPaths.${site.tlsCertSecret}
                config.services.onepassword-secrets.secretPaths.${site.tlsKeySecret});
          }
      ) (lib.filterAttrs (_name: site: site.enable)
        cfg.sites.standalone);

    internalSites = lib.mapAttrs' (
      name: site:
        lib.nameValuePair (
          if site.subdomain == ""
          then cfg.internal.domain
          else "${site.subdomain}.${cfg.internal.domain}"
        ) {
          extraConfig = mkProxyConfig name site.target site.logLevel (
            mkAcmeDnsTlsConfig
            cfg.internal.acme.dnsProvider
            cfg.internal.acme.dnsApiTokenEnvVar
            cfg.internal.acme.resolvers
          );
        }
    ) (lib.filterAttrs (_name: site: site.enable) cfg.internal.sites);
  in
    rootSite // proxySites // standaloneSites // lib.optionalAttrs cfg.internal.enable internalSites;
in {
  options.services.web.caddy = {
    enable = lib.mkEnableOption "Enable Caddy reverse proxy";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "rgbr.ink";
      description = "The primary domain name";
    };

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

    internal = {
      enable = lib.mkEnableOption "Enable internal LAN sites";

      domain = lib.mkOption {
        type = lib.types.str;
        default = "lan.rgbr.ink";
        description = "The internal LAN domain served by Caddy";
      };

      acme = {
        dnsProvider = lib.mkOption {
          type = lib.types.str;
          default = "cloudflare";
          description = "Caddy DNS provider module used for ACME DNS-01";
        };

        dnsApiTokenEnvVar = lib.mkOption {
          type = lib.types.str;
          default = "CLOUDFLARE_API_TOKEN";
          description = "Environment variable name containing the DNS API token";
        };

        resolvers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "1.1.1.1"
            "1.0.0.1"
          ];
          description = "Resolvers used by Caddy during ACME DNS-01 validation";
        };
      };

      sites = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Enable this internal site";
            subdomain = lib.mkOption {
              type = lib.types.str;
              description = "Subdomain for this internal service";
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
        description = "Internal LAN proxy sites using ACME DNS-01 certificates";
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
    services.web.caddy.sites.root.enable = lib.mkDefault true;

    # Default proxy configurations
    services.web.caddy.sites.proxies = lib.mkDefault {
      media = {
        enable = false;
        subdomain = "media";
        target = "ganymede.lan.rgbr.ink:8096";
        logLevel = "DEBUG";
      };
    };

    # Default standalone configurations
    services.web.caddy.sites.standalone = lib.mkDefault {};

    services.web.caddy.internal.sites = lib.mkDefault {};

    services.caddy = {
      enable = true;
      package = lib.mkIf cfg.internal.enable (pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
        hash = "sha256-Olz4W84Kiyldy+JtbIicVCL7dAYl4zq+2rxEOUTObxA=";
      });
      virtualHosts = generateVirtualHosts;
    };

    # Ensure Caddy starts after OpNix secrets are available
    systemd.services.caddy.after = ["opnix-secrets.service"];
    systemd.services.caddy.requires = ["opnix-secrets.service"];
    systemd.services.caddy.serviceConfig.EnvironmentFile = lib.mkIf cfg.internal.enable config.services.onepassword-secrets.secretPaths.cloudflareDnsApiTokenEnv;

    # Only open HTTPS port since we're using Cloudflare proxy
    networking.firewall.allowedTCPPorts = [443];
  };
}
