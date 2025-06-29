{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.opnix.darwinModules.default
    ../../modules/common
    ../../modules/darwin
    ../../modules/home-manager
  ];

  nixpkgs.config.allowUnfree = true;

  # OpNix system-level secrets configuration
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";

    secrets = {
      wireguardConfig = {
        reference = "op://Homelab/Wireguard Config/notesPlain";
        path = "/etc/wireguard/brizzguard.conf";
        owner = "root";
        group = "wheel";
        mode = "0600";
      };
    };

    # Note: Darwin uses launchd instead of systemd, so no systemdIntegration option
  };

  # Create necessary directories for Wireguard
  system.activationScripts.createWireguardDir.text = ''
    mkdir -p /etc/wireguard
    chmod 700 /etc/wireguard
  '';

  host = {
    users = {
      ryan = {
        name = "ryan";
        profile = "personal";
        isPrimary = true;
        homeManagerEnabled = true;
      };
      Work = {
        name = "Work";
        profile = "work";
        isPrimary = false;
        homeManagerEnabled = true;
      };
    };

    profiles = {
      personal = {
        appleIdApps = true;
        entertainmentApps = true;
        developmentApps = true;
        personalApps = true;
      };
      work = {
        businessApps = true;
        restrictedApps = false;
        developmentApps = false;
      };
    };

    keyboard = "voyager";
  };

  # Define the system user for nix-darwin
  system.primaryUser = "ryan";

  programs.zsh.enableCompletion = false;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    _1password-cli
    nushell
  ];

  homebrew = {
    enable = true;
    user = "ryan";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  programs.zsh.enable = true;
  nix.package = pkgs.nix;

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  system.stateVersion = 5;
}
