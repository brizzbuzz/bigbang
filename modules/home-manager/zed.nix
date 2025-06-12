{
  lib,
  pkgs,
  osConfig,
  ...
}: {
  home.file.".zed_server" = lib.mkIf osConfig.host.remote.enable {
     source = "${pkgs.zed-editor.remote_server}/bin";
     # keeps the folder writable, but symlinks the binaries into it
     recursive = true;
   };
}
