{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}: let
  admin = config.host.admin.name;
in {
  imports = [
    ../common
    inputs.home-manager.darwinModules.home-manager
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${admin} = import ./admin.nix;

  home-manager.extraSpecialArgs = {
    inherit pkgs pkgs-unstable;
  };
}
