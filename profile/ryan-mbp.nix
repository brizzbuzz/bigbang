{
  config,
  pkgs,
  home-manager,
  ...
}: {
  imports = [
    #../home/apps.nix
    ../home/dev.nix
    ../home/dots.nix
    ../home/neovim.nix
    ../home/terminal.nix
  ];

  config = {
    os = "macos";
    desktopEnabled = true;

    home = {
      stateVersion = "23.11";
      packages = with pkgs; [
        # TODO: Delegate to modules
        _1password
        mas
        slack
      ];
    };
  };
}
