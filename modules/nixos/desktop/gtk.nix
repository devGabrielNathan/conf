{ config, pkgs, ... }:
{
  home-manager.users.${config.hamra.userName} = {
    gtk = {
      enable = true;
      theme = { name = "Adwaita:dark"; package = pkgs.gnome-themes-extra; };
      cursorTheme = {
        package = pkgs.adwaita-icon-theme;
        name    = "Adwaita";
        size    = 24;
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
