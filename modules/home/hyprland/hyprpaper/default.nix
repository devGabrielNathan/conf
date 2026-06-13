{ config, ... }:

let
  selectedWallpaper = (import ../../../../lib/selected-wallpaper.nix config).wallpaper_path;
in {
  home.file."Pictures/Wallpapers" = { source = ../wallpapers; recursive = true; };

  services.hyprpaper = {
    enable = true;
    settings = { preload = [ selectedWallpaper ]; wallpaper = [ ",${selectedWallpaper}" ]; };
  };
}
