# ═══════════════════════════════════════════════════════════════
# PERFIL DESKTOP COMUM — módulos compartilhados entre sessões
# ═══════════════════════════════════════════════════════════════
# Importado por todos os perfis de desktop antes dos módulos
# específicos de cada sessão.
{ config, ... }:
{
  imports = [
    ../../modules/home/common/git.nix
    ../../modules/home/common/shell.nix
    ../../modules/home/common/apps.nix
  ];

  home-manager.users.${config.hamra.userName} = {
    programs.git = {
      userName = config.hamra.full_name;
      userEmail = config.hamra.email_address;
    };
  };
}
