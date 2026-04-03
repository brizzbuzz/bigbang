{
  config,
  lib,
  ...
}: {
  networking = {
    hostName = config.host.name;

    # Use the UniFi router as the DNS server by default
    # This ensures proper resolution of local lan.rgbr.ink domains
    nameservers = lib.mkDefault ["192.168.11.1"];
  };
}
