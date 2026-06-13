# ═══════════════════════════════════════════════════════════════
# PERFIL DESKTOP COMUM — módulos compartilhados entre sessões
# ═══════════════════════════════════════════════════════════════
# Importado por todos os perfis de desktop antes dos módulos
# específicos de cada sessão.
{ ... }:
{
  imports = [
    ../../modules/home/common/git.nix
    ../../modules/home/common/apps.nix
  ];
}
