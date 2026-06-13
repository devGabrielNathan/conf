# Fontes do sistema: pacotes + fontconfig, conforme hamra.session.fonts.
{ pkgs, config, lib, ... }:

let
  cfg  = config.hamra.session.fonts;
  nerd = cfg.packages == "nerd";
in
{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      liberation_ttf
    ] ++ lib.optionals nerd [
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-mono
    ];

    fontconfig.defaultFonts = {
      serif     = [ cfg.serif ];
      sansSerif = [ cfg.sansSerif ];
      monospace = [ cfg.monospace ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };
}
