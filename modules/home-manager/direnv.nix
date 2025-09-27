{...}: {
  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;

    # Make direnv quiet - no loading/unloading messages
    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };

  # Set DIRENV_LOG_FORMAT to empty string to silence direnv messages
  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };
}
