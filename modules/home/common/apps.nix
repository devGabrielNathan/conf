# ═══════════════════════════════════════════════════════════════
# APPS — pacotes do usuário disponíveis em todas as sessões
# ═══════════════════════════════════════════════════════════════
# Adicione pacotes extras em hosts/main/overrides.nix.
{ pkgs, lib, ... }:
{
  home-manager.sharedModules = [{
    home.packages = with pkgs; [
      git
      neovim
      firefox
      kitty
      btop
      fastfetch
    ];

    programs.firefox.enable = lib.mkDefault true;
  }];
}
