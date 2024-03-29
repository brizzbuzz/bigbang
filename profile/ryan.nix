{...}: {
  imports = [
    ../home/apps.nix
    ../home/art.nix
    ../home/browsers.nix
    ../home/dev.nix
    ../home/dots.nix
    ../home/gaming.nix
    ../home/git.nix
    ../home/keyboard.nix
    ../home/neovim.nix
    ../home/terminal.nix
    ../home/wayland.nix
  ];

  desktopEnabled = true;

  home = {
    username = "ryan";
    homeDirectory = "/home/ryan";
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;
}
