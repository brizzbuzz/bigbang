{...}: {
  services.transmission = {
    enable = true;
    # TODO: Can open up for RPC access if I wanna get crazy
    settings = {
    };
  };
}
