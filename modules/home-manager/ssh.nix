{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isDesktop = osConfig.host.desktop.enable;
in {
  programs.ssh = lib.mkIf isDesktop {
    enable = true;

    extraConfig =
      if isDarwin
      then ''
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      ''
      else ''
        IdentityAgent "~/.1password/agent.sock"
      '';

    matchBlocks = {
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
}
