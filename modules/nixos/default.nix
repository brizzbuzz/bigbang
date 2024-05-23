{
  config,
  lib,
  ...
}: {
  imports = [
    ../common
    ./audio.nix
    ./boot.nix
    ./docker.nix
    ./environment.nix
    ./fingerprint-reader.nix
    ./flake-support.nix
    ./fonts.nix
    ./garbage-collection.nix
    ./glance.nix
    ./hardware.nix
    ./hyprland.nix
    ./keyboard.nix
    ./locale.nix
    ./networking.nix
    ./nvidia.nix
    ./password-manager.nix
    ./polkit.nix
    ./printer.nix
    ./pueue.nix
    ./security.nix
    ./soft-serve.nix
    ./tailscale.nix
    ./users.nix
    ./xdg.nix
    ./xserver.nix
  ];

  soft-serve.enable = lib.mkDefault false;

  password-manager = {
    enable = lib.mkDefault true;
    gui = {
      enable = lib.mkDefault config.host.desktop.enable;
      polkitPolicyOwners = lib.mkDefault [config.host.admin.name];
    };
  };
}
