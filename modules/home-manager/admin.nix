{
  config,
  nixvim,
  opnix,
  ...
}: let
  admin = config.host.admin.name;
in {
  imports = [
    nixvim.homeManagerModules.nixvim
    opnix.homeManagerModules.default
    ../common # NOTE: This is required because home-manager gets evaluated as a separate attribute set... I think...
    ./neovim
    ./atuin.nix
    ./alacritty.nix
    ./apps.nix
    ./bat.nix
    ./bottom.nix
    ./direnv.nix
    ./dots.nix
    ./git.nix
    ./gitui.nix
    ./networking.nix
    ./nushell.nix
    ./rclone.nix
    ./ssh.nix
    ./starship.nix
    ./terminal.nix
    ./wayland.nix
    ./zellij.nix
    ./zoxide.nix
  ];

  home = {
    username = admin;
    homeDirectory = "/home/${admin}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

  programs.onepassword-secrets = {
    enable = true;
    secrets = [
      {
        path = ".config/Yubico/u2f_keys";
        reference = "op://Homelab/U2F Keys/notesPlain";
      }
    ];
  };
}
