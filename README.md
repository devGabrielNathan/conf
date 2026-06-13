# hamra

Configuração NixOS modular focada em Hyprland, com suporte a GNOME e Plasma como sessões secundárias.

## Sessões disponíveis

| Sessão | WM / DE | DM |
|--------|---------|----|
| Hyprland | Hyprland (Wayland) | SDDM |
| KDE Plasma 6 | KWin (Wayland) | SDDM |
| GNOME | Mutter (Wayland) | GDM |

---

## Início rápido

> [!IMPORTANT]
> Em instaladores mínimos sem `git`, entre em um shell temporário antes de clonar:
> ```bash
> nix-shell -p git gum
> ```
>
> O wizard usa [`gum`](https://github.com/charmbracelet/gum) para uma experiência interativa. Se não estiver disponível, funciona com entrada de texto padrão.

> [!WARNING]
> **Sobre o `/etc/nixos` existente**: o script faz backup automático para `/etc/nixos.bak` e extrai dados como hostname, locale e partições antes de sobrescrever.

```bash
nix-shell -p git gum
git clone https://github.com/devGabrielNathan/hamra ~/hamra
cd ~/hamra
sudo bash scripts/hamra-init.sh
cd /etc/nixos
sudo nixos-rebuild switch --flake .#main
sudo reboot
```

---

## Trocando de sessão

A sessão padrão é Hyprland. Para mudar, edite `hosts/main/overrides.nix`:

```nix
{ config, pkgs, lib, ... }: {
  hamra = {
    sessions.gnome    = true;
    defaultSession    = "gnome";
  };
}
```

```bash
sudo nixos-rebuild switch --flake .#main
```

---

## Configuração

### Dados da máquina — `hosts/main/hamra-config.nix`

Gerado pelo `hamra-init.sh`, centraliza os valores da máquina:

```nix
{ lib, ... }: {
  hamra = {
    userName = "gabrielnathan";
    system = {
      hostname = "nixos";
      timezone = "America/Sao_Paulo";
      locale   = "pt_BR.UTF-8";
      keymap   = "us";
    };
    gpu = "intel";
    boot = {
      loader = "grub";
      grub.device = "/dev/sda";
    };
    defaultSession = "hyprland";
    sessions.hyprland = true;
  };
}
```

Para regenerar: `sudo bash scripts/hamra-init.sh`

### Personalizações — `hosts/main/overrides.nix`

Nunca alterado pelo wizard:

```nix
{ config, pkgs, lib, ... }: {
  hamra = {
    userName = "gabrielnathan";
    system.hostname = "workstation";
    gpu = "nvidia";
    sessions.plasma = true;
    defaultSession  = "plasma";
  };
  environment.systemPackages = with pkgs; [ vscode discord ];
}
```

### Temas

O Hyprland usa temas base16 via nix-colors. O tema padrão é `gruvbox`. Disponível em `hyprland.theme`:

| Tema | base16 scheme |
|------|--------------|
| `gruvbox` (padrão) | gruvbox-dark-hard |
| `gruvbox-light` | gruvbox-light-medium |
| `tokyo-night` | tokyo-night-dark |
| `catppuccin` | catppuccin-macchiato |
| `everforest` | everforest |
| `nord` | nord |
| `kanagawa` | kanagawa |
| `generated_light` / `generated_dark` | extraído do wallpaper |

Temas sem base16 equivalente fazem fallback para catppuccin.

### Referência rápida

| O que fazer | Onde editar |
|-------------|-------------|
| Hostname, timezone, locale, teclado | `hosts/main/overrides.nix` ou `hosts/main/hamra-config.nix` |
| Driver de GPU | `overrides.nix` → `hamra.gpu` |
| Sessão ativa | `overrides.nix` → `hamra.sessions.*` |
| Sessão padrão | `overrides.nix` → `hamra.defaultSession` |
| Tema Hyprland | `overrides.nix` → `hyprland.theme` |
| Pacotes extras | `overrides.nix` |
| Apps para todas as sessões | `modules/home/common/apps.nix` |
| Serviços globais (docker, bluetooth, etc.) | `modules/nixos/core/users.nix` |
| SDDM / tema do login | `modules/nixos/desktop/display-manager.nix` |
| Fontes | `modules/nixos/desktop/fonts.nix` |
| Áudio | `modules/nixos/desktop/audio.nix` |

---

## Estrutura

```
hamra/
├── flake.nix
├── hosts/main/
│   ├── default.nix
│   ├── hamra.nix                  # Importa hamra-config.nix → opções hamra.*
│   ├── hamra-config.nix           # Gerado pelo wizard
│   ├── hardware-configuration.nix # Gerado por nixos-generate-config
│   └── overrides.nix              # Suas customizações (nunca sobrescrito)
├── profiles/
│   ├── base.nix
│   └── desktop/
│       ├── common.nix
│       ├── hyprland.nix
│       ├── gnome.nix
│       └── plasma.nix
├── modules/
│   ├── nixos/
│   │   ├── options/
│   │   │   ├── hamra.nix
│   │   │   └── hyprland.nix
│   │   ├── core/       (boot, locale, network, keyboard, users, security, gpu)
│   │   ├── desktop/    (audio, dm, env, fonts, gtk, polkit, portals, printing)
│   │   ├── sessions/   (hyprland, gnome, plasma)
│   │   ├── services/   (1password)
│   │   └── maintenance/gc.nix
│   └── home/
│       ├── common/     (shell, git, apps)
│       └── hyprland/   (hypr, waybar, wofi, mako, ghostty, hyprlock, hyprpaper, btop, vscode)
├── lib/
│   ├── default.nix
│   ├── mkSpecialisation.nix
│   └── selected-wallpaper.nix
├── scripts/
│   ├── hamra-init.sh               # Orquestrador (4 fases)
│   └── lib/
│       ├── log.sh                  # Logging com suporte a gum
│       ├── setup.sh                # Prepara /etc/nixos + git
│       ├── detect.sh               # Descobre config existente + GPU + hardware
│       ├── wizard.sh               # Assistente interativo
│       └── generate.sh             # Gera hamra-config.nix + define senha
└── docs/
```

---

## Documentação

- [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md)
- [`docs/ADRs.md`](docs/ADRs.md)
- [`docs/PRD.md`](docs/PRD.md)
- [`docs/REQUISITOS.md`](docs/REQUISITOS.md)
- [`docs/USER_STORIES.md`](docs/USER_STORIES.md)
- [`docs/STYLE_GUIDE.md`](docs/STYLE_GUIDE.md)
- [`docs/GUIA_IA.md`](docs/GUIA_IA.md)
