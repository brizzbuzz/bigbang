{
  config,
  lib,
  ...
}: {
  nixpkgs.overlays = import ../overlays;

  imports = [
    ../common

    ./audio.nix
    ./audiobookshelf.nix
    ./arr.nix
    ./blocky.nix
    ./boot.nix
    ./caddy.nix
    ./clickhouse.nix
    ./core.nix
    ./docker.nix
    ./environment.nix
    ./fingerprint-reader.nix
    ./fonts.nix
    ./gaming.nix
    ./maintenance.nix

    ./hardware.nix

    ./immich.nix
    ./jellyfin.nix

    ./locale.nix
    ./networking.nix
    ./nvidia.nix
    ./opencode.nix
    ./password-manager.nix
    ./postgres.nix
    ./printer.nix
    ./pueue.nix
    ./security.nix
    ./session.nix

    ./ssh.nix
    ./system-limits.nix
    ./torrents.nix
    ./users.nix
    ./userland.nix
    ./ventoy-web.nix
    ./vpn.nix
  ];

  password-manager = {
    enable = lib.mkDefault true;
    gui = {
      enable = lib.mkDefault config.host.roles.desktop;
      polkitPolicyOwners = lib.mkDefault [config.host.admin.name];
    };
  };
}
