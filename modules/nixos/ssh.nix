{...}: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "yes";
      AllowTcpForwarding = "yes";
    };
  };

  networking.firewall.allowedTCPPorts = [22];
}
