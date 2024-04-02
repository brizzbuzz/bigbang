{pkgs, ...}: {
  users.users.ryan = {
    isNormalUser = true;
    description = "Supreme Ruler";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.nushell;
  };
  nix.settings.trusted-users = ["ryan"];
}
