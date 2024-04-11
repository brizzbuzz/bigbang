{
  config,
  lib,
  ...
}: {
  security.sudo.wheelNeedsPassword = lib.mkIf config.host.remote.enable true;

  security.pam.services = lib.mkIf config.host.desktop.enable {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };
}
