# ═══════════════════════════════════════════════════════════════
# HAMRA.NIX — Configuração específica desta máquina
# ═══════════════════════════════════════════════════════════════
# Lê os dados de hosts/main/hamra.json (gerado pelo wizard)
# e mapeia para as opções do framework.
#
# Se hamra.json não existir, usa os defaults do módulo options.
#
# Não edite este arquivo manualmente para valores de configuração.
# Use overrides.nix para customizações.
# ═══════════════════════════════════════════════════════════════
{ lib, ... }:

let
  cfgPath = ./hamra.json;
  hasConfig = builtins.pathExists cfgPath;
  cfg = if hasConfig then builtins.fromJSON (builtins.readFile cfgPath) else {};
  has = key: builtins.hasAttr key cfg;
in
{
  hamra = lib.mkMerge [
    (lib.mkIf (has "userName") { userName = cfg.userName; })
    (lib.mkIf (has "hostname") { system.hostname = cfg.hostname; })
    (lib.mkIf (has "timezone") { system.timezone = cfg.timezone; })
    (lib.mkIf (has "locale")   { system.locale = cfg.locale; })
    (lib.mkIf (has "keymap")   { system.keymap = cfg.keymap; })
    (lib.mkIf (has "gpu")      { gpu = cfg.gpu; })
    (lib.mkIf (has "loader")   {
      boot = {
        loader = cfg.loader;
        grub.device = if has "grubDevice" then cfg.grubDevice else "/dev/sda";
      };
    })
    (lib.mkIf (has "session")  {
      defaultSession = cfg.session;
      sessions.${cfg.session} = true;
    })
  ];
}
