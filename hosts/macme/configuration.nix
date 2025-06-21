{pkgs, ...}: {
  imports = [
    ../../modules/common
    ../../modules/darwin
    ../../modules/home-manager
  ];

  nixpkgs.config.allowUnfree = true;

  # Multi-user configuration
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
    # App lists are now managed by the app-profiles module
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
