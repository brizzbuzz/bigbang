{
  pkgs,
  lib,
}:
with pkgs;
  rustPlatform.buildRustPackage rec {
    pname = "nufmt";
    version = "dev";

    src = fetchFromGitHub {
      owner = "nushell";
      repo = pname;
      rev = "dbb9be79cca8364aefb3112dbeb299b28dcd840b";
      sha256 = "PpaiyEoITzb9qqY3EglVzHOaaI0upxmEejM0PQx+0gY=";
    };

    cargoSha256 = "V2hwsN/o9zopO+CqR0ikEGAhkk7XOXscci9n0SLXMYA=";

    meta = with lib; {
      description = "Formatter for the Nu scripting language";
      homepage = "https://github.com/nushell/nufmt";
      license = licenses.mit;
      maintainers = [maintainers.nushell];
    };
  }
