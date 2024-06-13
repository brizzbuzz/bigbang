{pkgs, ...}: {
  imports = [
    ../../modules/common
    ../../modules/home-manager-darwin
  ];

  environment.systemPackages = with pkgs; [
    neovim
  ];

  programs.zsh.enable = true;

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
