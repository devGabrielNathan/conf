# Instala pacotes comuns disponíveis em todas as sessões.
# Lista baseada em Hamra.md — apps do dia a dia do usuário.
# Para apps exclusivos de uma sessão, use modules/home/sessions/<nome>.nix.
{ pkgs, config, lib, ... }:

let
  cfg = config.hamra;
in
{
  home-manager.sharedModules = [{
    home.packages = with pkgs; [
      # ── Desenvolvimento ──────────────────────────────────────
      git
      helix                           # Editor modal moderno
      mise                            # Runtime version manager (node, python, etc.)
      lazygit                         # Git TUI
      lazydocker                      # Docker TUI

      # ── Terminal ─────────────────────────────────────────────
      fastfetch                       # System info
      btop                            # Monitor de recursos
      opencode                        # AI no terminal (nixpkgs unstable)

      # ── Banco de dados & API ──────────────────────────────────
      dbeaver-bin                     # SQL client universal
      postman                         # HTTP client

      # ── Browsers & Comunicação ────────────────────────────────
      firefox
      discord
      obs-studio                      # Screen recording / streaming

      # ── Mídia ────────────────────────────────────────────────
      spotify                         # unfree — ativo via allowUnfree
      vlc

      # ── Produtividade ─────────────────────────────────────────
      obsidian                        # unfree — notas pessoais

      # ── Dev IDE ──────────────────────────────────────────────
      vscode                          # unfree

      # ── Diagnóstico ──────────────────────────────────────────
      wireshark                       # Análise de rede
      camunda-modeler                 # BPMN modeling
    ];

    # Programas configurados via HM (não só instalados)
    programs.firefox.enable = lib.mkDefault true;
  }];
}
