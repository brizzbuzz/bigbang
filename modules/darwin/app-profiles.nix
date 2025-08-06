{
  config,
  lib,
  ...
}: let
  cfg = config.host;

  getUsersByProfile = profile: lib.filterAttrs (_: user: user.profile == profile) cfg.users;

  personalApps = {
    casks = [
      "discord"
      "spotify"
      "steam"
      "pocket-casts"
      "parsec"
      "iina"
      "spacedrive"
      "protonvpn"
    ];
    masApps = {
      "WireGuard" = 1451685025;
    };
  };

  appleIdApps = {
    masApps = {
      "Xcode" = 497799835;
    };
  };

  entertainmentApps = {
    casks = [
      "discord"
      "spotify"
      "steam"
      "pocket-casts"
      "iina"
    ];
  };

  developmentApps = {
    casks = [
      "jetbrains-toolbox"
      "gitbutler"
      "bruno"
      "proxyman"
      "zed"
    ];
  };

  businessApps = {
    casks = [
      "notion"
      "zoom"
      "google-chrome"
      "zed"
    ];
  };

  commonApps = {
    casks = [
      "1password"
      "fantastical"
      "figma"
      "ghostty"
      "hammerspoon"
      "keymapp"
      "logi-options+"
      "orion"
      "sf-symbols"
      "the-unarchiver"
    ];
    brews = [
      "mas"
    ];
  };

  generateAppList = appType: let
    personalProfile = cfg.profiles.personal;
    workProfile = cfg.profiles.work;

    personalUsers = getUsersByProfile "personal";
    workUsers = getUsersByProfile "work";

    commonList = commonApps.${appType} or [];

    personalList =
      lib.optionals (personalUsers != {} && personalProfile.personalApps) (personalApps.${appType} or [])
      ++ lib.optionals (personalUsers != {} && personalProfile.appleIdApps) (appleIdApps.${appType} or [])
      ++ lib.optionals (personalUsers != {} && personalProfile.entertainmentApps) (entertainmentApps.${appType} or [])
      ++ lib.optionals (personalUsers != {} && personalProfile.developmentApps) (developmentApps.${appType} or []);

    workList =
      lib.optionals (workUsers != {} && workProfile.businessApps) (businessApps.${appType} or [])
      ++ lib.optionals (workUsers != {} && workProfile.developmentApps) (developmentApps.${appType} or []);
  in
    lib.unique (commonList ++ personalList ++ workList);

  generateMasApps = let
    personalProfile = cfg.profiles.personal;
    workProfile = cfg.profiles.work;

    personalUsers = getUsersByProfile "personal";
    workUsers = getUsersByProfile "work";

    commonMas = commonApps.masApps or {};

    personalMas =
      lib.optionalAttrs (personalUsers != {} && personalProfile.personalApps) (personalApps.masApps or {})
      // lib.optionalAttrs (personalUsers != {} && personalProfile.appleIdApps) (appleIdApps.masApps or {})
      // lib.optionalAttrs (personalUsers != {} && personalProfile.entertainmentApps) (entertainmentApps.masApps or {});

    workMas = lib.optionalAttrs (workUsers != {} && workProfile.businessApps) (businessApps.masApps or {});
  in
    commonMas // personalMas // workMas;
in {
  config = lib.mkIf (cfg.users != {}) {
    homebrew = {
      casks = generateAppList "casks";
      brews = generateAppList "brews";
      masApps = generateMasApps;
    };
  };
}
