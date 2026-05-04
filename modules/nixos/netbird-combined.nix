{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.netbird-combined;

  authSecretPath = "/var/lib/opnix/secrets/netbird-auth-secret";
  storeEncryptionKeyPath = "/var/lib/opnix/secrets/netbird-store-encryption-key";
  configPath = "/run/netbird/config.yaml";
  listenAddress = "${cfg.listenAddress}:${toString cfg.port}";
  exposedAddress = "https://${cfg.domain}:443";
  authIssuer = "https://${cfg.domain}/oauth2";
  dashboard = cfg.dashboard;
  dashboardOrigin = "https://${cfg.domain}";
  stunPortsYaml = "stunPorts: []";
  stunsYaml =
    if cfg.stun.enable && cfg.stun.uris != []
    then "stuns:\n${lib.concatMapStringsSep "\n" (uri: "    - uri: ${uri}\n      proto: udp") cfg.stun.uris}"
    else "stuns: []";
  configuredDashboard = pkgs.runCommand "netbird-dashboard-configured" {nativeBuildInputs = [pkgs.gettext];} ''
    cp -R ${dashboard.package} $out
    chmod -R u+w $out
    cp $out/OidcTrustedDomains.js.tmpl $out/OidcTrustedDomains.js

    export USE_AUTH0=${lib.escapeShellArg (lib.boolToString dashboard.useAuth0)}
    export AUTH_AUTHORITY=${lib.escapeShellArg dashboard.authAuthority}
    export AUTH_CLIENT_ID=${lib.escapeShellArg dashboard.authClientId}
    export AUTH_CLIENT_SECRET=${lib.escapeShellArg dashboard.authClientSecret}
    export AUTH_SUPPORTED_SCOPES=${lib.escapeShellArg dashboard.authSupportedScopes}
    export AUTH_AUDIENCE=${lib.escapeShellArg dashboard.authAudience}
    export AUTH_REDIRECT_URI=${lib.escapeShellArg dashboard.authRedirectUri}
    export AUTH_SILENT_REDIRECT_URI=${lib.escapeShellArg dashboard.authSilentRedirectUri}
    export NETBIRD_MGMT_API_ENDPOINT=${lib.escapeShellArg dashboard.apiEndpoint}
    export NETBIRD_MGMT_GRPC_API_ENDPOINT=${lib.escapeShellArg dashboard.grpcApiEndpoint}
    export NETBIRD_TOKEN_SOURCE=${lib.escapeShellArg dashboard.tokenSource}
    export NETBIRD_DRAG_QUERY_PARAMS=${lib.escapeShellArg (lib.boolToString dashboard.dragQueryParams)}
    export NETBIRD_HOTJAR_TRACK_ID=
    export NETBIRD_GOOGLE_ANALYTICS_ID=
    export NETBIRD_GOOGLE_TAG_MANAGER_ID=
    export NETBIRD_WASM_PATH=

    env_format='$USE_AUTH0 $AUTH_AUTHORITY $AUTH_CLIENT_ID $AUTH_CLIENT_SECRET $AUTH_SUPPORTED_SCOPES $AUTH_AUDIENCE $AUTH_REDIRECT_URI $AUTH_SILENT_REDIRECT_URI $NETBIRD_MGMT_API_ENDPOINT $NETBIRD_MGMT_GRPC_API_ENDPOINT $NETBIRD_TOKEN_SOURCE $NETBIRD_DRAG_QUERY_PARAMS $NETBIRD_HOTJAR_TRACK_ID $NETBIRD_GOOGLE_ANALYTICS_ID $NETBIRD_GOOGLE_TAG_MANAGER_ID $NETBIRD_WASM_PATH'
    while IFS= read -r file; do
      envsubst "$env_format" < "$file" > "$file.tmp"
      mv "$file.tmp" "$file"
    done < <(grep -R -l -E '\$(USE_AUTH0|AUTH_|NETBIRD_)' "$out")
  '';
in {
  options.services.netbird-combined = {
    enable = lib.mkEnableOption "combined NetBird self-hosted server";

    package = lib.mkPackageOption pkgs "netbird-server" {};

    domain = lib.mkOption {
      type = lib.types.str;
      default = "netbird.rgbr.ink";
      description = "Public domain for the NetBird management, signal, and relay endpoint.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address for the combined NetBird HTTP listener.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port for the combined NetBird HTTP listener.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/netbird";
      description = "State directory for NetBird data and embedded identity storage.";
    };

    metricsPort = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "Port for NetBird metrics.";
    };

    healthcheckAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:9000";
      description = "Address for the NetBird healthcheck endpoint.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum ["debug" "info" "warn" "error"];
      default = "info";
      description = "NetBird server log level.";
    };

    disableAnonymousMetrics = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable NetBird anonymous metrics collection.";
    };

    disableGeoliteUpdate = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable NetBird GeoLite database updates.";
    };

    stun = {
      enable = lib.mkEnableOption "external NetBird STUN discovery" // {default = true;};

      uris = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["stun:stun.cloudflare.com:3478"];
        description = "External STUN URIs advertised to NetBird clients.";
      };
    };

    dashboard = {
      enable = lib.mkEnableOption "the NetBird dashboard";

      package = lib.mkPackageOption pkgs "netbird-dashboard" {};

      listenAddress = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address for the local dashboard HTTP listener.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port for the local dashboard HTTP listener.";
      };

      apiEndpoint = lib.mkOption {
        type = lib.types.str;
        default = dashboardOrigin;
        defaultText = lib.literalExpression ''"https://$${config.services.netbird-combined.domain}"'';
        description = "Public management API endpoint used by the dashboard.";
      };

      grpcApiEndpoint = lib.mkOption {
        type = lib.types.str;
        default = dashboardOrigin;
        defaultText = lib.literalExpression ''"https://$${config.services.netbird-combined.domain}"'';
        description = "Public management gRPC endpoint used by the dashboard.";
      };

      authAuthority = lib.mkOption {
        type = lib.types.str;
        default = authIssuer;
        defaultText = lib.literalExpression ''"https://$${config.services.netbird-combined.domain}/oauth2"'';
        description = "OIDC issuer URL used by the dashboard.";
      };

      authClientId = lib.mkOption {
        type = lib.types.str;
        default = "netbird-dashboard";
        description = "OIDC client ID for the dashboard.";
      };

      authClientSecret = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "OIDC client secret for the dashboard; empty for the embedded public client.";
      };

      authAudience = lib.mkOption {
        type = lib.types.str;
        default = "netbird-dashboard";
        description = "OIDC audience expected by the dashboard.";
      };

      authSupportedScopes = lib.mkOption {
        type = lib.types.str;
        default = "openid profile email groups";
        description = "OAuth scopes requested by the dashboard.";
      };

      authRedirectUri = lib.mkOption {
        type = lib.types.str;
        default = "/nb-auth";
        description = "Dashboard OAuth redirect path.";
      };

      authSilentRedirectUri = lib.mkOption {
        type = lib.types.str;
        default = "/nb-silent-auth";
        description = "Dashboard OAuth silent-refresh redirect path.";
      };

      tokenSource = lib.mkOption {
        type = lib.types.enum ["accessToken" "idToken"];
        default = "accessToken";
        description = "Token source used by the dashboard.";
      };

      useAuth0 = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether dashboard authentication uses Auth0-specific behavior.";
      };

      dragQueryParams = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether the dashboard drags query parameters across auth redirects.";
      };
    };

    authSecretRef = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "1Password reference for the NetBird relay authentication secret.";
    };

    storeEncryptionKeySecretRef = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "1Password reference for the NetBird datastore encryption key.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.authSecretRef != null;
        message = "services.netbird-combined.authSecretRef must be set.";
      }
      {
        assertion = cfg.storeEncryptionKeySecretRef != null;
        message = "services.netbird-combined.storeEncryptionKeySecretRef must be set.";
      }
    ];

    users.groups.netbird = {};
    users.users.netbird = {
      isSystemUser = true;
      group = "netbird";
    };

    services.onepassword-secrets.secrets = {
      netbirdAuthSecret = {
        reference = cfg.authSecretRef;
        path = authSecretPath;
        owner = "netbird";
        group = "netbird";
        mode = "0400";
      };

      netbirdStoreEncryptionKey = {
        reference = cfg.storeEncryptionKeySecretRef;
        path = storeEncryptionKeyPath;
        owner = "netbird";
        group = "netbird";
        mode = "0400";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${toString cfg.dataDir} 0750 netbird netbird -"
    ];

    systemd.services.netbird-combined = {
      description = "Combined NetBird self-hosted server";
      wantedBy = ["multi-user.target"];
      after = [
        "network-online.target"
        "opnix-secrets.service"
      ];
      requires = [
        "network-online.target"
        "opnix-secrets.service"
      ];
      preStart = ''
        set -euo pipefail

        auth_secret_file=${lib.escapeShellArg authSecretPath}
        store_encryption_key_file=${lib.escapeShellArg storeEncryptionKeyPath}
        config_path=${lib.escapeShellArg configPath}

        if [ ! -f "$auth_secret_file" ]; then
          printf '%s\n' "Missing NetBird auth secret at $auth_secret_file" >&2
          exit 1
        fi

        if [ ! -f "$store_encryption_key_file" ]; then
          printf '%s\n' "Missing NetBird store encryption key at $store_encryption_key_file" >&2
          exit 1
        fi

        auth_secret="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$auth_secret_file")"
        store_encryption_key="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$store_encryption_key_file")"

        ${pkgs.coreutils}/bin/install -m 0600 /dev/null "$config_path"
        ${pkgs.bash}/bin/bash -c 'cat > "$1"' -- "$config_path" <<EOF
        server:
          listenAddress: ${listenAddress}
          exposedAddress: ${exposedAddress}
          metricsPort: ${toString cfg.metricsPort}
          healthcheckAddress: ${cfg.healthcheckAddress}
          logLevel: ${cfg.logLevel}
          logFile: console
          dataDir: ${toString cfg.dataDir}
          authSecret: $auth_secret
          ${stunPortsYaml}
          ${stunsYaml}
          disableAnonymousMetrics: ${lib.boolToString cfg.disableAnonymousMetrics}
          disableGeoliteUpdate: ${lib.boolToString cfg.disableGeoliteUpdate}
          store:
            engine: sqlite
            encryptionKey: $store_encryption_key
          auth:
            issuer: ${authIssuer}
            storage:
              type: sqlite3
            dashboardRedirectURIs:
              - ${dashboardOrigin}${dashboard.authRedirectUri}
              - ${dashboardOrigin}${dashboard.authSilentRedirectUri}
            cliRedirectURIs:
              - http://localhost:53000/
        EOF
      '';
      serviceConfig = {
        Type = "simple";
        User = "netbird";
        Group = "netbird";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${lib.getExe cfg.package} --config ${configPath}";
        Restart = "on-failure";
        RestartSec = "5s";
        StateDirectory = "netbird";
        RuntimeDirectory = "netbird";
        UMask = "0077";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [
          cfg.dataDir
          "/run/netbird"
        ];
      };
    };

    services.caddy.virtualHosts."http://${dashboard.listenAddress}:${toString dashboard.port}" = lib.mkIf dashboard.enable {
      extraConfig = ''
        bind ${dashboard.listenAddress}
        root * ${configuredDashboard}
        try_files {path} /index.html
        file_server
      '';
    };
  };
}
