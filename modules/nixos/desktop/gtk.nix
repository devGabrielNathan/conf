{ config, lib, pkgs, ... }:
{
  home-manager.users.${config.hamra.userName} = {
    gtk = {
      enable = lib.mkDefault true;
      theme = {
        name = lib.mkDefault "Adwaita:dark";
        package = lib.mkDefault pkgs.gnome-themes-extra;
      };
      cursorTheme = {
        package = lib.mkDefault pkgs.adwaita-icon-theme;
        name    = lib.mkDefault "Adwaita";
        size    = lib.mkDefault 24;
      };
    };

    home.sessionVariables = {
      XCURSOR_SIZE     = "24";
      XCURSOR_THEME    = "Adwaita";
      HYPRCURSOR_SIZE  = "24";
      HYPRCURSOR_THEME = "Adwaita";
    };
  };
}
