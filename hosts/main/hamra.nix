# ═══════════════════════════════════════════════════════════════
# HAMRA.NIX — configuração específica desta máquina
# ═══════════════════════════════════════════════════════════════
# Gerado por: scripts/hamra-init.sh
# Pode ser editado manualmente após a geração.
#
# Este arquivo NÃO deve ser modificado pelos módulos do framework.
# Para regenerar: bash scripts/hamra-init.sh
# ═══════════════════════════════════════════════════════════════
{ lib, ... }:
{
  hamra = {
    # ── Identidade ─────────────────────────────────────────────
    userName = "gabrielndsp";

    # ── Sistema ────────────────────────────────────────────────
    system = {
      hostname = "workstation";
      timezone = "America/Sao_Paulo";
      locale   = "pt_BR.UTF-8";
      keymap   = "us-acentos";
    };

    # ── Boot ───────────────────────────────────────────────────
    boot = {
      loader = "grub";           # ou "systemd-boot" para UEFI
      grub.device = "/dev/sda";  # ignorado se loader = "systemd-boot"
    };

    # ── GPU ────────────────────────────────────────────────────
    gpu = "intel";                 # amd | nvidia | intel | none

    # ── Sessão ─────────────────────────────────────────────────
    sessions.hyprland-caelestia = true;
    defaultSession              = "hyprland-caelestia";

    # ── Manutenção ─────────────────────────────────────────────
    maintenance.gc = {
      enable          = true;
      maxGenerations  = 10;
      schedule        = "weekly";
      keepDays        = 30;
    };
  };
}
