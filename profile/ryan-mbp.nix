{
  config,
  pkgs,
  home-manager,
  ...
}: {
  imports = [
    #../home/apps.nix
    #../home/dev.nix
    ../home/dots.nix
    ../home/terminal.nix
  ];

  config = {
    os = "macos";
    desktopEnabled = true;

    home = {
      stateVersion = "24.05";
      packages = with pkgs; [
        # TODO: Delegate to modules
        _1password
        alacritty
        bottom
        gitui
        helix
        mas
        mise
        ripgrep
        zellij
      ];
    };
  };
}

