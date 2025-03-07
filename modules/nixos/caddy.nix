{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.host.caddy.enable {
    # Create log directory for Caddy
    system.activationScripts.caddyLogDir = ''
      mkdir -p /var/log/caddy
      chown caddy:caddy /var/log/caddy
    '';
    
    services.caddy = {
      enable = true;

      virtualHosts = {
        "${config.host.caddy.domain}" = {
          extraConfig = ''
            tls /etc/ssl/certs/cloudflare-cert.pem /etc/ssl/private/cloudflare-key.pem
            respond "Hello, world!"
          '';
        };

        "media.${config.host.caddy.domain}" = {
          extraConfig = ''
            tls /etc/ssl/certs/cloudflare-cert.pem /etc/ssl/private/cloudflare-key.pem

            log {
              output file /var/log/caddy/media.log
              format console
              level DEBUG
            }

            # Handle WebSockets
            @websockets {
              header Connection *Upgrade*
              header Upgrade websocket
            }
            
            # Special handling for WebSockets
            handle @websockets {
              reverse_proxy gigame.brizz.net:8096 {
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

            # Handle normal requests
            handle {
              reverse_proxy gigame.brizz.net:8096 {
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
        };
      };
    };

    networking.firewall.allowedTCPPorts = [443];
  };
}
