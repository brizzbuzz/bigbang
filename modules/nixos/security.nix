{
  config,
  lib,
  pkgs,
  ...
}: let
  isDesktop = config.host.desktop.enable;
in {
  environment.systemPackages = with pkgs; [
    pam_u2f
  ];

  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  services.yubikey-agent.enable = lib.mkIf isDesktop true;
  programs.yubikey-touch-detector.enable = true;

  security.pam = {
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };

    u2f = {
      enable = true;
      settings = {
        cue = false;
        authFile = "/var/lib/opnix/secrets/u2f/keys";
      };
    };
  };
}
