{pkgs, ...}: {
  home.packages = with pkgs; [
    connman
    iwd
    iwgtk
    tailscale
  ];
}
