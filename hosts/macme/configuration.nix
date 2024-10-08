{pkgs, ...}: {
  imports = [
    ../../modules/common
    ../../modules/home-manager-darwin
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    _1password
    nushell
  ];

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
