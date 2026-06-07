# ═══════════════════════════════════════════════════════════════
# PERFIL DESKTOP COMUM — display manager + home-manager base
# ═══════════════════════════════════════════════════════════════
# Importado por todos os perfis de desktop (niri, hyprland, etc.)
# antes dos módulos de sessão específicos.
#
# Inclui:
#   - SDDM + variáveis de ambiente Wayland
#   - Módulos home-manager comuns (shell, git, terminal, apps)
# ═══════════════════════════════════════════════════════════════
{ ... }:
{
  imports = [
    # Sistema: display manager e Wayland
    ../../modules/nixos/desktop/display-manager.nix
    ../../modules/nixos/desktop/wayland.nix

    # Home Manager: configuração comum do usuário
    ../../modules/home/common/git.nix
    ../../modules/home/common/shell.nix
    ../../modules/home/common/terminal.nix
    ../../modules/home/common/apps.nix
  ];
}
