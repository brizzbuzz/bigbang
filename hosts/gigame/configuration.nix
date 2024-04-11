{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.home-manager
  ];

  host.name = "gigame";
  host.gpu.nvidia.enable = true;

  # TODO: Move to common
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ryan = import ../../profile/ryan.nix;
  home-manager.extraSpecialArgs = {
    inherit pkgs pkgs-unstable;
  };

  # System State
  system.stateVersion = "23.11";
}
