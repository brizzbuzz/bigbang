{pkgs, ...}: {
  environment.systemPackages = with pkgs; [kanata];
  systemd.user.services.kanata = {
    description = "Kanata";
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kanata}/bin/kanata -c ~/.config/kanata/kanata.kbd";
      Restart = "no";
    };
  };
}
