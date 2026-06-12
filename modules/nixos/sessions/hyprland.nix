{ config, lib, pkgs, ... }:

let
  cfg = config.hamra;
in
lib.mkIf cfg.sessions.hyprland-caelestia {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

  environment.systemPackages = with pkgs; [
    kitty
    libnotify
    grimblast
    brightnessctl
    playerctl
    swappy
    networkmanagerapplet
  ];
}
