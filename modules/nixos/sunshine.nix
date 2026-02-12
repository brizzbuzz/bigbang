{
  config,
  lib,
  ...
}: let
  cfg = config.host.sunshine;
in {
  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    hardware.uinput.enable = true;
    users.groups.uinput = {};
    users.users.${cfg.user} = {
      extraGroups = lib.mkAfter ["input" "uinput"];
      linger = true;
    };
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';

    systemd.user.services.sunshine.wantedBy = ["default.target"];
  };
}
