{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.stream.sunshine;
  configHome = "${cfg.dataDir}/config";
  sunshinePath = lib.makeBinPath [
    pkgs.bash
    pkgs.coreutils
    pkgs.steam
    pkgs.util-linux
    pkgs.xorg.xrandr
  ];
in {
  options.services.stream.sunshine = {
    enable = lib.mkEnableOption "Enable Sunshine host integration";
    user = lib.mkOption {
      type = lib.types.str;
      default = "ryan";
      description = "User that runs the Sunshine service";
    };
    createUser = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Create a dedicated system user for Sunshine";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/sunshine";
      description = "State directory for Sunshine user data";
    };
    headlessXorg = {
      enable = lib.mkEnableOption "Enable a headless Xorg session for Sunshine";
      display = lib.mkOption {
        type = lib.types.str;
        default = ":0";
        description = "X display number for the headless Sunshine session";
      };
    };
    appsJson = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a Sunshine apps.json file to install";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.headlessXorg.enable || cfg.createUser;
        message = "services.stream.sunshine.headlessXorg.enable requires createUser = true.";
      }
    ];

    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = lib.mkDefault (!cfg.headlessXorg.enable);
      openFirewall = true;
    };

    environment.systemPackages = lib.optionals cfg.headlessXorg.enable (with pkgs; [
      openbox
      xorg.xauth
      xorg.xorgserver
      xorg.xrandr
    ]);

    services.xserver = lib.mkIf cfg.headlessXorg.enable {
      enable = true;
      displayManager.startx.enable = true;
    };

    hardware.uinput.enable = true;
    users.groups.uinput = {};
    users.groups.${cfg.user} = lib.mkIf cfg.createUser {};
    users.users.${cfg.user} = lib.mkMerge [
      {
        extraGroups = lib.mkAfter ["input" "uinput" "video" "tty"];
        linger = true;
      }
      (lib.mkIf cfg.createUser {
        isSystemUser = true;
        group = cfg.user;
        home = cfg.dataDir;
        createHome = true;
      })
    ];
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';

    systemd.tmpfiles.rules = lib.optionals cfg.createUser ([
        "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.user} -"
        "d ${configHome} 0750 ${cfg.user} ${cfg.user} -"
        "f ${cfg.dataDir}/.Xauthority 0640 ${cfg.user} ${cfg.user} -"
      ]
      ++ lib.optionals (cfg.appsJson != null) [
        "d ${configHome}/sunshine 0750 ${cfg.user} ${cfg.user} -"
        "L+ ${configHome}/sunshine/apps.json - - - - /etc/sunshine/apps.json"
      ]);

    environment.etc = lib.optionalAttrs (cfg.appsJson != null) {
      "sunshine/apps.json".source = cfg.appsJson;
    };

    systemd.user.services.sunshine = {
      wantedBy = ["default.target"];
      after = lib.optionals cfg.headlessXorg.enable ["sunshine-openbox.service"];
      requires = lib.optionals cfg.headlessXorg.enable ["sunshine-openbox.service"];
      unitConfig.ConditionUser = cfg.user;
      serviceConfig.Environment = lib.mkAfter [
        "PATH=${sunshinePath}"
      ];
      environment =
        lib.optionalAttrs cfg.createUser {
          HOME = cfg.dataDir;
          XDG_CONFIG_HOME = configHome;
          LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
        }
        // lib.optionalAttrs cfg.headlessXorg.enable {
          DISPLAY = cfg.headlessXorg.display;
          XAUTHORITY = "${cfg.dataDir}/.Xauthority";
        };
    };

    systemd.services.sunshine-xorg = lib.mkIf cfg.headlessXorg.enable {
      description = "Headless Xorg server for Sunshine";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        Type = "simple";
        ExecStartPre = "${pkgs.runtimeShell} -lc \"${pkgs.xorg.xauth}/bin/xauth -f ${cfg.dataDir}/.Xauthority add ${cfg.headlessXorg.display} . $(${pkgs.util-linux}/bin/mcookie); ${pkgs.coreutils}/bin/chown ${cfg.user}:${cfg.user} ${cfg.dataDir}/.Xauthority; ${pkgs.coreutils}/bin/chmod 0640 ${cfg.dataDir}/.Xauthority\"";
        ExecStart = "${pkgs.xorg.xorgserver}/bin/Xorg ${cfg.headlessXorg.display} -nolisten tcp -noreset -auth ${cfg.dataDir}/.Xauthority";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    systemd.user.services.sunshine-openbox = lib.mkIf cfg.headlessXorg.enable {
      description = "Openbox session for Sunshine";
      wantedBy = ["default.target"];
      unitConfig.ConditionUser = cfg.user;
      environment = {
        HOME = cfg.dataDir;
        XDG_CONFIG_HOME = configHome;
        DISPLAY = cfg.headlessXorg.display;
        XAUTHORITY = "${cfg.dataDir}/.Xauthority";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.openbox}/bin/openbox-session";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };
}
