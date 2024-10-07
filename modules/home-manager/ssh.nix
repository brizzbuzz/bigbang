{
  lib,
  osConfig,
  ...
}: {
  programs.ssh = lib.mkIf osConfig.host.desktop.enable {
    enable = true;

    extraConfig = ''
      IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';

    matchBlocks = {
      "cloudy" = {
        hostname = "cloudy";
        forwardAgent = true;
        user = "ryan";
      };
    };

    # Override default settings
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
}
