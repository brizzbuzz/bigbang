{...}: {
  home = {
    # Hyprland
    file.".config/hypr".source = ./dots/hypr;
    file.".config/hypr".recursive = true;

    # WLogout
    file.".config/wlogout".source = ./dots/wlogout;
    file.".config/wlogout".recursive = true;

    # Waybar
    file.".config/waybar".source = ./dots/waybar;
    file.".config/waybar".recursive = true;

    # Wofi
    file.".config/wofi/style.css".source = ./dots/wofi/style.css;

    # XModMap
    file.".config/xmodmap/xmodmap".source = ./dots/xmodmap/xmodmap;
  };
}
