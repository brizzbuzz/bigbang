{pkgs, ...}: {
  imports = [
    ../../modules/common
    ../../modules/home-manager-darwin
  ];

  nixpkgs.config.allowUnfree = true;

   fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  environment.systemPackages = with pkgs; [
    _1password
    nushell
  ];

  homebrew = {
    enable = true;

    taps = [ ];
    brews = [ ];
    casks = ["1password" "alacritty" "floorp"];
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
