{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.netbird-personal-client;
  setupKeyPath = "/var/lib/opnix/secrets/netbird-homelab-headless-setup-key";
  usesSetupKey = cfg.enrollment == "setup-key";

  netbirdUrl = {
    Scheme = "https";
    Host = "${cfg.domain}:443";
  };
in {
  options.services.netbird-personal-client = {
    enable = lib.mkEnableOption "the personal self-hosted NetBird client";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "netbird.rgbr.ink";
      description = "Self-hosted NetBird management and admin domain.";
    };

    setupKeySecretRef = lib.mkOption {
      type = lib.types.str;
      default = "op://Homelab/Netbird Homelab Headless Setup Key/password";
      description = "1Password reference for the reusable personal NetBird setup key.";
    };

    enrollment = lib.mkOption {
      type = lib.types.enum ["setup-key" "interactive"];
      default = "setup-key";
      description = ''
        Enrollment flow for the client. Use setup-key for headless hosts and
        interactive for laptops or desktops that should authenticate through SSO.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 51820;
      description = "WireGuard port for the personal NetBird client.";
    };

    enableSshServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this peer should run the NetBird SSH server.";
    };

    enableSftp = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether NetBird SSH should expose the SFTP subsystem.";
    };

    enableSshRoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether NetBird SSH should allow root login.";
    };

    enableSshLocalPortForwarding = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether NetBird SSH should allow local port forwarding.";
    };

    enableSshRemotePortForwarding = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether NetBird SSH should allow remote port forwarding.";
    };

    disableSshAuth = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether NetBird SSH should disable JWT user authentication.";
    };

    sshJwtCacheTtl = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.unsigned;
      default = null;
      description = "Optional NetBird SSH JWT cache TTL in seconds for SSH client use.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.onepassword-secrets.secrets = lib.optionalAttrs usesSetupKey {
      netbirdHomelabHeadlessSetupKey = {
        reference = cfg.setupKeySecretRef;
        path = setupKeyPath;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    services.netbird.package = pkgs.netbird-client;
    services.netbird.clients.personal = {
      port = cfg.port;
      autoStart = true;
      openFirewall = true;
      login = lib.optionalAttrs usesSetupKey {
        enable = true;
        setupKeyFile = setupKeyPath;
        systemdDependencies = ["opnix-secrets.service"];
      };
      environment = {
        NB_ADMIN_URL = "https://${cfg.domain}";
        NB_DISABLE_SSH_CONFIG = "true";
        NB_MANAGEMENT_URL = "https://${cfg.domain}";
      };
      config =
        {
          AdminURL = netbirdUrl;
          ManagementURL = netbirdUrl;
          ServerSSHAllowed = cfg.enableSshServer;
          EnableSSHRoot = cfg.enableSshRoot;
          EnableSSHSFTP = cfg.enableSftp;
          EnableSSHLocalPortForwarding = cfg.enableSshLocalPortForwarding;
          EnableSSHRemotePortForwarding = cfg.enableSshRemotePortForwarding;
          DisableSSHAuth = cfg.disableSshAuth;
        }
        // lib.optionalAttrs (cfg.sshJwtCacheTtl != null) {
          SSHJWTCacheTTL = cfg.sshJwtCacheTtl;
        };
    };

    systemd.services.netbird-personal-login = lib.mkIf (!usesSetupKey) {
      enable = false;
    };
  };
}
