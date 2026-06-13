# ═══════════════════════════════════════════════════════════════
# PERFIL GNOME — receita completa do GNOME
# ═══════════════════════════════════════════════════════════════
{ config, ... }:
{
  imports = [
    ../base.nix
    ./common.nix
    ../../modules/nixos/sessions/gnome.nix
  ];

  home-manager.users.${config.hamra.userName}.imports = [
    ../../modules/home/common/terminal.nix
  ];
}
