{ lib, ... }:
{
  options.omarchy = {
    theme = lib.mkOption {
      type = lib.types.either (lib.types.enum [
        "catppuccin" "everforest"
        "gruvbox" "gruvbox-light"
        "kanagawa" "nord"
        "tokyo-night"
        "generated_light" "generated_dark"
      ]) lib.types.str;
      default = "gruvbox";
      description = "Tema Hyprland (base16 ou generated).";
    };

    theme_overrides = lib.mkOption {
      type = lib.types.submodule {
        options = {
          wallpaper_path = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Caminho do wallpaper para extrair cores (themes generated_*).";
          };
        };
      };
      default = { };
      description = "Overrides de tema (wallpaper path para temas generated).";
    };

    wallpaper_path = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Caminho para wallpaper personalizado. Null usa o wallpaper padrão do tema.";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Configuração de monitores (ex: [ \"DP-1,2560x1440@144,0x0,1\" ]).";
    };

    scale = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "Fator de escala da interface (1 = 1x, 2 = 2x).";
    };

    primary_font = lib.mkOption {
      type = lib.types.str;
      default = "CaskaydiaMono Nerd Font";
      description = "Fonte principal do sistema (formato: nome tamanho).";
    };

    vscode_settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Configurações extras do VSCode.";
    };

    quick_app_bindings = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "SUPER, A, exec, $webapp=https://chatgpt.com"
        "SUPER SHIFT, A, exec, $webapp=https://grok.com"
        "SUPER, C, exec, $webapp=https://app.hey.com/calendar/weeks/"
        "SUPER, E, exec, $webapp=https://app.hey.com"
        "SUPER, Y, exec, $webapp=https://youtube.com/"
        "SUPER SHIFT, G, exec, $webapp=https://web.whatsapp.com/"
        "SUPER, X, exec, $webapp=https://x.com/"
        "SUPER SHIFT, X, exec, $webapp=https://x.com/compose/post"
        "SUPER, return, exec, $terminal"
        "SUPER, F, exec, $fileManager"
        "SUPER, B, exec, $browser"
        "SUPER, M, exec, $music"
        "SUPER, N, exec, $terminal -e nvim"
        "SUPER, T, exec, $terminal -e btop"
        "SUPER, D, exec, $terminal -e lazydocker"
        "SUPER, G, exec, $messenger"
        "SUPER, O, exec, obsidian -disable-gpu"
        "SUPER, slash, exec, $passwordManager"
      ];
      description = "Atalhos de teclado para apps comuns.";
    };

    exclude_packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Pacotes a excluir da lista padrão.";
    };
  };
}
