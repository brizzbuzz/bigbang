[
  (final: prev: {
    vimPlugins =
      prev.vimPlugins
      // {
        supermaven = prev.callPackage ./../derivations/supermaven-nvim.nix {};
      };
  })

  (final: prev: {
    speedtest = prev.callPackage ./../derivations/speedtest.nix {};
  })
]
