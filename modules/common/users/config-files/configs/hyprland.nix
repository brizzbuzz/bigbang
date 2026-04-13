{lib, ...}: let
  desktopConfig = {
    hyprConfigFiles = [
      "appearance.conf"
      "autostart.conf"
      "binds.conf"
      "hyprland.conf"
      "input.conf"
      "monitors.conf"
      "profile.conf"
      "rules.conf"
      "submaps.conf"
      "theme.conf"
      "workspaces.conf"
    ];
    hyprlockFile = "hyprlock-personal.conf";
    wallpaperPalette = {
      background = "#0a0e27";
      accents = ["#ff006e" "#00f0ff" "#9d4edd" "#ffea00"];
    };
  };

  # Generate deployment script
  mkHyprlandScript = {
    homeDir,
    enabled,
  }: let
    hyprDir = "${homeDir}/.config/hypr";
  in
    lib.optionalString enabled ''
      # Create Hyprland config directories
      mkdir -p "${homeDir}/.config/waybar"
      mkdir -p "${homeDir}/.config/walker/themes/synthwave"
      mkdir -p "${homeDir}/.config/swaync"
      mkdir -p "${homeDir}/.config/gtk-3.0"
      mkdir -p "${homeDir}/.config/gtk-4.0"
      mkdir -p "${hyprDir}/scripts"
      mkdir -p "${hyprDir}/wallpapers"

      # Deploy modular Hyprland config
      for configFile in ${lib.concatStringsSep " " desktopConfig.hyprConfigFiles}; do
        [ -L "${hyprDir}/$configFile" ] && rm "${hyprDir}/$configFile"
        cp "${../files/hypr}/$configFile" "${hyprDir}/$configFile"
        chmod 644 "${hyprDir}/$configFile"
      done

      # Deploy Hyprlock config
      [ -L "${hyprDir}/hyprlock.conf" ] && rm "${hyprDir}/hyprlock.conf"
      cp "${../files/hypr}/${desktopConfig.hyprlockFile}" "${hyprDir}/hyprlock.conf"
      chmod 644 "${hyprDir}/hyprlock.conf"

      # Deploy Hypridle config (shared)
      [ -L "${hyprDir}/hypridle.conf" ] && rm "${hyprDir}/hypridle.conf"
      cp "${../files/hypr/hypridle.conf}" "${hyprDir}/hypridle.conf"
      chmod 644 "${hyprDir}/hypridle.conf"

      # Deploy wallpaper palette
      cat > "${hyprDir}/wallpaper-colors.json" << 'EOF'
      ${builtins.toJSON desktopConfig.wallpaperPalette}
      EOF
      chmod 644 "${hyprDir}/wallpaper-colors.json"

      # Deploy scripts
      for script in ${../files/hypr/scripts}/*; do
        if [ -f "$script" ]; then
          cp "$script" "${hyprDir}/scripts/"
          chmod 755 "${hyprDir}/scripts/$(basename "$script")"
        fi
      done

      # Deploy Waybar config
      cp "${../files/waybar}/config-personal.json" "${homeDir}/.config/waybar/config"
      cp "${../files/waybar}/style-personal.css" "${homeDir}/.config/waybar/style.css"
      chmod 644 "${homeDir}/.config/waybar/config"
      chmod 644 "${homeDir}/.config/waybar/style.css"

      # Deploy GTK settings
      cp "${../files/gtk/settings.ini}" "${homeDir}/.config/gtk-3.0/settings.ini"
      cp "${../files/gtk/settings.ini}" "${homeDir}/.config/gtk-4.0/settings.ini"
      chmod 644 "${homeDir}/.config/gtk-3.0/settings.ini"
      chmod 644 "${homeDir}/.config/gtk-4.0/settings.ini"

      # Deploy Walker config
      cp "${../files/walker}/config.toml" "${homeDir}/.config/walker/config.toml"
      cp "${../files/walker}/themes/synthwave/style.css" "${homeDir}/.config/walker/themes/synthwave/style.css"
      chmod 644 "${homeDir}/.config/walker/config.toml"
      chmod 644 "${homeDir}/.config/walker/themes/synthwave/style.css"

      # Deploy SwayNC config
      cp "${../files/swaync}/config.json" "${homeDir}/.config/swaync/config.json"
      cp "${../files/swaync}/style.css" "${homeDir}/.config/swaync/style.css"
      chmod 644 "${homeDir}/.config/swaync/config.json"
      chmod 644 "${homeDir}/.config/swaync/style.css"

      # Deploy wallpapers
      ${lib.optionalString (builtins.pathExists ../files/wallpapers/personal) ''
        for wallpaper in ${../files/wallpapers/personal}/*; do
          if [ -f "$wallpaper" ]; then
            cp "$wallpaper" "${hyprDir}/wallpapers/"
            chmod 644 "${hyprDir}/wallpapers/$(basename "$wallpaper")"
          fi
        done
      ''}
    '';
in {
  inherit mkHyprlandScript;
}
