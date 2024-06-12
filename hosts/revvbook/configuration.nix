{pkgs, ...}: {
  imports = [
    ../../modules/common
    #../../modules/home-manager-darwin
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    direnv
    gitui
    neovim
    zellij
  ];

  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
