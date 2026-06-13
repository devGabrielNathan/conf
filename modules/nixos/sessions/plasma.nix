{ config, lib, ... }:

let
  cfg = config.hamra;
in
lib.mkIf cfg.sessions.plasma {
  imports = [
    ../../desktop/audio.nix
    ../../desktop/display-manager.nix
    ../../desktop/env.nix
    ../../desktop/fonts.nix
    ../../desktop/gtk.nix
    ../../desktop/portals.nix
    ../../desktop/polkit.nix
    ../../desktop/printing.nix
  ];

  hamra.session = {
    displayManager = lib.mkDefault "sddm";
    compositor     = lib.mkDefault "wayland";
    portals        = lib.mkDefault "kde";
    fonts = {
      packages  = lib.mkDefault "default";
      serif     = lib.mkDefault "Liberation Serif";
      sansSerif = lib.mkDefault "Liberation Sans";
      monospace = lib.mkDefault "Liberation Mono";
    };
    env = {
      editor   = lib.mkDefault "nvim";
      browser  = lib.mkDefault "firefox";
      terminal = lib.mkDefault "konsole";
    };
  };

  services.desktopManager.plasma6.enable = true;
}
