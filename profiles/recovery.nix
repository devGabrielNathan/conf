# ═══════════════════════════════════════════════════════════════
# PERFIL RECOVERY — ambiente mínimo sem DE
# ═══════════════════════════════════════════════════════════════
# Usado pela specialisation "recovery" em hosts/main/default.nix.
# Garante que o sistema sempre tem uma saída funcional mesmo que
# todas as sessões gráficas falhem.
# ═══════════════════════════════════════════════════════════════
{ pkgs, lib, ... }:
{
  # Sem display manager na recovery
  services.displayManager.sddm.enable = lib.mkForce false;

  # Sem Home Manager na recovery (mais simples, mais resiliente)
  home-manager.users = lib.mkForce {};

  # Ferramentas essenciais de diagnóstico e recuperação
  environment.systemPackages = with pkgs; [
    git
    vim
    nano
    nixos-rebuild
    parted
    gptfdisk
    curl
    wget
    htop
    lsof
    pciutils
    usbutils
    rsync
  ];

  # Mensagem de boas-vindas na recovery
  environment.etc."motd".text = ''

    ╔══════════════════════════════════════════╗
    ║         HAMRA — RECOVERY MODE           ║
    ╠══════════════════════════════════════════╣
    ║  Sessão gráfica desabilitada.           ║
    ║  Use nixos-rebuild para restaurar.      ║
    ╚══════════════════════════════════════════╝

  '';
}
