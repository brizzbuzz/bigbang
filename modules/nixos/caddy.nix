{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.host.caddy.enable {
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

            reverse_proxy gigame.brizz.net:8096 {
              header_up X-Real-IP {remote_host}
              header_up X-Forwarded-For {remote_host}
              header_up X-Forwarded-Proto {scheme}
              header_up X-Forwarded-Host {host}
              header_up Host {host}
            }

            @websockets {
              header Connection *Upgrade*
              header Upgrade websocket
            }
            reverse_proxy @websockets gigame:8096
          '';
        };
      };
    };

    networking.firewall.allowedTCPPorts = [443];
  };
}
