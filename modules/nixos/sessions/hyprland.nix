{ config, lib, pkgs, ... }:

let
  cfg = config.hamra;
  packages = import ../../../home/hyprland/packages.nix { inherit pkgs lib; exclude_packages = config.omarchy.exclude_packages; };
in
lib.mkIf cfg.sessions.hyprland {
  imports = [
    ../../desktop/audio.nix
    ../../desktop/display-manager.nix
    ../../desktop/env.nix
    ../../desktop/fonts.nix
    ../../desktop/gtk.nix
    ../../desktop/portals.nix
    ../../1password.nix
  ];

  hamra.session = {
    displayManager = lib.mkDefault "sddm";
    compositor     = lib.mkDefault "wayland";
    portals        = lib.mkDefault "gtk";
    audio          = lib.mkDefault "pipewire";
    fonts = {
      packages  = lib.mkDefault "nerd";
      monospace = lib.mkDefault "Caskaydia Mono Nerd Font";
    };
    env = {
      editor   = lib.mkDefault "nvim";
      browser  = lib.mkDefault "chromium";
      terminal = lib.mkDefault "ghostty";
    };
  };

  programs.hyprland.enable = true;
  programs.dconf.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  programs.direnv.enable = true;
  services.resolved.enable = true;

  virtualisation.containers.enable = true;
  virtualisation.docker.enable = true;

  environment.systemPackages = packages.systemPackages;

  users.users.${cfg.userName}.shell = pkgs.zsh;
}
