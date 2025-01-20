{
  pkgs,
  config,
  ...
}: {
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlvSQnouxQqOlRGJ9AAerwJVjpdkH0F04LtVEnxJdUJ" # TODO: Move to config
  ];
  users.users.${config.host.admin.name} = {
    isNormalUser = true;
    initialPassword = "bigbangbooty";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlvSQnouxQqOlRGJ9AAerwJVjpdkH0F04LtVEnxJdUJ" # TODO: Move to config
    ];
    description = "Supreme Ruler";
    extraGroups = [
      "docker"
      "networkmanager"
      "connman"
      "wheel"
    ];
    shell = pkgs.nushell;
  };
  nix.settings.trusted-users = [config.host.admin.name];
}
