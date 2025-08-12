{
  config,
  lib,
  ...
}: {
  networking = {
    hostName = config.host.name;

    # Use the Unifi router as the DNS server by default
    # This ensures proper resolution of local .chateaubr.ink domains
    nameservers = lib.mkDefault ["192.168.11.1"];
  };
}
