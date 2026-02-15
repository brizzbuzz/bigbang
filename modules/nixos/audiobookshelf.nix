{
  config,
  lib,
  ...
}:
let
  cfg = config.services.audiobookshelfHost;
in {
  options.services.audiobookshelfHost = {
    enable = lib.mkEnableOption "Enable AudioBookshelf server";
    port = lib.mkOption {
      type = lib.types.int;
      default = 13378;
      description = "Port for AudioBookshelf web interface";
    };
  };

  config = lib.mkIf cfg.enable {
    services.audiobookshelf = {
      enable = true;
      port = cfg.port;
      host = "0.0.0.0";
      dataDir = "audiobookshelf";
    };

    # Create media directories on the dedicated media drive
    systemd.tmpfiles.rules = [
      "d /data/media 0755 audiobookshelf audiobookshelf -"
      "d /data/media/audiobooks 0755 audiobookshelf audiobookshelf -"
      "d /data/media/podcasts 0755 audiobookshelf audiobookshelf -"
    ];

    # Open firewall port
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
