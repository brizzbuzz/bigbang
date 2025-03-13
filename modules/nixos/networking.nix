{
  config,
  lib,
  ...
}: {
  networking = {
    hostName = config.host.name;

    # Use the Unifi router as the DNS server by default
    # This ensures proper resolution of local .brizz.net domains
    nameservers = lib.mkDefault ["192.168.1.1"];
  };
}
