{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  nixos-modules,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    # TODO: Can I simply import all of the modules somehow?
    nixos-modules.boot
    nixos-modules.environment
    nixos-modules.flake-support
    nixos-modules.fonts
    nixos-modules.garbage-collection
    nixos-modules.locale
    nixos-modules.networking
    nixos-modules.security
    nixos-modules.users
  ];

  # TODO: Should I disable this on all hosts?
  systemd.services.NetworkManager-wait-online.enable = false;

  # TODO: Move to better place
  users.users.god = {
    isNormalUser = true;
    description = "Literally God (of this domain, no disrepect to the true Big G)";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.nushell;
    packages = with pkgs; [];
  };

  nix.settings.trusted-users = ["god"];

  system.stateVersion = "23.11";
}
