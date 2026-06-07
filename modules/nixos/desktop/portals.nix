# Configura XDG Desktop Portals para integração de aplicações Wayland e Flatpak.
{ pkgs, ... }: {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
