{lib, ...}: let
  desktopConfig = {
    configFile = "hyprland-personal.conf";
    hyprlock = "hyprlock-personal.conf";
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
      mkdir -p "${hyprDir}/scripts"
      mkdir -p "${homeDir}/.config/waybar"
      mkdir -p "${homeDir}/.config/rofi"
      mkdir -p "${homeDir}/.config/dunst"
      mkdir -p "${homeDir}/.config/gtk-3.0"
      mkdir -p "${homeDir}/.config/gtk-4.0"
      mkdir -p "${hyprDir}/scripts"
      mkdir -p "${hyprDir}/wallpapers"

      # Deploy base Hyprland config (main entrypoint)
      [ -L "${hyprDir}/hyprland.conf" ] && rm "${hyprDir}/hyprland.conf"
      cp "${../files/hypr/hyprland-base.conf}" "${hyprDir}/hyprland.conf"
      chmod 644 "${hyprDir}/hyprland.conf"

      # Deploy profile-specific Hyprland config
      [ -L "${hyprDir}/hyprland-profile.conf" ] && rm "${hyprDir}/hyprland-profile.conf"
      cp "${../files/hypr}/${desktopConfig.configFile}" "${hyprDir}/hyprland-profile.conf"
      chmod 644 "${hyprDir}/hyprland-profile.conf"

      # Deploy Hyprlock config
      [ -L "${hyprDir}/hyprlock.conf" ] && rm "${hyprDir}/hyprlock.conf"
      cp "${../files/hypr}/${desktopConfig.hyprlock}" "${hyprDir}/hyprlock.conf"
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

      # Deploy Rofi config
      cp "${../files/rofi}/config-personal.rasi" "${homeDir}/.config/rofi/config.rasi"
      chmod 644 "${homeDir}/.config/rofi/config.rasi"

      # Deploy Dunst config
      cp "${../files/dunst}/dunstrc-personal" "${homeDir}/.config/dunst/dunstrc"
      chmod 644 "${homeDir}/.config/dunst/dunstrc"

      # Deploy wallpapers
      ${lib.optionalString (builtins.pathExists ../files/wallpapers/personal) ''
        for wallpaper in ${../files/wallpapers/personal}/*; do
          if [ -f "$wallpaper" ]; then
            cp "$wallpaper" "${hyprDir}/wallpapers/"
            chmod 644 "${hyprDir}/wallpapers/$(basename "$wallpaper")"
          fi
        done
      ''}

      # Deploy scripts
      for script in ${../files/hypr/scripts}/*; do
        if [ -f "$script" ]; then
          cp "$script" "${hyprDir}/scripts/"
          chmod 755 "${hyprDir}/scripts/$(basename "$script")"
        fi
      done
    '';
in {
  inherit mkHyprlandScript;
}
