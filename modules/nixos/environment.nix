{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  environment = {
    variables = {
      EDITOR = "nvim";
    };
    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
    shells = with pkgs; [bashInteractive nushell zsh];
    systemPackages = with pkgs; [
      git
    ];
  };
}
