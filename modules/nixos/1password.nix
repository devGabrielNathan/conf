{ config, ... }:
{
  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
    _1password-gui.polkitPolicyOwners = [ config.hamra.userName ];
  };
}
