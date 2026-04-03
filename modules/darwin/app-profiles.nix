{
  config,
  lib,
  ...
}: let
  cfg = config.host;
  isCompanyProfile = user: user.profile == "company";

  getUsersByProfile = profile: lib.filterAttrs (_: user: user.profile == profile) cfg.users;
  companyUsers = lib.filterAttrs (_: user: isCompanyProfile user) cfg.users;

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
    companyProfile = cfg.profiles.company;

    personalUsers = getUsersByProfile "personal";
    companyUsersByProfile = companyUsers;

    commonList = commonApps.${appType} or [];

    personalList =
      lib.optionals (personalUsers != {} && personalProfile.personalApps) (personalApps.${appType} or [])
      ++ lib.optionals (personalUsers != {} && personalProfile.entertainmentApps) (entertainmentApps.${appType} or [])
      ++ lib.optionals (personalUsers != {} && personalProfile.developmentApps) (developmentApps.${appType} or []);

    companyList =
      lib.optionals (companyUsersByProfile != {} && companyProfile.businessApps) (businessApps.${appType} or [])
      ++ lib.optionals (companyUsersByProfile != {} && companyProfile.developmentApps) (developmentApps.${appType} or []);
  in
    lib.unique (commonList ++ personalList ++ companyList);
in {
  config = lib.mkIf (cfg.users != {}) {
    homebrew = {
      casks = generateAppList "casks";
      brews = generateAppList "brews";
    };
  };
}
