{
  lib,
  osConfig,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "Ryan Brink";
    userEmail = "dev@ryanbr.ink";

    difftastic = {
      enable = true;
      background = "dark";
    };

    aliases = {
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

    extraConfig = {
      commit = {
        gpgsign = true;
      };
      diff = {
        tool = "difftastic";
      };
      difftool = {
        prompt = false;
      };
      "difftool \"difftastic\"" = {
        cmd = "difft \"$LOCAL\" \"$REMOTE\"";
      };
      init = {
        defaultBranch = "main";
      };
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = lib.mkIf osConfig.host.desktop.enable {
        program = "/run/current-system/sw/bin/op-ssh-sign";
      };
      push = {
        autoSetupRemote = true;
      };
      user = {
        signingKey = osConfig.host.gitSigningKey;
      };
    };
  };

  programs.git-cliff = {
    enable = true;
  };
}
