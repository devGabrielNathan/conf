# ═══════════════════════════════════════════════════════════════
# PERFIL GNOME — receita completa do GNOME
# ═══════════════════════════════════════════════════════════════
{ ... }:
{
  imports = [
    ../base.nix
    ./common.nix
    ../../modules/nixos/sessions/gnome.nix
  ];
}
