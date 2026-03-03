{
  fetchurl,
  lib,
  stdenvNoCC,
}: let
  system = stdenvNoCC.hostPlatform.system;
  platform =
    {
      aarch64-darwin = {
        suffix = "macos-arm64";
        sha256 = "08d39vnjzq9p9b1s32nvj15l4y91x83ad10n2p3xwhjss96m0fzc";
      };
      x86_64-darwin = {
        suffix = "macos-amd64";
        sha256 = "1682vasxmzcnlln5z88bbw4ysz2jh7nkx4rdwrl5lwinbww4i6pg";
      };
      aarch64-linux = {
        suffix = "linux-arm64";
        sha256 = "08949znp5gymack5i85rwnfwd6q5k03y42c8vq2ypskz3cl2f3m8";
      };
      x86_64-linux = {
        suffix = "linux-amd64";
        sha256 = "1lhprjfn1rwfmkhcyvdlvv5zjbjrva9yf768zm3gfxy8dd3ik48n";
      };
    }.${
      system
    } or (throw "datadog-mcp-cli: unsupported system ${system}");
  url = "https://coterm.datadoghq.com/mcp-cli/datadog_mcp_cli-${platform.suffix}";
in
  stdenvNoCC.mkDerivation {
    pname = "datadog-mcp-cli";
    version = "latest";

    src = fetchurl {
      inherit url;
      sha256 = platform.sha256;
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      install -m 755 "$src" "$out/bin/datadog_mcp_cli"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Datadog MCP CLI server";
      homepage = "https://coterm.datadoghq.com/mcp-cli";
      license = licenses.unfreeRedistributable;
      platforms = platforms.darwin ++ platforms.linux;
      mainProgram = "datadog_mcp_cli";
    };
  }
