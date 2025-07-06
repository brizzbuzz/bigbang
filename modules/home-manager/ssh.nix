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
      "callisto" = {
        hostname = "callisto.chateaubr.ink";
        forwardAgent = true;
        user = "ryan";
      };

      "ganymede" = {
        hostname = "ganymede.chateaubr.ink";
        forwardAgent = true;
        user = "ryan";
      };
    };

    forwardAgent = false;
    addKeysToAgent = "yes";
    compression = true;
    serverAliveInterval = 60;
    serverAliveCountMax = 3;
    hashKnownHosts = true;
    userKnownHostsFile = "~/.ssh/known_hosts";
    controlMaster = "auto";
    controlPath = "~/.ssh/master-%r@%h:%p";
    controlPersist = "10m";
  };
}
