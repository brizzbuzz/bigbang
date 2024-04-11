{
  config,
  lib,
  ...
}: {
  programs.hyprland = lib.mkIf config.host.desktop.enable {
    enable = true;
    xwayland = {
      enable = true;
    };
  };
}
