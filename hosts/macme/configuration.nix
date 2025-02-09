{pkgs, ...}: {
  imports = [
    ../../modules/common
    ../../modules/darwin
    ../../modules/home-manager
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
      "gitbutler"
      "iina"
      "ghostty"
      "hammerspoon"
      "jetbrains-toolbox"
      "parsec"
      "pocket-casts"
      "protonvpn"
      "proxyman"
      "sf-symbols"
      "spacedrive"
      "spotify"
      "steam"
      "the-unarchiver"
      "zed"
      "zen-browser"
      "zoom"
      "zen-browser"
      "zed"
    ];

    masApps = {
      "Unifi" = 1057750338;
      "Ubiquiti Wifiman" = 1385561119;
      "Xcode" = 497799835;
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
