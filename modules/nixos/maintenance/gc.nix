# Configura garbage collection automático e otimização do Nix store.
# Limita gerações no bootloader via hamra.maintenance.gc.maxGenerations.
{ config, lib, ... }:

let
  cfg = config.hamra.maintenance.gc;
in
lib.mkIf cfg.enable {
  # GC automático do store
  nix.gc = {
    automatic = true;
    dates     = cfg.schedule;
    options   = "--delete-older-than ${toString cfg.keepDays}d";
  };

  # Otimização do store (hard-links entre arquivos idênticos)
  nix.optimise = {
    automatic = true;
    dates     = [ cfg.schedule ];
  };

  # Features experimentais necessárias para Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
