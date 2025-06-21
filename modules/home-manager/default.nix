{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host;
  isDarwin = pkgs.stdenv.isDarwin;

  # Get all users that have Home Manager enabled
  homeManagerUsers = lib.filterAttrs (_: user: user.homeManagerEnabled) cfg.users;

  # Generate user configurations based on profile
  generateUserConfig = userName: userConfig: let
    profileConfig =
      if userConfig.profile == "personal"
      then ./profiles/personal.nix
      else ./profiles/work.nix;
  in {
    imports = [profileConfig];
    home.username = userName;
  };

  # Generate home-manager user configurations
  userConfigurations = lib.mapAttrs generateUserConfig homeManagerUsers;
in {
  imports =
    [
      ../common
    ]
    ++ (
      if isDarwin
      then [
        inputs.home-manager.darwinModules.home-manager
      ]
      else [
        inputs.home-manager.nixosModules.home-manager
      ]
    );

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";

  # Configure all users with Home Manager enabled
  home-manager.users = userConfigurations;

  home-manager.extraSpecialArgs = {
    inherit pkgs;
    opnix = inputs.opnix;
    hostUsers = cfg.users;
  };
}
