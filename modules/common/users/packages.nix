{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host;
  isLinux = pkgs.stdenv.isLinux;
  isCompanyProfile = profile: profile == "company";

  # Base packages for all users
  basePackages = with pkgs;
    [
      curl
      git
      lazygit
      jq
      wget
      zip
      unzip
      fd
      ripgrep
      tree
      _1password-cli
      # Shell tools
      starship
      zoxide
      atuin
      bat
      bottom
      direnv
      zellij
      erdtree
      nushell
      colmena
      # Version control
      inputs.opnix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      (
        if pkgs ? ghostty-bin
        then pkgs.ghostty-bin
        else pkgs.ghostty
      )
    ]
    ++ lib.optionals isLinux [
      tftp-hpa
    ];

  # Development packages
  devPackages = with pkgs;
    [
      nodejs
      python3
      rustc
      cargo
      go
      # LSP servers
      gopls
      rust-analyzer
      typescript-language-server
      pyright
      nil
      nixd
      # Development tools
      helix
      gh
      git-cliff
      alejandra # Nix formatter for Helix
      gotools # Go tools including goimports for Helix
      delve # Go debugger for Helix
      # AI
      opencode
      # Package Managers
      uv
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      bruno
      opencode-desktop
    ]
    ++ lib.optionals isLinux [
      docker
    ];

  # Personal packages
  personalPackages = with pkgs;
    [
    ]
    ++ lib.optionals isLinux [
      discord
      spotify
      mpv
    ];

  # Work packages
  workPackages = with pkgs; [
    nodejs
    python3
    wget
    curl
  ];

  # Entertainment packages
  entertainmentPackages = with pkgs;
    lib.optionals isLinux [
      discord
      spotify
      steam
    ];

  # Business packages
  businessPackages = with pkgs;
    lib.optionals pkgs.stdenv.isDarwin [
      zoom-us
    ]
    ++ lib.optionals isLinux [
      zoom-us
      libreoffice-qt
    ];

  # Get packages for a specific profile
  getPackagesForProfile = profile: let
    personalProfile = cfg.profiles.personal;
    companyProfile = cfg.profiles.company;
  in
    basePackages
    ++ lib.optionals (profile == "personal" && personalProfile.developmentApps) devPackages
    ++ lib.optionals (profile == "personal" && personalProfile.personalApps) personalPackages
    ++ lib.optionals (profile == "personal" && personalProfile.entertainmentApps) entertainmentPackages
    ++ lib.optionals (isCompanyProfile profile && companyProfile.developmentApps) devPackages
    ++ lib.optionals (isCompanyProfile profile && companyProfile.businessApps) (workPackages ++ businessPackages);

  # Generate system packages from all user profiles
  allUserPackages = lib.flatten (
    map
    (userConfig: getPackagesForProfile userConfig.profile)
    (lib.attrValues cfg.users)
  );
in {
  options.host.userPackages = {
    enable = lib.mkEnableOption "Enable profile-based package management";
  };

  config = lib.mkIf cfg.userPackages.enable {
    environment.systemPackages = lib.unique allUserPackages;
  };
}
