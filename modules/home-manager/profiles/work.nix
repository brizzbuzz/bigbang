{
  config,
  opnix,
  pkgs,
  lib,
  ...
}: let
  currentUsername = config.home.username;
  isDarwin = pkgs.stdenv.isDarwin;
  zedConfig = import ../zed-config.nix {inherit lib pkgs;};
in {
  imports = [
    opnix.homeManagerModules.default
    ../../common
    ../atuin.nix
    ../alacritty.nix
    ../bat.nix
    ../bottom.nix
    ../direnv.nix
    ../dots.nix
    ../git.nix
    ../gitui.nix
    ../nushell.nix
    ../ssh.nix
    ../starship.nix
    ../terminal.nix
    ../zoxide.nix
  ];

  home = {
    homeDirectory = lib.mkForce (
      if isDarwin
      then "/Users/${currentUsername}"
      else "/home/${currentUsername}"
    );
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

  programs.git = {
    settings = {
      user = {
        name = "Ryan Brink";
        email = "ryan@withodyssey.com";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvZU9QjyJpanD7LGnSn4e5gcOdLqL8nkUYfowWyrFvl"; # Work signing key - update with actual key
      };
    };
  };

  home.packages = with pkgs; [
    nodejs
    python3
    wget
    curl
    jq
  ];

  xdg.configFile."1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    item = "Odyssey Auth Key"
    vault = "Employee"
    account = "teamodyssey.1password.com"

    [[ssh-keys]]
    item = "Odyssey Signing Key"
    vault = "Employee"
    account = "teamodyssey.1password.com"
  '';

  xdg.configFile."zed/settings.json".source = zedConfig.zed.work;
}
