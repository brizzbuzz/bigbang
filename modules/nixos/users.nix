{
  pkgs,
  config,
  ...
}: {
  users.users.${config.host.admin.name} = {
    isNormalUser = true;
    description = "Supreme Ruler";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.nushell;
  };
  nix.settings.trusted-users = [config.host.admin.name];
}
