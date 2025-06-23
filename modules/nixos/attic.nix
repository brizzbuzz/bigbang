{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.host.attic.server.enable {
    services.atticd = {
      enable = true;
      environmentFile = "/var/lib/opnix/secrets/atticd/server/env";

      settings = {
        listen = "[::]:${toString config.host.attic.server.port}";

        jwt = {};

        storage = {
          type = "s3";
          region = "us-east-1";
          bucket = "some-bucket";
          endpoint = "https://callisto.dory-mamba.ts.net:9002";
        };

        # Data chunking
        #
        # Warning: If you change any of the values here, it will be
        # difficult to reuse existing chunks for newly-uploaded NARs
        # since the cutpoints will be different. As a result, the
        # deduplication ratio will suffer for a while after the change.
        chunking = {
          # The minimum NAR size to trigger chunking
          #
          # If 0, chunking is disabled entirely for newly-uploaded NARs.
          # If 1, all NARs are chunked.
          nar-size-threshold = 64 * 1024; # 64 KiB

          # The preferred minimum size of a chunk, in bytes
          min-size = 16 * 1024; # 16 KiB

          # The preferred average size of a chunk, in bytes
          avg-size = 64 * 1024; # 64 KiB

          # The preferred maximum size of a chunk, in bytes
          max-size = 256 * 1024; # 256 KiB
        };
      };
    };
  };
}
