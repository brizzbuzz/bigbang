{
  inputs,
  pkgs,
  pkgs-unstable,
  hello,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  environment = {
    variables = {
      EDITOR = "nvim";
    };
    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
    shells = with pkgs; [bashInteractive nushell];
    systemPackages =
      (with pkgs; [
        inputs.alejandra.defaultPackage.${system}
        font-awesome
        git
        neovim
        hello
      ])
      ++ (with pkgs-unstable; [
        nushell
        pueue
      ]);
  };
}
