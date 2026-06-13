{ config, lib, pkgs, ... }:

let
  cfg = config.hamra;
in
lib.mkIf cfg.sessions.gnome {
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
    displayManager = lib.mkDefault "gdm";
    compositor     = lib.mkDefault "wayland";
    portals        = lib.mkDefault "gtk";
    fonts = {
      packages  = lib.mkDefault "default";
      serif     = lib.mkDefault "Liberation Serif";
      sansSerif = lib.mkDefault "Liberation Sans";
      monospace = lib.mkDefault "Liberation Mono";
    };
    env = {
      editor   = lib.mkDefault "nvim";
      browser  = lib.mkDefault "epiphany";
      terminal = lib.mkDefault "gnome-terminal";
    };
  };

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnome-themes-extra
    adwaita-icon-theme
  ];
}
