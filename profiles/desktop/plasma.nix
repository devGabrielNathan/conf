# ═══════════════════════════════════════════════════════════════
# PERFIL PLASMA — receita completa do KDE Plasma
# ═══════════════════════════════════════════════════════════════
{ config, ... }:
{
  imports = [
    ../base.nix
    ./common.nix
    ../../modules/nixos/sessions/plasma.nix
  ];

  home-manager.users.${config.hamra.userName}.imports = [
    ../../modules/home/common/terminal.nix
  ];
}
