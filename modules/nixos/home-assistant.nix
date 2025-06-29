{
  config,
  lib,
  pkgs,
  ...
}: {
  # Use NixOS's built-in home-assistant module instead of defining our own options
  config = lib.mkIf config.services.home-assistant.enable {
    services.home-assistant = {
      package = pkgs.home-assistant;
      openFirewall = true;

      # Stick to essential components for initial setup
      extraComponents = [
        "default_config"
        "frontend"
      ];

      config = {
        # Keep HTTP configuration simple
        http = {
          server_port = 8123;
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
            "::1"
            "192.168.1.0/24" # Local network range
            "10.0.0.0/8" # Private network ranges
            "172.16.0.0/12" # Private network ranges
          ];
        };

        # Basic UI config
        frontend = {};
        homeassistant = {
          name = "Home";
          time_zone = "America/Los_Angeles";
          unit_system = "metric";
          temperature_unit = "C";
        };
        frontend = {};
        automation = "!include automations.yaml";
        script = "!include scripts.yaml";
        scene = "!include scenes.yaml";
      };
    };
  };
}
