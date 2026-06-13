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
    ../modules/nixos/options/hyprland.nix

    # Core: presente em qualquer NixOS
    ../modules/nixos/core/boot.nix
    ../modules/nixos/core/nix.nix
    ../modules/nixos/core/locale.nix
    ../modules/nixos/core/network.nix
    ../modules/nixos/core/keyboard.nix
    ../modules/nixos/core/users.nix
    ../modules/nixos/core/security.nix
    ../modules/nixos/core/gpu.nix

    # Manutenção
    ../modules/nixos/maintenance/gc.nix
  ];
}
