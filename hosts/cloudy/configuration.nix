{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.services.NetworkManager-wait-online.enable = false;
  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  security.sudo.wheelNeedsPassword = false;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.god = {
    isNormalUser = true;
    description = "Literally God (of this domain, no disrepect to the true Big G)";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.nushell;
    packages = with pkgs; [];
  };

  nix.settings.trusted-users = ["god"];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    jq
    neovim
    nushell
    wget
  ];

  environment.variables = {
    EDITOR = "nvim";
  };

  # Garbage Collection
  nix = {
    # optimise.automatic = true;  TODO: See https://github.com/NixOS/nix/issues/6033
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "23.11";
}
