{ config, lib, ... }: {
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
      };
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
