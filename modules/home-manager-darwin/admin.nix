{config, ...}: let
  admin = config.host.admin.name;
in {
  imports = [../common];

  home = {
    username = admin;
    homeDirectory = "/Users/${admin}";
    stateVersion = "24.05";
  };
}
