# Arquitetura e Estrutura de Módulos
## hamra

**Versão:** 4.0  
**Data:** 2026-06  

---

## 1. Visão Geral da Arquitetura

O `hamra` é organizado em **4 camadas** que se compõem verticalmente, do mais genérico ao mais específico.

```
┌─────────────────────────────────────────────────┐
│                    HOSTS                        │
│     (configuração específica por máquina)       │
│  hosts/main/default.nix + hardware.nix          │
│  hosts/main/hamra.nix   (gerado por hamra-init) │
├─────────────────────────────────────────────────┤
│                   PROFILES                      │
│     (composições de módulos com defaults)       │
│  profiles/base.nix, profiles/desktop/*.nix      │
│  profiles/recovery.nix                          │
├─────────────────────────────────────────────────┤
│                   MODULES                       │
│     (lógica técnica com opções declarativas)    │
│  modules/nixos/core/**    — sistema             │
│  modules/nixos/desktop/** — desktop gráfico     │
│  modules/nixos/sessions/**— WM/DE               │
│  modules/nixos/maintenance/** — GC/otimização   │
│  modules/home/**          — usuário             │
├─────────────────────────────────────────────────┤
│                     LIB                         │
│        (helpers e funções auxiliares)           │
│  lib/mkSpecialisation.nix                       │
└─────────────────────────────────────────────────┘
```

---

## 2. Estrutura de Pastas Completa

```
hamra/
├── flake.nix                        # Entrypoint: inputs, outputs, devShells
├── flake.lock                       # Versões fixadas
│
├── lib/
│   ├── default.nix                  # Re-exporta helpers
│   └── mkSpecialisation.nix         # Helper para criar sessões
│
├── hosts/
│   └── main/
│       ├── default.nix              # Imports, specialisations, Home Manager
│       ├── hardware-configuration.nix  # Gerado por nixos-generate-config
│       └── hamra.nix                # Gerado por hamra-init — valores do usuário
│
├── profiles/
│   ├── base.nix                     # Importa todos os módulos comuns (sem sessão)
│   ├── recovery.nix                 # Ambiente mínimo sem DE para recuperação
│   └── desktop/
│       ├── common.nix               # SDDM + variáveis Wayland (compartilhado)
│       ├── niri.nix                 # Perfil Niri completo
│       └── hyprland.nix             # Perfil Hyprland completo
│
├── modules/
│   ├── nixos/
│   │   ├── options/
│   │   │   └── hamra.nix            # API pública: declara TODAS as opções hamra.*
│   │   ├── core/                    # Presente em qualquer NixOS (com ou sem DE)
│   │   │   ├── boot.nix             # Bootloader via hamra.boot.*
│   │   │   ├── locale.nix           # Timezone, locale via hamra.system.*
│   │   │   ├── network.nix          # Hostname, NetworkManager via hamra.system.*
│   │   │   ├── keyboard.nix         # Layout de teclado via hamra.system.keymap
│   │   │   ├── users.nix            # Usuário via hamra.userName
│   │   │   ├── security.nix         # sudo, polkit base
│   │   │   ├── apps.nix             # Defaults de hamra.apps.*
│   │   │   └── keybinds.nix         # Defaults de hamra.keybinds.*
│   │   ├── desktop/                 # Específico de ambiente gráfico
│   │   │   ├── audio.nix            # PipeWire + CUPS + allowUnfree
│   │   │   ├── display-manager.nix  # SDDM com tema astronaut
│   │   │   ├── fonts.nix            # Nerd Fonts, Noto, Liberation
│   │   │   ├── gpu.nix              # Drivers AMD/NVIDIA/Intel via hamra.gpu
│   │   │   ├── polkit.nix           # Agente gráfico polkit
│   │   │   ├── portals.nix          # XDG Desktop Portals (Wayland)
│   │   │   └── wayland.nix          # Variáveis de ambiente Wayland
│   │   ├── sessions/                # Habilitação de WM/DE no sistema
│   │   │   ├── niri.nix             # programs.niri.enable (mkIf)
│   │   │   └── hyprland.nix         # programs.hyprland.enable (mkIf)
│   │   └── maintenance/             # Manutenção automática
│   │       └── gc.nix               # GC, otimização, experimental-features
│   │
│   └── home/
│       ├── common/
│       │   ├── shell.nix            # zsh + aliases + starship
│       │   ├── git.nix              # git config global + delta
│       │   ├── terminal.nix         # kitty com fonte e settings
│       │   └── apps.nix             # Pacotes do dia a dia (lista Hamra.md)
│       ├── sessions/
│       │   ├── niri.nix             # Config KDL + keybinds + Noctalia
│       │   └── hyprland.nix         # Hyprland config + waybar + wofi
│       └── noctalia-shell/
│           └── default.nix          # Bar + launcher + control center
│
├── scripts/
│   └── hamra-init.sh                # Wizard: detecta→importa→pergunta→gera hamra.nix
│
└── docs/
```

---

## 3. Separação Framework vs. Dados do Usuário

**Princípio central:** a configuração do usuário não existe dentro dos módulos do framework.

```
framework/              ← o que é commitado, imutável entre usuários
└── modules/
└── profiles/
└── lib/

dados do usuário/       ← específico desta instalação
└── hosts/main/
    ├── default.nix     ← imports + specialisations (pode ser versionado)
    ├── hardware-configuration.nix  ← gerado por nixos-generate-config
    └── hamra.nix       ← GERADO por hamra-init (valores pessoais)
```

O `hamra-init.sh` gera apenas `hosts/main/hamra.nix`. Não modifica nenhum módulo.

---

## 4. Fluxo de Composição

### Sessão padrão (Niri)

```
flake.nix
└── nixosConfigurations.main
    └── hosts/main/default.nix
        ├── imports:
        │   ├── hardware-configuration.nix
        │   ├── hamra.nix                          (valores do usuário)
        │   └── profiles/desktop/niri.nix
        │       ├── profiles/base.nix
        │       │   ├── modules/nixos/options/hamra.nix  (API)
        │       │   ├── modules/nixos/core/{boot,locale,network,keyboard,users,security,apps,keybinds}.nix
        │       │   ├── modules/nixos/desktop/{audio,fonts,gpu,polkit,portals}.nix
        │       │   ├── modules/nixos/maintenance/gc.nix
        │       │   └── modules/home/common/{shell,git,terminal,apps}.nix
        │       ├── profiles/desktop/common.nix    (SDDM + Wayland vars)
        │       ├── modules/nixos/sessions/niri.nix (mkIf hamra.sessions.niri)
        │       └── modules/home/sessions/niri.nix  (mkIf hamra.sessions.niri)
        │           └── modules/home/noctalia-shell/default.nix
        │
        └── specialisations:
            ├── recovery.configuration
            │   └── profiles/recovery.nix
            └── hyprland.configuration
                └── profiles/desktop/hyprland.nix
```

### Specialisation Hyprland

```
nixos-rebuild switch --flake .#main --specialisation hyprland
    └── hosts/main/default.nix
        └── specialisation.hyprland.configuration
            ├── imports: profiles/desktop/hyprland.nix
            ├── hamra.sessions.niri     = false (mkForce)
            ├── hamra.sessions.hyprland = true  (mkForce)
            └── hamra.defaultSession    = "hyprland" (mkForce)
```

### Specialisation Recovery

```
nixos-rebuild switch --flake .#main --specialisation recovery
    └── profiles/recovery.nix
        ├── services.displayManager.sddm.enable = false (mkForce)
        ├── home-manager.users = {} (mkForce)
        └── environment.systemPackages = [ git vim nano ... ]
```

---

## 5. Opções Hamra (`hamra.*`)

Declaradas em `modules/nixos/options/hamra.nix`. Este é o único arquivo com `mkOption`.

| Opção | Tipo | Default | Descrição |
|-------|------|---------|-----------|
| `hamra.userName` | string | `"nixos"` | Nome do usuário principal |
| `hamra.system.hostname` | string | `"nixos"` | Hostname da máquina |
| `hamra.system.timezone` | string | `"America/Sao_Paulo"` | Timezone |
| `hamra.system.locale` | string | `"pt_BR.UTF-8"` | Locale padrão |
| `hamra.system.keymap` | string | `"us-acentos"` | Mapa de teclado |
| `hamra.boot.loader` | enum | `"grub"` | grub ou systemd-boot |
| `hamra.boot.grub.device` | string | `"/dev/sda"` | Dispositivo GRUB |
| `hamra.gpu` | enum | `"none"` | amd, nvidia, intel, none |
| `hamra.sessions.niri` | bool | `false` | Habilitar Niri |
| `hamra.sessions.hyprland` | bool | `false` | Habilitar Hyprland |
| `hamra.defaultSession` | enum | `"niri"` | Sessão padrão do SDDM |
| `hamra.apps.*` | string | vários | Apps padrão |
| `hamra.keybinds.*` | string | vários | Atalhos padrão |
| `hamra.maintenance.gc.enable` | bool | `true` | GC automático |
| `hamra.maintenance.gc.maxGenerations` | int | `10` | Gerações no bootloader |

---

## 6. Responsabilidades por Camada

### `flake.nix`
- Declara inputs (nixpkgs, home-manager)
- Declara `nixosConfigurations.main`
- Declara `devShells.default` (statix, deadnix, alejandra, nixd)
- **Não contém lógica de configuração**

### `hosts/main/default.nix`
- Importa hardware, hamra.nix e profile de desktop
- Declara specialisations disponíveis (recovery, hyprland)
- Configura Home Manager com `hamra.userName`
- **Não contém valores pessoais** — tudo vem de hamra.nix

### `hosts/main/hamra.nix`
- Arquivo **gerado por hamra-init.sh**
- Contém: userName, hostname, timezone, locale, keymap, gpu, boot, sessions
- Pode ser editado manualmente após geração
- Em repos públicos: adicionar ao `.gitignore`

### `profiles/`
- **Não declaram opções** (`mkOption`)
- Importam módulos e definem a composição de uma sessão
- São "receitas" legíveis de configuração

### `modules/nixos/core/`
- Configuração presente em qualquer NixOS (com ou sem DE)
- boot, locale, network, keyboard, users, security, apps, keybinds

### `modules/nixos/desktop/`
- Específico de ambiente gráfico desktop
- audio, display-manager, fonts, gpu, polkit, portals, wayland

### `modules/nixos/sessions/`
- Habilitação do WM/DE no nível do sistema
- Usa `mkIf cfg.sessions.<nome>` para ser condicional

### `modules/home/`
- Configuração no nível do usuário (home-manager)
- sessions/: dotfiles, keybinds, apps do WM

---

## 7. Convenções de Nomenclatura

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Opções Nix | camelCase | `hamra.userName` |
| Nomes de arquivo | kebab-case | `display-manager.nix` |
| Nomes de host | kebab-case | `main`, `laptop-work` |
| Specialisations | lowercase | `hyprland`, `recovery` |
| Variáveis internas | camelCase | `cfg = config.hamra` |
| Comentários de cabeçalho | Frase descritiva | `# Configura áudio via PipeWire` |

---

## 8. Regras de Design

1. **Módulos fazem uma coisa só** — `audio.nix` só configura áudio
2. **Profiles não têm lógica** — só imports e atribuições de valores
3. **flake.nix não tem lógica** — só entrypoint e wiring
4. **Todas as opções ficam em `options/hamra.nix`** — não espalhadas pelos módulos
5. **Nenhum módulo duplica código de outro** — extrair para módulo comum se necessário
6. **Todo arquivo tem comentário de cabeçalho** — explica o que faz em uma linha
7. **Toda opção tem `description`** — campo obrigatório no `mkOption`
8. **Sessões usam `mkIf`** — módulos de sessão são condicionais via `hamra.sessions.*`
9. **Specialisations usam `mkForce`** — para sobrescrever valores do base
10. **Framework não é modificado pelo usuário** — customizações vão em `hamra.nix` ou `overrides.nix`
