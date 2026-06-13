{ config, ... }:

let
  palette = config.colorScheme.palette;
  selectedWallpaperPath = (import ../../../../lib/selected-wallpaper.nix config).wallpaper_path;
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        no_fade_in = false;
      };
      auth = {
        fingerprint.enabled = true;
      };
      background = {
        monitor = "";
        path = selectedWallpaperPath;
      };
      input-field = {
        monitor = "";
        size = "600, 100";
        position = "0, 0";
        halign = "center";
        valign = "center";
        inner_color = "rgb(${palette.base02})";
        outer_color = "rgb(${palette.base05})";
        outline_thickness = 4;
        font_family = "CaskaydiaMono Nerd Font";
        font_size = 32;
        font_color = "rgb(${palette.base05})";
        placeholder_color = "rgb(${palette.base04})";
        placeholder_text = "Password 󰈷";
        check_color = "rgba(131, 192, 146, 1.0)";
        fail_text = "Wrong";
        rounding = 0;
        shadow_passes = 0;
        fade_on_empty = false;
      };
      label = {
        monitor = "";
        text = "$FPRINTPROMPT";
        text_align = "center";
        color = "rgb(${palette.base05})";
        font_size = 24;
        font_family = "CaskaydiaMono Nerd Font";
        position = "0, -100";
        halign = "center";
        valign = "center";
      };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300; on-timeout = "loginctl lock-session"; }
        { timeout = 330; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on && brightnessctl -r"; }
      ];
    };
  };
}
