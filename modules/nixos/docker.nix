{pkgs, ...}: {
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "firewall-backend" = "nftables";
    };
  };

  # Docker 29's nftables backend shells out to `nft`.
  systemd.services.docker.path = [pkgs.nftables];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
