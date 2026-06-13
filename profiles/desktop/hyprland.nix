{ config, ... }:
{
  imports = [
    ../base.nix
    ./common.nix
    ../../modules/nixos/sessions/hyprland.nix
  ];

  home-manager.users.${config.hamra.userName}.imports = [
    ../../modules/home/common/shell.nix
    ../../modules/home/common/terminal.nix
    ../../modules/home/hyprland/default.nix
  ];
}
