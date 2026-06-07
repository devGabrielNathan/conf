# Define os apps padrão do sistema via hamra.apps.*.
# Para sobrescrever, edite hosts/main/hamra.nix sem mkDefault.
{ lib, ... }:
{
  hamra.apps.browser           = lib.mkDefault "firefox";
  hamra.apps.terminal          = lib.mkDefault "kitty";
  hamra.apps.editor            = lib.mkDefault "nvim";
  hamra.apps.fileManager       = lib.mkDefault "nautilus";
  hamra.apps.launcher          = lib.mkDefault "fuzzel";
  hamra.apps.audioControl      = lib.mkDefault "pavucontrol";
  hamra.apps.mediaControl      = lib.mkDefault "playerctl";
  hamra.apps.brightnessControl = lib.mkDefault "brightnessctl";
}
