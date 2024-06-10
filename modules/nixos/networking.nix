{config, ...}: {
  networking.hostName = config.host.name;
  networking.networkmanager.enable = true;
}
