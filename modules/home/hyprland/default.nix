{ config, lib, pkgs, ... }:

let
  cfg = config.hamra;
in
lib.mkIf cfg.sessions.hyprland {
  home.packages = with pkgs; [
    # Barra de status
    waybar

    # Notificacoes
    mako

    # Launcher
    walker

    # Wallpaper
    swaybg

    # Captura de tela
    grim
    slurp
    wl-clipboard

    # Utilitarios Wayland
    swayosd
    hypridle
    hyprlock
  ];

  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland compositor session";
      Documentation = "man:hyprctl(1)";
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
  };
}
