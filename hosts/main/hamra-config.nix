# ═══════════════════════════════════════════════════════════════
# HAMRA-CONFIG.NIX — Valores desta máquina
# ═══════════════════════════════════════════════════════════════
# Gerado/sobrescrito por: sudo bash scripts/hamra-init.sh
# ═══════════════════════════════════════════════════════════════
{ lib, ... }:

{
  hamra = {
    userName = "nixos";
    full_name = "User";
    email_address = "user@example.com";
    system = {
      hostname = "nixos";
      timezone = "America/Sao_Paulo";
      locale   = "pt_BR.UTF-8";
      keymap   = "us";
    };
    gpu = "intel";
    boot = {
      loader = "grub";
      grub.device = "/dev/sda";
    };
    defaultSession = "hyprland";
    sessions.hyprland = true;
  };

  omarchy = {
    monitors = [ ];
    scale = 1;
  };
}
