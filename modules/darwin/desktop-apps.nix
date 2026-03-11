{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.desktopApps;

  nixApplications = pkgs.buildEnv {
    name = "nix-system-applications";
    paths = config.environment.systemPackages;
    pathsToLink = ["/Applications"];
  };
in {
  options.host.desktopApps = {
    enable =
      lib.mkEnableOption "Expose Nix-installed macOS apps in /Applications"
      // {default = true;};
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.desktopApplications.text = lib.mkAfter ''
      target="/Applications/Nix Apps"

      echo "setting up $target..." >&2
      mkdir -p "$target"

      if [ -d "${nixApplications}/Applications" ]; then
        rsyncFlags=(
          --checksum
          --copy-unsafe-links
          --archive
          --delete
          --chmod=+w
        )

        ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" "${nixApplications}/Applications/" "$target"
      else
        /usr/bin/find "$target" -mindepth 1 -maxdepth 1 -exec /bin/rm -rf {} +
      fi
    '';
  };
}
