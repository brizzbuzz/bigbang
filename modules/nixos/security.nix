{...}: {
  security.sudo.wheelNeedsPassword = false;

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };
}
