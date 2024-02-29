{
  config,
  pkgs,
  ...
}: {
  # Set packages available globally across system
  environment.systemPackages = with pkgs; [
    git
    neovim
    nushell
    raycast
  ];

  users.users.ryan = {
    name = "ryan";
    home = "/Users/ryan";
    shell = pkgs.nushell;
  };

  # Homebrew (requires installation, managed by flake)
  # Generally, keep this to a minimum and manage through nix unless good reason not too
  homebrew = {
    enable = true;
    onActivation.upgrade = true;
    casks = [
      "1password" # 1Password GUI complains if not present directly inside Applications folder
      "jetbrains-toolbox" # Jetbrains toolbox is only supported by NixOS for linux targets
    ];
  };

  # Necessary for using flakes on this system
  nix.settings.experimental-features = "nix-command flakes";

  # Enable nix daemon 
  services.nix-daemon.enable = true;
  #services.nix-daemon.package = pkgs.nixFlakes;

  system = {
    stateVersion = 4;
    # This seems to break for some reason, even if I include self as a param
    # configurationRevision = self.rev or self.dirtyRev or null;
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  programs.zsh.enable = true;
}

