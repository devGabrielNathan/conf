{ config, lib, ... }:
{
  imports = [
    ../base.nix
    ./common.nix
    ../../modules/nixos/sessions/hyprland.nix
  ];

  home-manager.users.${config.hamra.userName}.imports = [
    ../../modules/home/caelestia/default.nix
  ];
}
