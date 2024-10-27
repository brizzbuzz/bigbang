{pkgs, ...}: {
  imports = [
    ../../modules/common
    ../../modules/darwin
    ../../modules/home-manager-darwin
  ];

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];

  environment.systemPackages = with pkgs; [
    _1password
    nushell
  ];

  homebrew = {
    enable = true;

    brews = ["mas"];
    casks = [
      "1password"
      "alacritty"
      "betterdiscord-installer"
      "discord"
      "floorp"
      "iina"
      "hammerspoon"
      "proxyman"
      "sf-symbols"
      "the-unarchiver"
    ];
    masApps = {
      "Xcode" = 497799835;
      #"Yoink" = 457622435;
    };
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

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
  system.stateVersion = 5;
}
