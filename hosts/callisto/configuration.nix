{inputs, ...}: {
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
    remote.enable = true;
    userManagement.enable = true;

    blocky = {
      enable = true;
      customDNS.enable = false; # UniFi handles local domain resolution
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

    caddy = {
      enable = true;
      domain = "rgbr.ink";
      sites = {
        root = {
          enable = true;
          content = "Hello from callisto!";
        };
        proxies = {
          media = {
            enable = true;
            subdomain = "media";
            target = "ganymede.chateaubr.ink:8096";
            logLevel = "DEBUG";
          };

          # torrents = {
          #   enable = true;
          #   subdomain = "torrents";
          #   target = "ganymede.chateaubr.ink:8080";
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
            target = "ganymede.chateaubr.ink:2283";
            logLevel = "INFO";
          };
          books = {
            enable = true;
            subdomain = "books";
            target = "ganymede.chateaubr.ink:13378";
            logLevel = "INFO";
          };
        };
        # Portfolio now served via standalone ryanbr.ink domain
        standalone = {
          portfolio = {
            enable = true;
            domain = "ryanbr.ink";
            target = "ganymede.chateaubr.ink:7878";
            tlsCertSecret = "sslRyanbrCert";
            tlsKeySecret = "sslRyanbrKey";
            logLevel = "INFO";
          };
        };
      };
    };

    ventoy-web = {
      enable = true;
      port = 24680;
      bindAddress = "0.0.0.0";
    };
  };

  system.stateVersion = "24.05";
}
