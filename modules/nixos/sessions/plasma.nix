# Habilita KDE Plasma 6 no sistema.
{ config, lib, ... }:

let
  cfg = config.hamra;
in
{
  services = lib.mkIf cfg.sessions.plasma {
    desktopManager.plasma6.enable = true;
  };
}
