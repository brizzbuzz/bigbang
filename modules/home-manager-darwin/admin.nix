{
  config,
  lib,
  ...
}: let
  admin = config.host.admin.name;
in {
  # TODO: find a way to merge this with the default home-manager config
  imports = [
    ../common
    ../home-manager/dev.nix
    ../home-manager/neovim.nix
    ../home-manager/terminal.nix
    ../home-manager/dots.nix
    ../home-manager/darwin-dots.nix
    ../home-manager/git.nix
  ];

  home = {
    username = admin;
    homeDirectory = lib.mkForce "/Users/${admin}";
    stateVersion = "24.05";
  };
}
