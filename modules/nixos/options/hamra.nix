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
      default = "gabrielnathan";
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
        description = "Mapa de teclado para o console e X11 (ex: us, br).";
      };
      xkbVariant = lib.mkOption {
        type = lib.types.str;
        default = "intl";
        description = "Variante XKB do teclado (ex: intl, abnt2). Vazio = sem variante.";
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
      default = "intel";
      description = ''
        GPU do sistema. Configura drivers automaticamente via modules/nixos/core/gpu.nix.
        Valores aceitos: amd, nvidia, intel, none.
      '';
    };

    # ═══════════════════════════════════════════
    # SESSÕES
    # ═══════════════════════════════════════════
    sessions = {
      plasma           = lib.mkEnableOption "KDE Plasma 6 Desktop Environment";
      gnome            = lib.mkEnableOption "GNOME Desktop Environment";
      hyprland         = lib.mkEnableOption "Hyprland Wayland compositor";
    };

    defaultSession = lib.mkOption {
      type = lib.types.enum [ "plasma" "gnome" "hyprland" ];
      default = "hyprland";
      description = "Sessão padrão exibida pelo SDDM.";
    };

    # ═══════════════════════════════════════════
    # SESSION CONFIG — defaults reativos
    # ═══════════════════════════════════════════
    # Cada módulo em modules/nixos/desktop/ reage
    # a estas opções. A sessão só as preenche.
    # ═══════════════════════════════════════════
    session = {
      displayManager = lib.mkOption {
        type = lib.types.enum [ "sddm" "gdm" ];
        default = "sddm";
        description = "Gerenciador de login da sessão.";
      };
      sddmTheme = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Tema do SDDM (null = padrão do sistema). Ex: silent.";
      };

      compositor = lib.mkOption {
        type = lib.types.enum [ "x11" "wayland" ];
        default = "x11";
        description = "Compositor da sessão (X11 ou Wayland).";
      };
      audio = lib.mkOption {
        type = lib.types.enum [ "pipewire" "pulseaudio" "none" ];
        default = "pipewire";
        description = "Sistema de áudio da sessão.";
      };
      portals = lib.mkOption {
        type = lib.types.enum [ "none" "gtk" "kde" ];
        default = "none";
        description = "Portais XDG da sessão (none, gtk ou kde).";
      };
      printing = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Habilitar impressão (CUPS).";
      };
      fonts = lib.mkOption {
        type = lib.types.enum [ "default" "nerd" ];
        default = "default";
        description = "Conjunto de fontes: default (Noto + Liberation) ou nerd (+ JetBrainsMono Nerd Font).";
      };
      env = {
        editor = lib.mkOption {
          type = lib.types.str;
          default = "nvim";
          description = "Editor padrão ($EDITOR).";
        };
        browser = lib.mkOption {
          type = lib.types.str;
          default = "firefox";
          description = "Navegador padrão ($BROWSER).";
        };
        terminal = lib.mkOption {
          type = lib.types.str;
          default = "kitty";
          description = "Terminal padrão ($TERMINAL).";
        };
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
