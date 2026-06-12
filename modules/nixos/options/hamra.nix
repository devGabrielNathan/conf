# ═══════════════════════════════════════════════════════════════
# OPÇÕES HAMRA — API pública do projeto
# ═══════════════════════════════════════════════════════════════
# Declara todas as opções hamra.* disponíveis no projeto.
# Este é o único arquivo que usa mkOption.
#
# Os valores padrões declarados aqui atuam como FALLBACKS caso
# o usuário não os configure explicitamente no `hamra.nix`.
# ═══════════════════════════════════════════════════════════════
{ lib, ... }:
{
  options.hamra = {

    # ═══════════════════════════════════════════
    # IDENTIDADE DO USUÁRIO (FALLBACK)
    # ═══════════════════════════════════════════
    userName = lib.mkOption {
      type = lib.types.str;
      default = "gabrielnathan"; # Fallback do criador do projeto
      description = "Nome do usuário principal do sistema.";
    };

    # ═══════════════════════════════════════════
    # SISTEMA (FALLBACKS)
    # ═══════════════════════════════════════════
    system = {
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "nixos";
        description = "Hostname da máquina.";
      };
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "America/Sao_Paulo";
        description = "Timezone do sistema.";
      };
      locale = lib.mkOption {
        type = lib.types.str;
        default = "pt_BR.UTF-8";
        description = "Locale padrão do sistema.";
      };
      keymap = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Mapa de teclado para o console (ex: us, br-abnt2).";
      };
    };

    # ═══════════════════════════════════════════
    # BOOT (FALLBACKS)
    # ═══════════════════════════════════════════
    boot = {
      loader = lib.mkOption {
        type = lib.types.enum [ "grub" "systemd-boot" ];
        default = "grub";
        description = "Tipo de bootloader. Use 'grub' para BIOS/MBR e 'systemd-boot' para UEFI.";
      };
      grub = {
        device = lib.mkOption {
          type = lib.types.str;
          default = "/dev/sda";
          description = "Dispositivo do GRUB (ex: /dev/sda). Ignorado se loader = 'systemd-boot'.";
        };
      };
    };

    # ═══════════════════════════════════════════
    # GPU (FALLBACK)
    # ═══════════════════════════════════════════
    gpu = lib.mkOption {
      type = lib.types.enum [ "amd" "nvidia" "intel" "none" ];
      default = "intel"; # Seu PC possui GPU Intel Iris Xe
      description = ''
        GPU do sistema. Configura drivers automaticamente via modules/nixos/desktop/gpu.nix.
        Valores aceitos: amd, nvidia, intel, none.
      '';
    };

    # ═══════════════════════════════════════════
    # SESSÕES
    # ═══════════════════════════════════════════
    sessions = {
      niri             = lib.mkEnableOption "Niri scrollable-tiling Wayland compositor";
      plasma           = lib.mkEnableOption "KDE Plasma 6 Desktop Environment";
      gnome            = lib.mkEnableOption "GNOME Desktop Environment";
      hyprland-caelestia = lib.mkEnableOption "Hyprland + Caelestia Shell desktop";
      recovery         = lib.mkEnableOption "Recovery mode (minimal, no DE)";
    };

    defaultSession = lib.mkOption {
      type = lib.types.enum [ "niri" "plasma" "gnome" "hyprland-caelestia" ];
      default = "niri";
      description = "Sessão padrão exibida pelo SDDM.";
    };

    # ═══════════════════════════════════════════
    # APLICATIVOS
    # ═══════════════════════════════════════════
    apps = {
      browser = lib.mkOption {
        type = lib.types.str;
        default = "firefox";
        description = "Navegador padrão.";
      };
      terminal = lib.mkOption {
        type = lib.types.str;
        default = "kitty";
        description = "Terminal padrão.";
      };
      editor = lib.mkOption {
        type = lib.types.str;
        default = "nvim";
        description = "Editor padrão.";
      };
      fileManager = lib.mkOption {
        type = lib.types.str;
        default = "nautilus";
        description = "Gerenciador de arquivos padrão.";
      };
      launcher = lib.mkOption {
        type = lib.types.str;
        default = "fuzzel";
        description = "App launcher padrão.";
      };
      audioControl = lib.mkOption {
        type = lib.types.str;
        default = "pavucontrol";
        description = "Controle de volume padrão.";
      };
      mediaControl = lib.mkOption {
        type = lib.types.str;
        default = "playerctl";
        description = "Controle de mídia padrão.";
      };
      brightnessControl = lib.mkOption {
        type = lib.types.str;
        default = "brightnessctl";
        description = "Controle de brilho padrão.";
      };
    };

    # ═══════════════════════════════════════════
    # MANUTENÇÃO
    # ═══════════════════════════════════════════
    maintenance = {
      gc = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Habilitar garbage collection automático do Nix store.";
        };
        maxGenerations = lib.mkOption {
          type = lib.types.int;
          default = 10;
          description = "Número máximo de gerações mantidas no bootloader.";
        };
        schedule = lib.mkOption {
          type = lib.types.str;
          default = "weekly";
          description = "Frequência do GC automático (ex: daily, weekly).";
        };
        keepDays = lib.mkOption {
          type = lib.types.int;
          default = 30;
          description = "Manter gerações dos últimos N dias.";
        };
      };
    };

  };
}
