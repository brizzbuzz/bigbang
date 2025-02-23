{
  config,
  lib,
  ...
}: {
  imports = [
    ../common
    ./attic.nix
    ./audio.nix
    ./boot.nix
    ./caddy.nix
    ./display-manager.nix
    ./docker.nix
    ./environment.nix
    ./fingerprint-reader.nix
    ./flake-support.nix
    ./fonts.nix
    ./gaming.nix
    ./garbage-collection.nix
    ./glance.nix
    ./hardware.nix
    ./hyprland.nix
    ./jellyfin.nix
    ./locale.nix
    ./networking.nix
    ./nvidia.nix
    ./minio.nix
    ./ollama.nix
    ./open-webui.nix
    ./password-manager.nix
    ./polkit.nix
    ./postgres.nix
    ./printer.nix
    ./pueue.nix
    ./security.nix
    ./soft-serve.nix
    ./speedtest.nix
    ./ssh.nix
    ./users.nix
    ./xdg.nix
  ];

  glance.enable = lib.mkDefault false;
  soft-serve.enable = lib.mkDefault false;

  password-manager = {
    enable = lib.mkDefault true;
    gui = {
      enable = lib.mkDefault config.host.desktop.enable;
      polkitPolicyOwners = lib.mkDefault [config.host.admin.name];
    };
  };
}
