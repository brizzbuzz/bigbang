[
  (_final: prev: {
    netbird-client = prev.callPackage ./packages/netbird-client.nix {};
    netbird-server = prev.callPackage ./packages/netbird-server.nix {};
  })

  (_final: prev: {
    opencode-desktop = prev.opencode-desktop.overrideAttrs (oldAttrs: {
      env =
        (oldAttrs.env or {})
        // prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
          CSC_IDENTITY_AUTO_DISCOVERY = "false";
        };

      postPatch =
        (oldAttrs.postPatch or "")
        + prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin ''
          substituteInPlace packages/desktop/electron-builder.config.ts \
            --replace-fail 'hardenedRuntime: true,' 'hardenedRuntime: false,' \
            --replace-fail 'gatekeeperAssess: false,' 'gatekeeperAssess: false, identity: null,' \
            --replace-fail 'notarize: true,' 'notarize: false,' \
            --replace-fail 'sign: true,' 'sign: false,'
        '';
    });
  })

  # Disable checks for fish shell
  (_final: prev: {
    fish = prev.fish.overrideAttrs (_oldAttrs: {
      doCheck = false;
    });
  })
]
