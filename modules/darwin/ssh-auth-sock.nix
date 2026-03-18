{...}: {
  launchd.agents.setSshAuthSock = {
    script = ''
      /bin/launchctl setenv SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
    serviceConfig = {
      RunAtLoad = true;
    };
  };
}
