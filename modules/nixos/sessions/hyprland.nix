{ config, lib, pkgs, ... }:

let
  cfg = config.hamra;
  packages = import ../../home/hyprland/packages { inherit pkgs lib; exclude_packages = config.hyprland.exclude_packages; };
in
{
  imports = [
    ../desktop/audio.nix
    ../desktop/display-manager.nix
    ../desktop/env.nix
    ../desktop/fonts.nix
    ../desktop/gtk.nix
    ../desktop/portals.nix
    ../desktop/polkit.nix
    ../services/1password.nix
  ];

  config = lib.mkIf cfg.sessions.hyprland {
    hamra.session = {
      displayManager = lib.mkDefault "sddm";
      compositor     = lib.mkDefault "wayland";
      portals        = lib.mkDefault "gtk";
      audio          = lib.mkDefault "pipewire";
      fonts = {
        packages  = lib.mkDefault "nerd";
        monospace = lib.mkDefault "Caskaydia Mono Nerd Font";
      };
      env = {
        editor   = lib.mkDefault "nvim";
        browser  = lib.mkDefault "chromium";
        terminal = lib.mkDefault "ghostty";
      };
    };

    programs.hyprland.enable = true;

    environment.systemPackages = packages.systemPackages;
  };
}