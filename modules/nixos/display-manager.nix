{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.host.desktop.enable {
    environment.systemPackages = [
      (
        pkgs.catppuccin-sddm.override {
          flavor = "macchiato";
          font = "JetBrainsMono Nerd Font";
          fontSize = "16";
          loginBackground = true;
        }
      )
    ];
    services.displayManager.sddm = {
      enable = true;
      theme = "catppuccin-macchiato";
      package = pkgs.kdePackages.sddm;
      wayland.enable = true;
    };
  };
}
