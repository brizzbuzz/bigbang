{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.host.roles.desktop {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    services.displayManager.sddm.enable = false;

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%Y-%m-%d %H:%M' --remember --remember-session --asterisks --greet-align left --container-padding 1 --prompt-padding 1 --greeting 'access node // frame' --theme 'bg=#0a0e27;fg=#d9def2;prompt=#00f0ff;input=#d9def2;action=#8b93b8;button=#151c35;container=#11162f;time=#7aa2f7;greet=#ff79c6' --cmd start-hyprland";
          user = "greeter";
        };
      };
    };

    services.displayManager.sessionPackages = [pkgs.hyprland];

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

    services.dbus.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;

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
