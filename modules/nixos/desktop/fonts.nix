# Instala e configura fontes do sistema: Nerd Fonts, Noto, Liberation e Emoji.
{ pkgs, ... }: {
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
    ];

    fontconfig.defaultFonts = {
      serif      = [ "Liberation Serif" "Noto Serif" ];
      sansSerif  = [ "Liberation Sans"  "Noto Sans"  ];
      monospace  = [ "JetBrainsMono Nerd Font" "FiraCode Nerd Font" ];
      emoji      = [ "Noto Color Emoji" ];
    };
  };
}
