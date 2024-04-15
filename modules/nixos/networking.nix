{
  lib,
  config,
  ...
}: {
  networking.hostName = config.host.name;
  networking.networkmanager.enable = true;

  systemd.services.NetworkManager-wait-online.enable = lib.mkIf config.host.remote.enable false;
}
