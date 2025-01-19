{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isDesktop = osConfig.host.desktop.enable;

  # 1Password agent config
  opAgentConfig = ''
    # First, specify work keys from Odyssey vault
    [[ssh-keys]]
    vault = "Odyssey"
    account = "my.1password.com"

    # Then add personal keys
    [[ssh-keys]]
    vault = "Private"
    account = "my.1password.com"
  '';

  # Define the agent socket path
  opAgentSocket = if isDarwin
    then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else "~/.1password/agent.sock";
in {
  programs.ssh = lib.mkIf isDesktop {
    enable = true;

    extraConfig = ''
      IdentityAgent "${opAgentSocket}"
    '';

    matchBlocks = {
      # Personal GitHub (default)
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identitiesOnly = true;
      };

      # Work GitHub configuration
      "github.com-work" = {
        hostname = "github.com";
        user = "git";
        identitiesOnly = true;
      };

      # Your existing server config
      "cloudy" = {
        hostname = "cloudy";
        forwardAgent = true;
        user = "ryan";
      };
    };

    forwardAgent = false;
    addKeysToAgent = "no";
    compression = false;
    serverAliveInterval = 0;
    serverAliveCountMax = 3;
    hashKnownHosts = false;
    userKnownHostsFile = "~/.ssh/known_hosts";
    controlMaster = "no";
    controlPath = "~/.ssh/master-%r@%n:%p";
    controlPersist = "no";
  };

  # Create 1Password SSH agent config file
  home.file.".config/1Password/ssh/agent.toml".text = opAgentConfig;

  # Set the environment variable
  home.sessionVariables = {
    SSH_AUTH_SOCK = opAgentSocket;
  };
}
