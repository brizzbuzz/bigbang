{ lib, osConfig, ... }: {
  programs.zed-editor = lib.mkIf osConfig.host.remote.enable {
    enable = true;
    installRemoteServer = true;
  };
}
