# Variáveis de ambiente conforme hamra.session.env + compositor.
{ config, lib, ... }:

let
  env = config.hamra.session.env;
in
{
  environment.sessionVariables =
    { EDITOR   = env.editor;
      BROWSER  = env.browser;
      TERMINAL = env.terminal;
    }
    // lib.optionalAttrs (config.hamra.session.compositor == "wayland") {
      NIXOS_OZONE_WL    = "1";
      MOZ_ENABLE_WAYLAND = "1";
      GDK_BACKEND        = "wayland";
      QT_QPA_PLATFORM    = "wayland";
      SDL_VIDEODRIVER    = "wayland";
      OZONE_PLATFORM     = "wayland";
    };
}
