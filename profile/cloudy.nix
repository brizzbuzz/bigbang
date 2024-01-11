{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../home/dev.nix
    ../home/dots.nix
    ../home/terminal.nix
  ];

  home = {
    username = "cloudy";
    homeDirectory = "/home/cloudy";
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;
}
