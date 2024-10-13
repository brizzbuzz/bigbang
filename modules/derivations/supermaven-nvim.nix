{
  lib,
  pkgs,
  vimUtils,
}:
with pkgs;
  vimUtils.buildVimPlugin {
    pname = "supermaven";
    version = "0.1.0";
    src = fetchFromGitHub {
      owner = "supermaven-inc";
      repo = "supermaven-nvim";
      rev = "rust-binary";
      sha256 = "ym33I/19rfdnal2VeElbrKTUQA/G/nezJq/r/AuZNos=";
    };
    meta = with lib; {
      description = "Supermaven plugin for Neovim";
      homepage = "https://github.com/supermaven-inc/supermaven-nvim";
      license = licenses.mit;
    };
  }
