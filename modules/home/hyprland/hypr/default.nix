{ config, lib, pkgs, inputs, osConfig ? { }, ... }:

let
  palette = config.colorScheme.palette;
  hexToRgba = hex: alpha: "rgba(${hex}${alpha})";
  inactiveBorder = hexToRgba palette.base09 "aa";
  activeBorder = hexToRgba palette.base0D "aa";
  cfg = osConfig.hyprland;
  hasNvidiaDrivers = builtins.elem "nvidia" osConfig.services.xserver.videoDrivers;
  nvidiaEnv = [
    "NVD_BACKEND,direct"
    "LIBVA_DRIVER_NAME,nvidia"
    "__GLX_VENDOR_LIBRARY_NAME,nvidia"
  ];
in {
  home.packages = with pkgs; [ hyprshot hyprpicker hyprsunset ];

  services.hyprpolkitagent.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      "$terminal"         = lib.mkDefault "ghostty";
      "$fileManager"      = lib.mkDefault "nautilus --new-window";
      "$browser"          = lib.mkDefault "chromium --new-window --ozone-platform=wayland";
      "$music"            = lib.mkDefault "spotify";
      "$passwordManager"  = lib.mkDefault "1password";
      "$messenger"        = lib.mkDefault "signal-desktop";
      "$webapp"           = lib.mkDefault "$browser --app";
      monitor             = cfg.monitors;

      env = (lib.optionals hasNvidiaDrivers nvidiaEnv) ++ [
        "GDK_SCALE,${toString cfg.scale}"

        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,Adwaita"
        "HYPRCURSOR_THEME,Adwaita"

        "GDK_BACKEND,wayland"
        "QT_QPA_PLATFORM,wayland"
        "QT_STYLE_OVERRIDE,kvantum"
        "SDL_VIDEODRIVER,wayland"
        "MOZ_ENABLE_WAYLAND,1"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "OZONE_PLATFORM,wayland"

        "CHROMIUM_FLAGS,\"--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4\""

        "XDG_DATA_DIRS,$XDG_DATA_DIRS:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share"
        "XCOMPOSEFILE,~/.XCompose"
        "EDITOR,nvim"

        "GTK_THEME,${if cfg.theme == "generated_light" then "Adwaita" else "Adwaita:dark"}"
      ];

      xwayland = { force_zero_scaling = true; };
      ecosystem = { no_update_news = true; };

      input = {
        kb_layout = "us"; kb_variant = "intl"; kb_options = "compose:caps";
        follow_mouse = 1; sensitivity = 0;
        touchpad = { natural_scroll = false; };
      };

      gestures = { workspace_swipe = false; };

      general = {
        gaps_in = 5; gaps_out = 10; border_size = 2;
        "col.active_border" = activeBorder;
        "col.inactive_border" = inactiveBorder;
        resize_on_border = false; allow_tearing = false; layout = "dwindle";
      };

      decoration = {
        rounding = 4;
        shadow = { enabled = false; range = 30; render_power = 3; ignore_window = true; color = "rgba(00000045)"; };
        blur = { enabled = true; size = 5; passes = 2; vibrancy = 0.1696; };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1" "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1" "almostLinear,0.5,0.5,0.75,1.0" "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default" "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear" "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick" "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade" "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear" "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 0, 0, ease"
        ];
      };

      dwindle = { pseudotile = true; preserve_split = true; force_split = 2; };
      master = { new_status = "master"; };
      misc = { disable_hyprland_logo = true; disable_splash_rendering = true; };

      windowrule = [
        "suppressevent maximize, class:.*"
        "tile, class:^(chromium|google-chrome|google-chrome-unstable)$"
        "float, class:^(org.pulseaudio.pavucontrol|blueman-manager)$"
        "float, class:^(steam)$"
        "fullscreen, class:^(com.libretro.RetroArch)$"
        "opacity 0.97 0.9, class:.*"
        "opacity 1 1, class:^(chromium|google-chrome|google-chrome-unstable)$, title:.*Youtube.*"
        "opacity 1 0.97, class:^(chromium|google-chrome|google-chrome-unstable)$"
        "opacity 0.97 0.9, initialClass:^(chrome-.*-Default)$"
        "opacity 1 1, initialClass:^(chrome-youtube.*-Default)$"
        "opacity 1 1, class:^(zoom|vlc|org.kde.kdenlive|com.obsproject.Studio)$"
        "opacity 1 1, class:^(com.libretro.RetroArch|steam)$"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        "float, class:(clipse)"
        "size 622 652, class:(clipse)"
        "stayfocused, class:(clipse)"
      ];
      layerrule = [ "blur,wofi" "blur,waybar" ];

      bind = cfg.quick_app_bindings ++ [
        "SUPER, space, exec, wofi --show drun --sort-order=alphabetical"
        "SUPER SHIFT, SPACE, exec, pkill -SIGUSR1 waybar"
        "SUPER, W, killactive," "SUPER, Backspace, killactive,"
        "SUPER, ESCAPE, exec, hyprlock" "SUPER SHIFT, ESCAPE, exit,"
        "SUPER CTRL, ESCAPE, exec, reboot"
        "SUPER SHIFT CTRL, ESCAPE, exec, systemctl poweroff"
        "SUPER, K, exec, ~/.local/share/hyprland/bin/hyprland-show-keybindings"
        "SUPER, J, togglesplit," "SUPER, P, pseudo,"
        "SUPER, V, togglefloating," "SUPER SHIFT, Plus, fullscreen,"
        "SUPER, left, movefocus, l" "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u" "SUPER, down, movefocus, d"
        "SUPER, 1, workspace, 1" "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3" "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5" "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7" "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9" "SUPER, 0, workspace, 10"
        "SUPER, comma, workspace, -1" "SUPER, period, workspace, +1"
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"
        "SUPER SHIFT, left, swapwindow, l"
        "SUPER SHIFT, right, swapwindow, r"
        "SUPER SHIFT, up, swapwindow, u"
        "SUPER SHIFT, down, swapwindow, d"
        "SUPER, minus, resizeactive, -100 0"
        "SUPER, equal, resizeactive, 100 0"
        "SUPER SHIFT, minus, resizeactive, 0 -100"
        "SUPER SHIFT, equal, resizeactive, 0 100"
        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"
        "SUPER, S, togglespecialworkspace, magic"
        "SUPER SHIFT, S, movetoworkspace, special:magic"
        ", PRINT, exec, hyprshot -m region"
        "SHIFT, PRINT, exec, hyprshot -m window"
        "CTRL, PRINT, exec, hyprshot -m output"
        "SUPER, PRINT, exec, hyprpicker -a"
        "CTRL SUPER, V, exec, ghostty --class clipse -e clipse"
      ];
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      exec-once = [
        "hyprsunset"
        "wl-clip-persist --clipboard regular & clipse -listen"
      ];
      exec = [ "pkill -SIGUSR2 waybar || waybar" ];
    };
  };
}
