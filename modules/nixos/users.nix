{
  pkgs,
  config,
  lib,
  ...
}: {
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlvSQnouxQqOlRGJ9AAerwJVjpdkH0F04LtVEnxJdUJ" # TODO: Move to config
  ];

  # Only create admin user if userManagement is NOT enabled
  # (when userManagement is enabled, accounts.nix handles user creation)
  users.users.${config.host.admin.name} = lib.mkIf (!config.host.userManagement.enable) {
    isNormalUser = true;
    initialPassword = "bigbangbooty";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlvSQnouxQqOlRGJ9AAerwJVjpdkH0F04LtVEnxJdUJ" # TODO: Move to config
    ];
    description = "Supreme Ruler";
    extraGroups = [
      "docker"
      "connman"
      "wheel"
    ];
    shell = pkgs.nushell;
  };

  nix.settings.trusted-users = [config.host.admin.name "root" "@wheel"];
}
