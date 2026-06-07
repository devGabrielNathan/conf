# hamra

Configuração NixOS modular com suporte a múltiplos desktop environments via `specialisations`. Cada sessão é construída apenas quando ativada em `hosts/main/hamra.nix`.

## Sessões disponíveis

| Sessão | Opção | WM / DE | DM |
|--------|-------|---------|----|
| KDE Plasma 6 | `sessions.plasma` | KWin (Wayland) | SDDM |
| GNOME | `sessions.gnome` | Mutter (Wayland/X11) | SDDM |
| Recovery | `sessions.recovery` | TTY (sem gráfico) | — |

---

## Início rápido

> [!IMPORTANT]
> Em instaladores mínimos sem `git`, entre em um shell temporário antes de clonar:
> ```bash
> nix-shell -p git
> ```

> [!WARNING]
> **Sobre o `/etc/nixos` existente**: o NixOS cria esse diretório por padrão com `configuration.nix` e `hardware-configuration.nix`. O script `hamra-init.sh` gerencia a transição automaticamente:
> 1. Faz backup de `/etc/nixos` para `/etc/nixos.bak`
> 2. Extrai hostname, teclado, locale e partições dos arquivos de backup
> 3. Reconstrói a estrutura com suas configurações importadas
>
> Suas configurações de hardware não serão perdidas.

```bash
# 1. Clone o repositório
git clone https://github.com/devGabrielNathan/conf ~/hamra
cd ~/hamra

# 2. Execute o wizard de inicialização
sudo bash scripts/hamra-init.sh

# 3. Entre no diretório definitivo
cd /etc/nixos

# 4. Aplique a configuração
sudo nixos-rebuild switch --flake .#main

# 5. Reinicie
sudo reboot
```

---

## Trocando de sessão

Edite `hosts/main/hamra.nix`:

```nix
  # ── Sessão ─────────────────────────────────────────────────
  sessions.recovery = false;      # ativa recovery (se desejar)
  sessions.plasma   = false;      # desativa plasma
  sessions.gnome    = true;       # ativa gnome
  defaultSession    = "gnome";    # sessão padrão do SDDM
```

Depois rebuild com a specialisation desejada:

```bash
sudo nixos-rebuild switch --flake .#main --specialisation gnome
```

Para usar apenas a sessão padrão (sem specialisation extra):

```bash
sudo nixos-rebuild switch --flake .#main
```

> Recovery desabilita o display manager e o Home Manager. Use apenas quando o ambiente gráfico estiver inacessível (`--specialisation recovery`).

---

## Configuração

### Valores pessoais — `hosts/main/hamra.nix`

Gerado pelo `hamra-init.sh`, este arquivo centraliza todos os seus valores pessoais. Edite-o diretamente conforme necessário:

```nix
{ lib, ... }:
{
  hamra = {
    userName = "gabrielnathan";

    system = {
      hostname = "nixos";
      timezone = "America/Sao_Paulo";
      locale   = "pt_BR.UTF-8";
      keymap   = "us";
    };

    boot = {
      loader = "grub";           # ou "systemd-boot" para UEFI
      grub.device = "/dev/sda";
    };

    gpu = "intel";               # amd | nvidia | intel | none

    sessions.plasma = true;
    defaultSession  = "plasma";
  };
}
```

Para regenerar do zero: `sudo bash scripts/hamra-init.sh`

### Personalizações extras — `hosts/main/overrides.nix`

Para instalar pacotes adicionais ou habilitar serviços do NixOS além das opções `hamra.*`, edite `hosts/main/overrides.nix`. Este arquivo nunca é alterado pelo framework e é o local ideal para suas customizações.

### Referência rápida

| O que fazer | Onde editar |
|-------------|-------------|
| Hostname, timezone, locale, teclado | `hosts/main/hamra.nix` |
| Driver de GPU | `hosts/main/hamra.nix` → `hamra.gpu` |
| Sessão ativa | `hosts/main/hamra.nix` → `hamra.sessions.*` |
| Sessão padrão | `hosts/main/hamra.nix` → `hamra.defaultSession` |
| GC automático | `hosts/main/hamra.nix` → `hamra.maintenance.gc.*` |
| Pacotes extras ou serviços do NixOS | `hosts/main/overrides.nix` |
| Apps para todas as sessões | `modules/home/common/apps.nix` |
| SDDM / tema do login | `modules/nixos/desktop/display-manager.nix` |
| Fontes do sistema | `modules/nixos/desktop/fonts.nix` |
| Áudio | `modules/nixos/desktop/audio.nix` |

---

## Estrutura do projeto

```
hamra/
├── flake.nix                          # Entrypoint (não editar)
│
├── lib/
│   └── default.nix                    # Helpers e re-exports
│
├── hosts/main/                        # Configuração da máquina
│   ├── default.nix                    #   Imports e specialisations (optionalAttrs)
│   ├── hardware-configuration.nix     #   Gerado automaticamente
│   ├── hamra.nix                      #   Seus valores (gerado por hamra-init)
│   └── overrides.nix                  #   Seus overrides e customizações extras
│
├── profiles/                          # Receitas — agrupam módulos
│   ├── base.nix                       #   Módulos comuns (sem sessão)
│   ├── recovery.nix                   #   Ambiente mínimo de recuperação
│   └── desktop/
│       ├── common.nix                 #   SDDM + variáveis Wayland + pacotes base
│       ├── gnome.nix                  #   Receita GNOME
│       └── plasma.nix                 #   Receita KDE Plasma 6
│
├── modules/
│   ├── nixos/                         # Sistema (requer sudo)
│   │   ├── options/
│   │   │   └── hamra.nix              #   API pública — todas as opções hamra.*
│   │   ├── core/                      #   Presente em qualquer sessão NixOS
│   │   │   ├── boot.nix               #     Bootloader (grub / systemd-boot)
│   │   │   ├── locale.nix             #     Timezone e locale
│   │   │   ├── network.nix            #     Hostname e NetworkManager
│   │   │   ├── keyboard.nix           #     Layout de teclado
│   │   │   ├── users.nix              #     Usuário via hamra.userName
│   │   │   └── security.nix           #     sudo e polkit base
│   │   ├── desktop/                   #   Infraestrutura gráfica
│   │   │   ├── apps.nix               #     Apps padrão
│   │   │   ├── audio.nix              #     PipeWire + CUPS
│   │   │   ├── display-manager.nix    #     SDDM (pixie-sddm theme)
│   │   │   ├── fonts.nix              #     Fontes
│   │   │   ├── gpu.nix                #     Drivers AMD/NVIDIA/Intel
│   │   │   ├── polkit.nix             #     Agente de autenticação gráfico
│   │   │   ├── portals.nix            #     XDG Desktop Portals
│   │   │   └── wayland.nix            #     Variáveis de ambiente
│   │   ├── sessions/                  #   Habilita DE no sistema
│   │   │   ├── gnome.nix              #     GNOME (mkIf)
│   │   │   └── plasma.nix             #     KDE Plasma 6 (mkIf)
│   │   └── maintenance/
│   │       └── gc.nix                 #     GC + otimização do store
│   │
│   └── home/                          # Usuário (dotfiles)
│       └── common/                    #   Shell, git, terminal, apps comuns
│
└── scripts/
    └── hamra-init.sh                  # Wizard de inicialização
```

---

## Documentação

- [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md) — Arquitetura e estrutura de módulos
- [`docs/ADRs.md`](docs/ADRs.md) — Decisões de design
- [`docs/PRD.md`](docs/PRD.md) — Documento de requisitos
- [`docs/REQUISITOS.md`](docs/REQUISITOS.md) — Requisitos funcionais e não-funcionais
- [`docs/USER_STORIES.md`](docs/USER_STORIES.md) — Histórias de usuário
- [`docs/STYLE_GUIDE.md`](docs/STYLE_GUIDE.md) — Regras de formatação
- [`docs/GUIA_IA.md`](docs/GUIA_IA.md) — Guia para desenvolvimento assistido por IA
