{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ../../modules/home-manager
    inputs.opnix.nixosModules.default
  ];

  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    configFile = ./../../secrets.json;
  };

  host = {
    name = "cloudy";
    desktop.enable = false;
    remote.enable = true;
    attic.server.enable = true;
    jellyfin.server.enable = true;
    minio.server.enable = true;
  };

  glance.enable = true;
  soft-serve.enable = true;
  speedtest.enable = true;

  system.stateVersion = "24.05";
}
