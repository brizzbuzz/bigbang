{
  config,
  inputs,
  lib,
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

  # OpNix disabled - ganymede doesn't need any secrets
  services.onepassword-secrets = {
    enable = false;
  };

  host = {
    ai.enable = true;
    name = "ganymede";
    desktop.enable = false;
    gpu.nvidia.enable = true;
    jellyfin.server.enable = true;
    keyboard = "moonlander";
    remote.enable = true;
  };

  # Enable Home Assistant (moved from callisto for better proxy setup)
  services.home-assistant.enable = true;

  lgtm.alloy = {
    enable = true;
    port = 12345;
    configFile = ./config.alloy;
    extraFlags = [
      "--disable-reporting"
    ];
  };

  lgtm.node_exporter = {
    enable = true;
    enableGpuMetrics = true; # Enable GPU metrics collection
  };

  # TODO: Make configurable module
  networking = {
    useDHCP = false;
    interfaces.enp4s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.1.51";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.1.1";
  };

  # Disable OpNix for Home Manager since system-level OpNix is disabled
  home-manager.users.${config.host.admin.name} = {
    programs.onepassword-secrets.enable = lib.mkForce false;
  };

  system.stateVersion = "24.05";
}
