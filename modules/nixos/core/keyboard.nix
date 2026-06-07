# Configura o layout de teclado para console e sessões via hamra.system.keymap.
{ config, lib, ... }:

let
  cfg = config.hamra;
in
{
  console.keyMap = lib.mkDefault cfg.system.keymap;

  # Layout de teclado para SDDM e sessões Wayland (XKB)
  services.xserver.xkb = {
    layout  = lib.mkDefault "us";
    variant = lib.mkDefault "altgr-intl";
  };
}
