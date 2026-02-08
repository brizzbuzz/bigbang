{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.host.desktop.enable {
    services.displayManager.sddm.enable = false;

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%Y-%m-%d %H:%M' --remember --remember-session --asterisks --greet-align left --container-padding 1 --prompt-padding 1 --greeting 'access node // frame' --theme 'bg=black;fg=brightgreen;prompt=green;input=brightgreen;action=brightblack;button=brightblack;container=black;time=green;greet=brightgreen' --cmd start-hyprland";
          user = "greeter";
        };
      };
    };

    # Ensure Hyprland session is available in display manager
    services.displayManager.sessionPackages = [pkgs.hyprland];

    # Rescue TTY: keep standard login prompt on tty2
  };
}
