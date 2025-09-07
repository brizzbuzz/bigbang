{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.host.audiobookshelf.enable {
    services.audiobookshelf = {
      enable = true;
      port = config.host.audiobookshelf.port;
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
    networking.firewall.allowedTCPPorts = [config.host.audiobookshelf.port];
  };
}
