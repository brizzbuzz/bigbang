{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isDesktop = osConfig.host.desktop.enable;
  workUser = {
    email = "ryan@withodyssey.com";
    signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvZU9QjyJpanD7LGnSn4e5gcOdLqL8nkUYfowWyrFvl";
  };

  opPath = if isDarwin then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" else "/run/current-system/sw/bin/op-ssh-sign";
  opSockPath = if isDarwin then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" else "~/.1password/agent.sock";
in {
  programs.git = {
    enable = true;
    userName = "Ryan Brink";
    userEmail = "dev@ryanbr.ink";
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+4LZpJ9+QmvjLKMzmHX1aUdsnoOlrrcTjwKhcwnCN1";
      signByDefault = true;
    };

    includes = [
      {
        condition = "gitdir:~/Workspace/withodyssey/**";
        contents = {
          user = workUser;
          core.sshCommand = "ssh -o IdentityAgent=\"${opSockPath}\"";
        };
      }
      {
        condition = "gitdir:~/Workspace/ryan-odyssey/**";
        contents = {
          user = workUser;
          core.sshCommand = "ssh -o IdentityAgent=\"${opSockPath}\"";
        };
      }
    ];

    aliases = {
      blah = "!git add .; git commit -m 'blah'; git push";
      co = "checkout";
      cs = "commit --allow-empty-message -m ''";
      cm = "commit -m";
      dft = "difftool";
      dlog = "!f() { GIT_EXTERNAL_DIFF=difft git log -p --ext-diff $@; }; f";
      main = "!git checkout main; git pull";
      pl = "pull";
      ps = "push";
    };

    extraConfig = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      "gpg \"ssh\"" = lib.mkIf isDesktop {
        program = opPath;
      };
      push.autoSetupRemote = true;
      core.sshCommand = "ssh -o IdentityAgent=\"${opSockPath}\"";
    };

    difftastic = {
      enable = true;
      background = "dark";
    };
  };
}
