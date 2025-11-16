{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  options.host.userShell = {
    enable = lib.mkEnableOption "Enable user shell configuration";
  };

  config = lib.mkIf cfg.userShell.enable {
    # Zsh configuration - basic setup compatible with both Darwin and Linux
    programs.zsh =
      {
        enable = true;
        enableCompletion = lib.mkDefault true;
      }
      // lib.optionalAttrs isLinux {
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        interactiveShellInit = ''
          # Starship prompt
          if command -v starship >/dev/null 2>&1; then
            eval "$(starship init zsh)"
          fi

          # Zoxide
          if command -v zoxide >/dev/null 2>&1; then
            eval "$(zoxide init zsh)"
          fi

          # Atuin history
          if command -v atuin >/dev/null 2>&1; then
            eval "$(atuin init zsh)"
          fi

          # Direnv
          if command -v direnv >/dev/null 2>&1; then
            eval "$(direnv hook zsh)"
          fi
        '';
      };

    # Starship prompt configuration - disabled for Darwin compatibility
    # programs.starship = lib.mkIf isLinux {
    #   enable = true;
    #   settings = {
    #     format = lib.concatStrings [
    #       "$all"
    #       "$character"
    #     ];

    #     character = {
    #       success_symbol = "[➜](bold green)";
    #       error_symbol = "[➜](bold red)";
    #     };

    #     git_branch = {
    #       symbol = "🌱 ";
    #     };

    #     directory = {
    #       truncation_length = 3;
    #       truncate_to_repo = false;
    #     };
    #   };
    # };

    # Direnv configuration - disabled for Darwin compatibility
    # programs.direnv = lib.mkIf isLinux {
    #   enable = true;
    #   nix-direnv.enable = true;
    # };

    # Shell packages
    environment.systemPackages = with pkgs; [
      starship
      zoxide
      atuin
      bat
      bottom
      direnv
      nushell
    ];
  };
}
