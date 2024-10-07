{
  lib,
  osConfig,
  ...
}: {
  programs.ssh = lib.mkIf osConfig.host.desktop.enable {
    enable = true;

    compression = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/control-%C";
    controlPersist = "10m";

    extraConfig = ''
      Host *
        IdentityAgent ~/.1password/agent.sock
        AddKeysToAgent yes
        IdentitiesOnly yes
        HashKnownHosts yes
        ServerAliveInterval 60
        ServerAliveCountMax 2
    '';

    matchBlocks = {
      "cloudy" = {
        hostname = "cloudy";
        forwardAgent = true;
        user = "ryan";
      };
    };

    includes = [
      "~/.ssh/config.d/*"
    ];
  };
}
