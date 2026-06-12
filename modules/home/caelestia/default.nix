{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.hamra;
in
lib.mkIf cfg.sessions.hyprland-caelestia {
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
    inputs.hyprland.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    cli.enable = true;
    systemd.enable = true;

    settings = {
      general.apps = {
        terminal = [ "kitty" ];
        audio = [ "pavucontrol" ];
      };
      paths.wallpaperDir = "~/Pictures/Wallpapers";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    xwayland.enable = true;

    settings = {
      monitor = ",preferred,auto,1";

      exec-once = [
        "caelestia-shell"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "XDG_CURRENT_DESKTOP,Hyprland"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      windowrule = [
        "float, ^(pavucontrol)$"
        "float, ^(blueman-manager)$"
      ];

      bind = [
        "SUPER, Q, exec, kitty"
        "SUPER, C, killactive"
        "SUPER, M, exit"
        "SUPER, F, togglefloating"
        "SUPER, Space, exec, fuzzel"
        "SUPER, L, exec, loginctl lock-session"
        "SUPER, V, toggleorientation"
        "SUPER, R, exec, caelestia shell"
        "SUPER SHIFT, R, exec, caelestia shell launcher"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
}
