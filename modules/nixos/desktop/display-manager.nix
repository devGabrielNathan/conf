# Configura display manager conforme hamra.session.
{ config, lib, ... }:

let
  cfg = config.hamra.session;
  defaultSession = config.hamra.defaultSession;
in
{
  services.displayManager = {
    sddm = lib.mkIf (cfg.displayManager == "sddm") {
      enable = true;
      wayland.enable = lib.mkDefault (cfg.compositor == "wayland");
      theme = lib.mkIf (cfg.sddmTheme != null) cfg.sddmTheme;
    };

    gdm = lib.mkIf (cfg.displayManager == "gdm") {
      enable = true;
      wayland = true;
    };

    defaultSession = lib.mkDefault (
      if      defaultSession == "hyprland" then "hyprland"
      else if defaultSession == "plasma"   then "plasma6"
      else    defaultSession
    );
  };
}
