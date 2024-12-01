{pkgs, ...}: {
  imports = [
    ../../modules/common
    ../../modules/darwin
    ../../modules/home-manager-darwin
  ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enableCompletion = false;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    _1password-cli
    nushell
  ];

  homebrew = {
    enable = true;

    brews = [
      "mas"
    ];

    casks = [
      "1password"
      "alacritty"
      "bartender"
      "betterdiscord-installer"
      "bruno"
      "discord"
      "floorp"
      "iina"
      "hammerspoon"
      "jetbrains-toolbox"
      "pocket-casts"
      "protonvpn"
      "proxyman"
      "sf-symbols"
      "spacedrive"
      "spotify"
      "the-unarchiver"
      "zoom"
    ];

    masApps = {
      "Tailscale" = 1475387142;
      "Xcode" = 497799835;
      #"Yoink" = 457622435;
    };

    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  host = {
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
  system.stateVersion = 5;
}
