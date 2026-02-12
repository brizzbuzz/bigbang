{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.host.desktop.enable {
    # Enable Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # XDG Portal for screen sharing, file picking, etc.
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = ["hyprland" "gtk"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        };
        hyprland.default = ["hyprland" "gtk"];
      };
    };

    # Enable required services
    services.dbus.enable = true;
    services.gnome.gnome-keyring.enable = true;

    # Security - polkit for privilege escalation
    security.polkit.enable = true;

    # Wayland-native polkit agent for Hyprland
    environment.systemPackages = with pkgs; [
      hyprpolkitagent
    ];

    systemd.user.services.hyprpolkitagent = {
      description = "Hyprland polkit agent";
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };
}
