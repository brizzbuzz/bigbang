{...}: {
  home = {
    # Hyprland
    file.".config/hypr".source = ./dots/hypr;
    file.".config/hypr".recursive = true;

    # Wofi
    file.".config/wofi/style.css".source = ./dots/wofi/style.css;

    # XModMap
    file.".config/xmodmap/xmodmap".source = ./dots/xmodmap/xmodmap;
  };
}
