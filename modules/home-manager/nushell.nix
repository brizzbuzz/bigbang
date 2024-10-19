{...}: {
  programs.nushell = {
    enable = true;
    configFile.text = ''
      $env.config = {
        show_banner: false,
      }

      # Environment variables
      $env.PATH = ($env.PATH | split row (char esep) | prepend "/usr/local/bin")
      $env.EDITOR = "nvim"
    '';

    extraConfig = ''
      # Aliases
      alias nr = sudo colmena apply-local # Apply config only for the current host
      alias nrr = sudo colmena apply --on # Apply config for all hosts
      alias zj = zellij
    '';

    envFile.text = ''
      # Nushell Environment Config File
      $env.STARSHIP_SHELL = "nu"

      def create_left_prompt [] {
        starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
      }

      # Use nushell functions to define your right and left prompt
      $env.PROMPT_COMMAND = { create_left_prompt }
      $env.PROMPT_COMMAND_RIGHT = ""

      # The prompt indicators are environmental variables that represent
      # the state of the prompt
      $env.PROMPT_INDICATOR = "〉"
      $env.PROMPT_INDICATOR_VI_INSERT = ": "
      $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
      $env.PROMPT_MULTILINE_INDICATOR = "::: "
    '';
  };
}
