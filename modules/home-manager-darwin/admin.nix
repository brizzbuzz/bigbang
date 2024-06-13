{config, lib, ...}: let
  admin = config.host.admin.name;
in {
  imports = [../common];

  home = {
    username = admin;
    homeDirectory = lib.mkForce "/Users/${admin}";
    stateVersion = "24.05";
  };
}
