# ═══════════════════════════════════════════════════════════════
# HAMRA.NIX — Configuração específica desta máquina
# ═══════════════════════════════════════════════════════════════
# Importa o arquivo gerado pelo wizard (hamra-config.nix).
# Se quiser valores manuais, edite overrides.nix em vez deste.
# ═══════════════════════════════════════════════════════════════
{ lib, ... }:

{
  imports = [
    ./hamra-config.nix
  ];
}
