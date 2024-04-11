{
  config,
  lib,
  ...
}: {
  imports = [
    ./boot.nix
    ./environment.nix
    ./flake-support.nix
    ./fonts.nix
    ./garbage-collection.nix
    ./hardware.nix
    ./host-info.nix
    ./hyprland.nix
    ./locale.nix
    ./networking.nix
    ./nvidia.nix
    ./password-manager.nix
    ./polkit.nix
    ./pueue.nix
    ./security.nix
    ./tailscale.nix
    ./users.nix
    ./xdg.nix
    ./xserver.nix
  ];

  host = {
    admin.name = lib.mkDefault "ryan";

    desktop = {
      enable = lib.mkDefault true;
    };

    gpu.nvidia = {
      enable = lib.mkDefault false;
    };

    remote = {
      enable = lib.mkDefault false;
    };
  };

  password-manager = {
    enable = lib.mkDefault true;
    gui = {
      enable = lib.mkDefault config.host.desktop.enable;
      polkitPolicyOwners = lib.mkDefault [config.host.admin.name];
    };
  };
}
