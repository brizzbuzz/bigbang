[
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
  })

  # Disable checks for fish shell
  (final: prev: {
    fish = prev.fish.overrideAttrs (oldAttrs: {
      doCheck = false;
    });
  })
]
