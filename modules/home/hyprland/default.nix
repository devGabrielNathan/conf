{ config, lib, pkgs, inputs, osConfig ? { }, ... }:

let
  cfg = osConfig.hyprland or { theme = "gruvbox"; };
  themes = import ./themes;
  isGenerated = cfg.theme == "generated_light" || cfg.theme == "generated_dark";
  selectedTheme =
    if isGenerated then null
    else if builtins.hasAttr cfg.theme themes then themes.${cfg.theme}
    else themes."catppuccin";
  generatedColorScheme =
    if isGenerated then
      (inputs.nix-colors.lib.contrib { inherit pkgs; }).colorSchemeFromPicture {
        path = cfg.theme_overrides.wallpaper_path or null;
        variant = if cfg.theme == "generated_light" then "light" else "dark";
      }
    else
      null;
  colorScheme =
    if isGenerated then generatedColorScheme
    else inputs.nix-colors.colorSchemes.${selectedTheme.base16-theme};
in
{
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

  config = lib.mkIf (osConfig.hamra.sessions.hyprland or false) {
    colorScheme = colorScheme;

    programs.neovim.enable = true;

    gtk = {
      enable = true;
      theme = {
        name = if cfg.theme == "generated_light" then "Adwaita" else "Adwaita:dark";
        package = pkgs.gnome-themes-extra;
      };
    };
  };
}
