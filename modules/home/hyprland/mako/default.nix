{ config, ... }:

let palette = config.colorScheme.palette; in {
  services.mako = {
    enable = true;
    borderRadius = 0;
    borderSize = 2;
    defaultTimeout = 5000;
    font = "CaskaydiaMono Nerd Font 10";
    backgroundColor = "#${palette.base00}";
    textColor = "#${palette.base05}";
    borderColor = "#${palette.base04}";
    progressColor = "over #${palette.base0D}";
    width = 420;
    height = 110;
    padding = "10";
    margin = "10";
    maxVisible = 5;
    sort = "-time";
    groupBy = "app-name";
    format = "<b>%s</b>\n%b";
    layer = "overlay";
    ignoreTimeout = false;
    actions = true;
    markup = true;
    extraConfig = ''
      [urgency=low]
      border-color=#${palette.base09}
      [urgency=normal]
      border-color=#${palette.base0D}
      [urgency=high]
      border-color=#${palette.base08}
      default-timeout=0
    '';
  };
}
