{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    k3s
    tailscale
  ];

  networking = {
    hostName = "cloudy"; # TODO: Make this configurable?

    # Network Manager
    networkmanager.enable = true;

    # Firewall
    firewall = {
      allowedTCPPorts = [
        6443 # k3s TODO: Why is this required in single node setup? Wouldn't it all be internal?
      ];
    };
  };

  services = {
    k3s = {
      enable = true;
      role = "server";
    };

    tailscale.enable = true;
  };
}
