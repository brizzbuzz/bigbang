{
  config,
  lib,
  ...
}: let
  # Helper function for TLS configuration
  tlsConfig = "/etc/ssl/certs/cloudflare-cert.pem /etc/ssl/private/cloudflare-key.pem";
  
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
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
        header_up Connection "Upgrade"
        header_up Upgrade "websocket"
        health_timeout 5s
      }
    }
  '';
  
  # Helper function to create a standard reverse proxy config
  mkReverseProxy = target: ''
    handle {
      reverse_proxy ${target} {
        transport http {
          keepalive 2m
          versions 1.1 2
        }
        header_up Host {host}
        header_up X-Real-IP {remote_host}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-Host {host}
        health_timeout 5s
        fail_duration 10s
        lb_try_duration 5s
        lb_policy first
      }
    }
  '';
  
  # Full proxy configuration with websocket support
  mkProxyConfig = name: target: level: ''
    tls ${tlsConfig}
    
    ${mkLogBlock name level}
    
    ${mkWebsocketMatcher}
    ${mkWebsocketProxy target}
    ${mkReverseProxy target}
  '';
  
  # Simple helper for static responses
  mkStaticResponse = content: ''
    tls ${tlsConfig}
    respond "${content}"
  '';
  
  # Base domain
  domain = config.host.caddy.domain;
  
  # Generate virtual hosts from services
  generateVirtualHosts = let
    # Root site
    rootSite = lib.optionalAttrs config.host.caddy.sites.root.enable {
      "${domain}" = {
        extraConfig = mkStaticResponse config.host.caddy.sites.root.content;
      };
    };
    
    # Proxy sites with websocket support
    proxySites = lib.mapAttrs' (name: site: 
      lib.nameValuePair "${site.subdomain}.${domain}" {
        extraConfig = mkProxyConfig name site.target site.logLevel;
      }
    ) (lib.filterAttrs (_: site: site.enable) config.host.caddy.sites.proxies);
  in
    rootSite // proxySites;
    
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
        description = "Proxy sites configuration";
      };
    };
  };

  config = lib.mkIf config.host.caddy.enable {
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
        target = "gigame.brizz.net:8096";
        logLevel = "DEBUG";
      };
    };
    
    services.caddy = {
      enable = true;
      virtualHosts = generateVirtualHosts;
    };

    networking.firewall.allowedTCPPorts = [443];
  };
}
