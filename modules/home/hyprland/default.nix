{ config, lib, pkgs, inputs, ... }:

let
  themes = import ./themes.nix;
  isGenerated = config.omarchy.theme == "generated_light" || config.omarchy.theme == "generated_dark";
  selectedTheme =
    if isGenerated then null
    else if builtins.hasAttr config.omarchy.theme themes then themes.${config.omarchy.theme}
    else themes."catppuccin";
  generatedColorScheme =
    if isGenerated then
      (inputs.nix-colors.lib.contrib { inherit pkgs; }).colorSchemeFromPicture {
        path = config.omarchy.theme_overrides.wallpaper_path;
        variant = if config.omarchy.theme == "generated_light" then "light" else "dark";
      }
    else
      null;
  colorScheme =
    if isGenerated then generatedColorScheme
    else inputs.nix-colors.colorSchemes.${selectedTheme.base16-theme};
in
lib.mkIf config.hamra.sessions.hyprland {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    ./hypr
    ./waybar
    ./wofi
    ./mako
    ./ghostty
    ./hyprlock
    ./hyprpaper
    ./btop
    ./scripts
    ./vscode
  ];

  colorScheme = colorScheme;

  programs.neovim.enable = true;

  gtk = {
    enable = true;
    theme = {
      name = if config.omarchy.theme == "generated_light" then "Adwaita" else "Adwaita:dark";
      package = pkgs.gnome-themes-extra;
    };
  };
}
