{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  environment = {
    etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          floorp
          vivaldi-bin
        '';
        mode = "0755";
      };
    };
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
