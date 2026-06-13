config:
let
  cfg = config.hyprland;
  wallpapers = {
    "catppuccin" = [ "catppuccin-totoro.png" ];
    "everforest" = [ "everforest-tree-tops.jpg" ];
    "gruvbox" = [ "gruvbox-the-backwater.jpg" ];
    "gruvbox-light" = [ "gruvbox-the-backwater.jpg" ];
    "kanagawa" = [ "kanagawa-kanagawa.jpg" ];
    "nord" = [ "nord-black-moon.jpg" ];
    "tokyo-night" = [ "tokyo-night-swirl-buck.jpg" ];
  };
  isGenerated = cfg.theme == "generated_light" || cfg.theme == "generated_dark";
  wallpaper_path =
    if isGenerated || cfg.theme_overrides.wallpaper_path != null then
      toString cfg.theme_overrides.wallpaper_path
    else
      let selected_wallpaper = builtins.elemAt (wallpapers.${cfg.theme}) 0;
      in "~/Pictures/Wallpapers/${selected_wallpaper}";
in { inherit wallpaper_path; }
