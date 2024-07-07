{osConfig, ...}: let
  admin = osConfig.host.admin.name;
in {
  home = {
    # Nushell
    file."/Users/${admin}/Library/Application Support/nushell/config.nu".source = ./dots/nushell/config.nu;
    file."/Users/${admin}/Library/Application Support/nushell/env.nu".source = ./dots/nushell/env.nu;
  };
}
