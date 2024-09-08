{pkgs, pkgs-unstable, ...}: {
  imports = [
    ../../modules/common
    ../../modules/home-manager-darwin
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = (with pkgs; [
    _1password
    nushell
  ]) ++ (with pkgs-unstable; [
    neovim
  ]);

  host = {
    isDarwin = true;
    keyboard = "voyager";
  };

  programs.zsh.enable = true;

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  homebrew = {
    enable = true;
    brews = [];
    casks = [
      "1password"
      "alacritty"
      "discord"
      "font-jetbrains-mono-nerd-font"
      "orion"
      "zed"
    ];
  };
}
