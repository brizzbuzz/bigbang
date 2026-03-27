{
  config,
  lib,
  ...
}: let
  cfg = config.host;

  getUsersByProfile = profile: lib.filterAttrs (_: user: user.profile == profile) cfg.users;

  personalApps = {
    casks = [
      "protonvpn"
    ];
  };

  entertainmentApps = {
    casks = [
      "spotify"
    ];
  };

  developmentApps = {
    casks = [
      "proxyman"
    ];
  };

  businessApps = {
    casks = [
      "google-chrome"
    ];
  };

  commonApps = {
    casks = [
      "1password"
      "sf-symbols"
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
      ++ lib.optionals (personalUsers != {} && personalProfile.entertainmentApps) (entertainmentApps.${appType} or [])
      ++ lib.optionals (personalUsers != {} && personalProfile.developmentApps) (developmentApps.${appType} or []);

    workList =
      lib.optionals (workUsers != {} && workProfile.businessApps) (businessApps.${appType} or [])
      ++ lib.optionals (workUsers != {} && workProfile.developmentApps) (developmentApps.${appType} or []);
  in
    lib.unique (commonList ++ personalList ++ workList);
in {
  config = lib.mkIf (cfg.users != {}) {
    homebrew = {
      casks = generateAppList "casks";
      brews = generateAppList "brews";
    };
  };
}
