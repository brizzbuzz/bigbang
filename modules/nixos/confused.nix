{lib, ...}: {
  imports = [
    ./password-manager.nix
  ];

  password-manager = {
    enable = lib.mkDefault true;
    gui = {
      enable = lib.mkDefault true;
      # TODO: Any way to make this a reference to another config value?
      polkitPolicyOwners = lib.mkDefault ["ryan"];
    };
  };
}
