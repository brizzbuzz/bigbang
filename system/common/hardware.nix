{...}: {
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    keyboard = {
      zsa.enable = true; # TODO: Maybe want this to be conditional?
    };
    # TODO: what is this
    opengl = {
      enable = true;
      driSupport = true;
      # driSupport32bit = true;
    };
  };
}
