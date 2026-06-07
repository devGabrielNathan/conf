# Configura o emulador de terminal padrão do usuário: Kitty com tema e fonte.
{ pkgs, ... }: {
  home-manager.sharedModules = [{
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 13;
      };
      settings = {
        scrollback_lines     = 10000;
        enable_audio_bell    = false;
        update_check_interval = 0;
        confirm_os_window_close = 0;
        background_opacity   = "0.95";
      };
    };
  }];
}
