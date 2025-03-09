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
      extraComponents = [
        "default_config"
        "esphome"
        "met"
        "homekit"
      ];
      config = {
        http = {
          server_port = 8123;
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" "::1" ];
        };
        homeassistant = {
          name = "Home";
          time_zone = "America/Los_Angeles";
          unit_system = "metric";
          temperature_unit = "C";
        };
        frontend = { };
        automation = "!include automations.yaml";
        script = "!include scripts.yaml";
        scene = "!include scenes.yaml";
      };
    };
  };
}