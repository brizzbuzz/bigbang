{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.opnix.nixosModules.default
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/nixos
    ../../modules/home-manager
  ];

  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    users = ["ryan"]; # TODO: Read from config

    # Fully declarative secrets configuration
    secrets = {
      # SSL certificates for Caddy
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

      # Atticd server environment
      atticdServerEnv = {
        reference = "op://Homelab/Atticd/notesPlain";
        path = "/var/lib/opnix/secrets/atticd/server/env";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      # Minio credentials
      minioRootCredentials = {
        reference = "op://Homelab/Minio Root Credentials/notesPlain";
        path = "/var/lib/opnix/secrets/minio/root-credentials";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      minioLgtmCredentials = {
        reference = "op://Homelab/Minio LGTM Credentials/notesPlain";
        path = "/var/lib/opnix/secrets/minio/lgtm-credentials";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      # Grafana OAuth client ID for Authentik
      grafanaOAuthClientId = {
        reference = "op://Homelab/Grafana OAuth/client_id";
        path = "/var/lib/grafana/secrets/oauth-client-id";
        owner = "grafana";
        group = "grafana";
        mode = "0600";
        services = ["grafana"];
      };

      # Grafana OAuth client secret for Authentik
      grafanaOAuthClientSecret = {
        reference = "op://Homelab/Grafana OAuth/client_secret";
        path = "/var/lib/grafana/secrets/oauth-client-secret";
        owner = "grafana";
        group = "grafana";
        mode = "0600";
        services = ["grafana"];
      };
    };

    # Enable systemd integration for reliable service management
    systemdIntegration = {
      enable = true;
      services = ["caddy" "grafana"];
      restartOnChange = true;
    };
  };

  # Create SSL directories for OpNix-managed certificates
  systemd.tmpfiles.rules = [
    "d /var/lib/caddy/ssl 0750 caddy caddy -"
  ];

  # Minio service
  services.minio-server = {
    enable = true;
    port = 9002;
    consolePort = 9003;
  };

  services.grafana-server = {
    enable = true;
    domain = "metrics.rgbr.ink";
    mimir.url = "http://localhost:9009/prometheus";
    oauth = {
      enable = true;
      authentik = {
        allowedDomains = [];
      };
    };
  };

  lgtm.mimir = {
    enable = true;
    port = 9009;
    retentionTime = "1080h";
    storage.minio = {
      endpoint = "localhost:${toString config.services.minio-server.port}";
      bucketName = "mimir";
      region = "us-east-1";
      credentialsFile = config.services.onepassword-secrets.secretPaths.minioLgtmCredentials;
    };
  };

  lgtm.node_exporter = {
    enable = true;
  };

  lgtm.loki = {
    enable = true;
    port = 3100;
    retentionTime = "1080h"; # Same as Mimir for consistency
    storage.minio = {
      endpoint = "localhost:${toString config.services.minio-server.port}";
      bucketName = "loki";
      region = "us-east-1";
      credentialsFile = config.services.onepassword-secrets.secretPaths.minioLgtmCredentials;
    };
  };

  lgtm.tempo = {
    enable = true;
    port = 3200;
    grpcPort = 9097;
    retentionTime = "1080h"; # Same as Mimir and Loki for consistency
    storage.minio = {
      endpoint = "localhost:${toString config.services.minio-server.port}";
      bucketName = "tempo";
      region = "us-east-1";
      credentialsFile = config.services.onepassword-secrets.secretPaths.minioLgtmCredentials;
    };
  };

  lgtm.alloy = {
    enable = true;
    port = 12345;
    configFile = ./config.alloy;
    extraFlags = [
      "--disable-reporting"
    ];
  };

  system-limits = {
    enable = false;
  };

  host = {
    name = "callisto";
    desktop.enable = false;
    remote.enable = true;
    attic.server.enable = true;
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
          enable = false; # Disabled - using Glance as root instead
          content = "Hello from callisto!";
        };
        proxies = {
          glance = {
            enable = true;
            subdomain = ""; # Empty subdomain means root domain
            target = "localhost:8081";
            logLevel = "INFO";
          };
          media = {
            enable = true;
            subdomain = "media";
            target = "ganymede.chateaubr.ink:8096";
            logLevel = "DEBUG";
          };
          homeassistant = {
            enable = true;
            subdomain = "home";
            target = "ganymede.chateaubr.ink:8123";
            logLevel = "DEBUG";
          };
          minio = {
            enable = true;
            subdomain = "storage";
            target = "localhost:${toString config.services.minio-server.consolePort}";
            logLevel = "INFO";
          };
          mimir = {
            enable = true;
            subdomain = "mimir";
            target = "localhost:9009";
            logLevel = "INFO";
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
          auth = {
            enable = true;
            subdomain = "auth";
            target = "ganymede.chateaubr.ink:9000";
            logLevel = "INFO";
          };
        };
      };
    };
  };

  glance = {
    enable = true;
    settings = {
      server = {
        host = "127.0.0.1";
        port = 8081;
      };
      pages = [
        {
          name = "Homelab Dashboard";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "monitor";
                  cache = "30s";
                  title = "🏠 Core Services";
                  sites = [
                    {
                      title = "Jellyfin Media";
                      url = "https://media.rgbr.ink";
                      icon = "si:jellyfin";
                    }
                    {
                      title = "Home Assistant";
                      url = "https://home.rgbr.ink";
                      icon = "si:homeassistant";
                    }
                    {
                      title = "Photo Library";
                      url = "https://photos.rgbr.ink";
                      icon = "si:immich";
                    }
                    {
                      title = "Authentication";
                      url = "https://auth.rgbr.ink";
                      icon = "si:authentik";
                    }
                  ];
                }
                {
                  type = "monitor";
                  cache = "1m";
                  title = "🔧 Infrastructure";
                  sites = [
                    {
                      title = "Grafana Metrics";
                      url = "https://metrics.rgbr.ink";
                      icon = "si:grafana";
                    }
                    {
                      title = "MinIO Storage";
                      url = "https://storage.rgbr.ink";
                      icon = "si:minio";
                    }
                    {
                      title = "DNS Filtering";
                      url = "https://dns.rgbr.ink";
                      icon = "si:pihole";
                    }
                    # {
                    #   title = "Torrent Client";
                    #   url = "https://torrents.rgbr.ink";
                    #   icon = "si:qbittorrent";
                    # }
                  ];
                }
                {
                  type = "calendar";
                  title = "📅 Calendar";
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "bookmarks";
                  title = "🚀 Quick Access";
                  groups = [
                    {
                      title = "🎬 Media Services";
                      color = "280 100 50";
                      links = [
                        {
                          title = "Jellyfin - Movies & TV";
                          url = "https://media.rgbr.ink";
                          icon = "si:jellyfin";
                        }
                        {
                          title = "Immich - Photo Library";
                          url = "https://photos.rgbr.ink";
                          icon = "si:immich";
                        }
                        {
                          title = "AudioBookshelf - Books & Podcasts";
                          url = "https://books.rgbr.ink";
                          icon = "si:audiobookshelf";
                        }
                      ];
                    }
                    {
                      title = "📊 Monitoring & Storage";
                      color = "220 100 40";
                      links = [
                        {
                          title = "Grafana - System Metrics";
                          url = "https://metrics.rgbr.ink";
                          icon = "si:grafana";
                        }
                        {
                          title = "MinIO - Object Storage";
                          url = "https://storage.rgbr.ink";
                          icon = "si:minio";
                        }
                        {
                          title = "Mimir - Metrics Database";
                          url = "https://mimir.rgbr.ink";
                          icon = "si:prometheus";
                        }
                        {
                          title = "Blocky - DNS & Ad Blocking";
                          url = "https://dns.rgbr.ink";
                          icon = "si:pihole";
                        }
                      ];
                    }
                    {
                      title = "🏠 Smart Home";
                      color = "120 100 45";
                      links = [
                        {
                          title = "Home Assistant - Automation Hub";
                          url = "https://home.rgbr.ink";
                          icon = "si:homeassistant";
                        }
                        {
                          title = "Authentik - Identity Management";
                          url = "https://auth.rgbr.ink";
                          icon = "si:authentik";
                        }
                      ];
                    }
                    {
                      title = "⬇️ Downloads & Network";
                      color = "10 100 50";
                      links = [
                        # {
                        #   title = "qBittorrent - Torrent Client";
                        #   url = "https://torrents.rgbr.ink";
                        #   icon = "si:qbittorrent";
                        # }
                      ];
                    }
                  ];
                }
                {
                  type = "hacker-news";
                  title = "📰 Hacker News";
                  limit = 10;
                  collapse-after = 5;
                }
                {
                  type = "reddit";
                  title = "🛠️ r/selfhosted";
                  subreddit = "selfhosted";
                  limit = 8;
                  collapse-after = 4;
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  title = "🌤️ London Weather";
                  location = "London, United Kingdom";
                  units = "metric";
                }
                {
                  type = "clock";
                  title = "🕐 System Time";
                  hour-format = "24h";
                  timezones = [
                    {
                      timezone = "Europe/London";
                      label = "London";
                    }
                  ];
                }
                {
                  type = "rss";
                  title = "📡 Tech Feeds";
                  limit = 5;
                  collapse-after = 3;
                  cache = "6h";
                  feeds = [
                    {
                      url = "https://www.jeffgeerling.com/blog.xml";
                      title = "Jeff Geerling";
                    }
                    {
                      url = "https://ciechanow.ski/atom.xml";
                      title = "Bartosz Ciechanowski";
                    }
                    {
                      url = "https://samwho.dev/rss.xml";
                      title = "Sam Rose";
                    }
                  ];
                }
                {
                  type = "stocks";
                  title = "📈 Markets";
                  stocks = [
                    {
                      symbol = "SPY";
                      name = "S&P 500";
                    }
                    {
                      symbol = "QQQ";
                      name = "NASDAQ";
                    }
                    {
                      symbol = "BTC-USD";
                      name = "Bitcoin";
                    }
                    {
                      symbol = "NVDA";
                      name = "NVIDIA";
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "System Overview";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "bookmarks";
                  title = "🖥️ Infrastructure Map";
                  groups = [
                    {
                      title = "☁️ Callisto - Infrastructure Hub";
                      color = "200 80 60";
                      links = [
                        {
                          title = "Caddy Reverse Proxy";
                          url = "https://rgbr.ink";
                          icon = "si:caddy";
                        }
                        {
                          title = "Grafana Monitoring";
                          url = "https://metrics.rgbr.ink";
                          icon = "si:grafana";
                        }
                        {
                          title = "MinIO Object Storage";
                          url = "https://storage.rgbr.ink";
                          icon = "si:minio";
                        }
                        {
                          title = "Blocky DNS Filter";
                          url = "https://dns.rgbr.ink";
                          icon = "si:pihole";
                        }
                      ];
                    }
                    {
                      title = "🌙 Ganymede - Media & Services";
                      color = "280 80 60";
                      links = [
                        {
                          title = "Jellyfin Media Server";
                          url = "https://media.rgbr.ink";
                          icon = "si:jellyfin";
                        }
                        {
                          title = "Immich Photo Management";
                          url = "https://photos.rgbr.ink";
                          icon = "si:immich";
                        }
                        {
                          title = "Home Assistant";
                          url = "https://home.rgbr.ink";
                          icon = "si:homeassistant";
                        }
                        {
                          title = "AudioBookshelf";
                          url = "https://books.rgbr.ink";
                          icon = "si:audiobookshelf";
                        }
                        {
                          title = "Authentik SSO";
                          url = "https://auth.rgbr.ink";
                          icon = "si:authentik";
                        }
                        # {
                        #   title = "qBittorrent";
                        #   url = "https://torrents.rgbr.ink";
                        #   icon = "si:qbittorrent";
                        # }
                      ];
                    }
                    {
                      title = "🔧 Development & Tools";
                      color = "120 80 50";
                      links = [
                        {
                          title = "NixOS Configurations";
                          url = "https://github.com/your-username/bigbang";
                          icon = "si:nixos";
                        }
                        {
                          title = "Atticd Binary Cache";
                          url = "https://attic.rgbr.ink";
                          icon = "si:nix";
                        }
                        {
                          title = "Soft Serve Git Server";
                          url = "ssh://git.rgbr.ink";
                          icon = "si:git";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };
  soft-serve.enable = true;
  speedtest.enable = true;
  # services.home-assistant.enable = true; # Moved to ganymede

  system.stateVersion = "24.05";
}
