{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host;
  isLinux = pkgs.stdenv.isLinux;

  # Generate Linux user account configuration
  mkLinuxUser = userName: userConfig: {
    isNormalUser = true;
    home = "/home/${userName}";
    shell = lib.mkDefault pkgs.zsh;
    extraGroups =
      ["wheel" "networkmanager"]
      ++ lib.optionals (userConfig.profile == "personal") ["docker" "audio" "video"];
    openssh.authorizedKeys.keys = [
      # Personal SSH key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+4LZpJ9+QmvjLKMzmHX1aUdsnoOlrrcTjwKhcwnCN1"
    ];
  };

  # Generate user configurations for Linux
  linuxUsers = lib.mapAttrs mkLinuxUser cfg.users;
in {
  options.host.userAccounts = {
    enable = lib.mkEnableOption "Enable user account management";
  };

  config = lib.mkIf cfg.userAccounts.enable (let
  in {
    # Linux user management
    users.users = lib.mkIf isLinux linuxUsers;

    # Darwin primary user is handled by Darwin-specific configurations
    # Not set here to avoid conflicts with NixOS

    # Global shell configuration
    programs.zsh = {
      enable = true;
      enableCompletion = lib.mkDefault true;
    };
  });
}
