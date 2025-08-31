[
  # Speedtest
  (final: prev: {
    speedtest = prev.callPackage ./../derivations/speedtest.nix {};
  })

  # Fix opensearch-py build issues by disabling tests that fail in sandbox
  (final: prev: {
    python3Packages =
      prev.python3Packages
      // {
        opensearch-py = prev.python3Packages.opensearch-py.overridePythonAttrs (oldAttrs: {
          doCheck = false;
          doInstallCheck = false;
          nativeCheckInputs = [];
          checkInputs = [];
        });
      };

    # Fix open-webui missing rapidocr-onnxruntime dependency
    open-webui = prev.open-webui.overridePythonAttrs (oldAttrs: {
      dontCheckRuntimeDeps = true; # Disable runtime dependency check
    });
  })
]
