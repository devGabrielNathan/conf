# ═══════════════════════════════════════════════════════════════
# PERFIL BASE — importa módulos de sistema comuns a todos os hosts
# ═══════════════════════════════════════════════════════════════
# Contém apenas configuração de SISTEMA (nixos modules).
# Módulos de home-manager ficam em profiles/desktop/common.nix
# pois só fazem sentido em contexto de desktop com usuário.
# ═══════════════════════════════════════════════════════════════
{ ... }:
{
  imports = [
    # API pública — deve vir primeiro
    ../modules/nixos/options/hamra.nix

    # Core: configuração presente em qualquer NixOS
    ../modules/nixos/core/boot.nix
    ../modules/nixos/core/locale.nix
    ../modules/nixos/core/network.nix
    ../modules/nixos/core/keyboard.nix
    ../modules/nixos/core/users.nix
    ../modules/nixos/core/security.nix

    # Desktop: configuração específica de ambiente gráfico
    ../modules/nixos/desktop/apps.nix
    ../modules/nixos/desktop/audio.nix
    ../modules/nixos/desktop/fonts.nix
    ../modules/nixos/desktop/gpu.nix
    ../modules/nixos/desktop/polkit.nix
    ../modules/nixos/desktop/portals.nix

    # Manutenção: GC automático e otimização
    ../modules/nixos/maintenance/gc.nix
  ];
}
