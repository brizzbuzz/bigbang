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

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
  
  # Ensure sudo wrapper takes precedence in PATH
  environment.extraInit = ''
    export PATH="/run/wrappers/bin:$PATH"
  '';
  
  # Ensure we don't accidentally add sudo to systemPackages
  # This would bypass the setuid wrapper
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];

  services.yubikey-agent.enable = lib.mkIf isDesktop true;
  programs.yubikey-touch-detector.enable = true;

  security.pam = {
    services = {
      greetd.fprintAuth = true;
      hyprlock.fprintAuth = true;
      login.fprintAuth = true;
      sudo.fprintAuth = true;
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
