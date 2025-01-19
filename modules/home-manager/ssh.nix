{
  lib,
  osConfig,
  ...
}: let
  isDesktop = osConfig.host.desktop.enable;
in {
  programs.ssh = lib.mkIf isDesktop {
    enable = true;

    # matchBlocks = {
    #   "cloudy" = {
    #     hostname = "cloudy";
    #     forwardAgent = true;
    #     user = "ryan";
    #   };
    # };

    forwardAgent = false;
    addKeysToAgent = "no";
    compression = false;
    serverAliveInterval = 0;
    serverAliveCountMax = 3;
    hashKnownHosts = false;
    userKnownHostsFile = "~/.ssh/known_hosts";
  };
}
