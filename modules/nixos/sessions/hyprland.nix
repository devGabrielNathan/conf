{ config, lib, pkgs, ... }:

let
  cfg = config.hamra;
in
lib.mkIf cfg.sessions.hyprland {
  hamra.session = {
    displayManager = lib.mkDefault "sddm";
    compositor     = lib.mkDefault "wayland";
    portals        = lib.mkDefault "gtk";
    audio          = lib.mkDefault "pipewire";
    fonts          = lib.mkDefault "nerd";
    env = {
      editor   = lib.mkDefault "nvim";
      browser  = lib.mkDefault "firefox";
      terminal = lib.mkDefault "kitty";
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.dconf.enable = true;

  users.users.${cfg.userName}.shell = pkgs.zsh;
}
