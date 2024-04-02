{...}: {
  # This would make more sense managed by home manager, but, I was having config issues :/
  # Plus this way I get polkit integration out of the box
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = ["ryan"];
  programs._1password.enable = true;
}
