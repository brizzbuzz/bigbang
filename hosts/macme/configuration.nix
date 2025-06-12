{pkgs, ...}: {
  imports = [
    ../../modules/common
    ../../modules/darwin
    ../../modules/home-manager
  ];

  nixpkgs.config.allowUnfree = true;

  # Define the system user for nix-darwin
  system.primaryUser = "ryan";

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
    user = "ryan";

    brews = [
      "mas"
    ];

    casks = [
      "1password"
      "betterdiscord-installer"
      "bruno"
      "discord"
      "docker"
      "gitbutler"
      "google-chrome"
      "iina"
      "ghostty"
      "hammerspoon"
      "jetbrains-toolbox"
      "keymapp"
      "logi-options+"
      "notion"
      "orion"
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
      "zoom"
    ];

    masApps = {
      "Unifi" = 1057750338;
      "Ubiquiti Wifiman" = 1385561119;
      "WireGuard" = 1451685025;
      "Xcode" = 497799835;
    };

    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  host = {
    keyboard = "voyager";
  };

  programs.zsh.enable = true;
  nix.package = pkgs.nix;

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  system.stateVersion = 5;
}
