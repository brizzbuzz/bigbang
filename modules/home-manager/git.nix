{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isDesktop = osConfig.host.desktop.enable;
in {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = lib.mkDefault "Ryan Brink";
        email = lib.mkDefault "dev@ryanbr.ink";
        signingKey = lib.mkDefault "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+4LZpJ9+QmvjLKMzmHX1aUdsnoOlrrcTjwKhcwnCN1";
      };
      alias = {
        blah = "git add .; git commit -m 'blah'; git push";
        co = "checkout";
        cs = "commit --allow-empty-message -m ''";
        cm = "commit -m";
        dft = "difftool";
        dlog = "!f() { GIT_EXTERNAL_DIFF=difft git log -p --ext-diff $@; }; f";
        main = "git co main; git pl";
        pl = "pull";
        ps = "push";
      };
      commit.gpgsign = true;
      diff.tool = "difftastic";
      difftool.prompt = false;
      "difftool \"difftastic\"" = {
        cmd = "difft \"$LOCAL\" \"$REMOTE\"";
      };
      init.defaultBranch = "main";
      gpg.format = "ssh";
      "gpg \"ssh\"" = lib.mkIf (isDesktop || isDarwin) {
        program =
          if isDarwin
          then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
          else "/run/current-system/sw/bin/op-ssh-sign";
      };
      push.autoSetupRemote = true;
    };

    includes = [
      {
        condition = "gitdir:**/withodyssey/**";
        contents = {
          user = {
            email = "ryan@withodyssey.com";
            signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvZU9QjyJpanD7LGnSn4e5gcOdLqL8nkUYfowWyrFvl";
          };
        };
      }
    ];
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    options = {
      background = "dark";
    };
  };

  programs.git-cliff.enable = true;
}
