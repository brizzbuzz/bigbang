{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # Base packages for all users
  basePackages = with pkgs; [
    curl
    git
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
    nushell
    colmena
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
      zls
      nodePackages.typescript-language-server
      pyright
      nil
      # Development tools
      gh
      git-cliff
      tokei
      docker-compose
      kubectl
    ]
    ++ lib.optionals isLinux [
      docker
    ];

  # Personal packages
  personalPackages = with pkgs;
    [
      obsidian
      ffmpeg
      yt-dlp
      bind
    ]
    ++ lib.optionals isLinux [
      discord
      spotify
      floorp
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
    lib.optionals isLinux [
      zoom-us
      libreoffice-qt
    ];

  # Get packages for a specific profile
  getPackagesForProfile = profile: let
    personalProfile = cfg.profiles.personal;
    workProfile = cfg.profiles.work;
  in
    basePackages
    ++ lib.optionals (profile == "personal" && personalProfile.developmentApps) devPackages
    ++ lib.optionals (profile == "personal" && personalProfile.personalApps) personalPackages
    ++ lib.optionals (profile == "personal" && personalProfile.entertainmentApps) entertainmentPackages
    ++ lib.optionals (profile == "work" && workProfile.developmentApps) devPackages
    ++ lib.optionals (profile == "work" && workProfile.businessApps) (workPackages ++ businessPackages);

  # Generate system packages from all user profiles
  allUserPackages = lib.flatten (
    lib.mapAttrsToList
    (userName: userConfig: getPackagesForProfile userConfig.profile)
    cfg.users
  );
in {
  options.host.userPackages = {
    enable = lib.mkEnableOption "Enable profile-based package management";
  };

  config = lib.mkIf cfg.userPackages.enable {
    environment.systemPackages = lib.unique allUserPackages;
  };
}
