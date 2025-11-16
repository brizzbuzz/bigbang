{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.opnix.darwinModules.default
    ../../modules/common
    ../../modules/darwin
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
  };

  # Create necessary directories for Wireguard
  system.activationScripts.createWireguardDir.text = ''
    mkdir -p /etc/wireguard
    chmod 700 /etc/wireguard
  '';

  host = {
    userManagement.enable = true;

    users = {
      ryan = {
        name = "ryan";
        profile = "personal";
        isPrimary = true;
      };
      Work = {
        name = "Work";
        profile = "work";
        isPrimary = false;
      };
    };

    profiles = {
      personal = {
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
    settings = {
      download-buffer-size = 268435456; # 256MB
      trusted-users = ["root" "ryan" "Work" "@admin" "@wheel"];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://colmena.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };
  system.stateVersion = 5;
}
