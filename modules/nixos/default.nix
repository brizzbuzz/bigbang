{
  config,
  lib,
  ...
}: {
  imports = [
    ../common

    ./storage
    ./audio.nix
    ./audiobookshelf.nix
    ./blocky.nix
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

    ./hardware.nix

    ./hyprland.nix
    ./immich.nix
    ./jellyfin.nix

    ./locale.nix
    ./networking.nix
    ./nvidia.nix
    ./password-manager.nix
    ./polkit.nix
    ./postgres.nix
    ./printer.nix
    ./pueue.nix
    ./security.nix

    ./ssh.nix
    ./system-limits.nix
    ./users.nix
    ./xdg.nix
  ];

  password-manager = {
    enable = lib.mkDefault true;
    gui = {
      enable = lib.mkDefault config.host.desktop.enable;
      polkitPolicyOwners = lib.mkDefault [config.host.admin.name];
    };
  };
}
