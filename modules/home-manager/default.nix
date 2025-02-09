{
  config,
  inputs,
  pkgs,
  ...
}: let
  admin = config.host.admin.name;
  isDarwin = pkgs.stdenv.isDarwin;
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

  home-manager.users.${admin} = import ./admin.nix;

  home-manager.extraSpecialArgs = {
    inherit pkgs;
    opnix = inputs.opnix;
  };
}
