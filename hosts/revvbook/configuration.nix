{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/common
    ../../modules/home-manager-darwin
  ];

  environment.systemPackages = with pkgs; [
    neovim
    nushell
  ];

  host = {
    gitSigningKey = lib.mkForce "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpBT61fePYbBmIS3sA6ZLceD3VTvQs22K45ORRRWD6L";
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
}
