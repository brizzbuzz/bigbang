{
  config,
  lib,
  pkgs,
  ...
}: {
  # Use NixOS's built-in home-assistant module instead of defining our own options
  config = lib.mkIf config.services.home-assistant.enable {
    # Create missing YAML files that Home Assistant expects
    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
      "f ${config.services.home-assistant.configDir}/scripts.yaml 0755 hass hass"
      "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
    ];

    services.home-assistant = {
      package = pkgs.home-assistant;
      openFirewall = true;

      # Essential components for initial setup and reverse proxy compatibility
      extraComponents = [
        "default_config"
        "frontend"
        "met"
        "radio_browser"
      ];

      config = {
        # HTTP configuration - simple setup for callisto proxy
        http = {
          server_port = 8123;
          # Enable X-Forwarded-For to handle reverse proxy requests from callisto
          use_x_forwarded_for = true;
          trusted_proxies = [
            "192.168.11.200" # callisto reverse proxy
            "127.0.0.1"
            "::1"
          ];
          # Allow connections from any IP since DNS-level protection is in place
          ip_ban_enabled = false;
          login_attempts_threshold = -1; # Disable login attempt limiting
        };

        # Basic system configuration
        homeassistant = {
          name = "Home";
          time_zone = "America/Los_Angeles";
          unit_system = "metric";
          temperature_unit = "C";
        };

        # UI components
        frontend = {};

        # Hybrid approach: support both declarative and UI-defined configurations
        "automation manual" = [
          # Declarative automations can be added here
        ];
        "automation ui" = "!include automations.yaml";

        "script manual" = {
          # Declarative scripts can be added here
        };
        "script ui" = "!include scripts.yaml";

        "scene manual" = [
          # Declarative scenes can be added here
        ];
        "scene ui" = "!include scenes.yaml";
      };
    };
  };
}
