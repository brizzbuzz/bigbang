{inputs, ...}: {
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
    configFile = ./../../secrets.json;
    users = [ "ryan" ]; # TODO: Read from config
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
