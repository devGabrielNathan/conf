# Guia: Onde Editar cada Configuração

O projeto **Hamra** segue uma filosofia de separação clara entre código de infraestrutura (o framework) e configurações do usuário. Para garantir que o sistema seja robusto e que você possa atualizar o framework sem quebrar suas preferências, as configurações são divididas em 3 camadas:

1. 📂 **DEFAULTS DO SISTEMA** (Seus valores de fábrica)
   São os valores gerados pelo script de instalação [hamra-init.sh](file:///home/gabrielnathan/Projetos/shell/hamra/scripts/hamra-init.sh) específicos para o seu hardware físico. Ficam gravados em:
   - [hosts/main/hardware-configuration.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/hardware-configuration.nix) (Partições, CPU, periféricos)
   - [hosts/main/hamra.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/hamra.nix) (Usuário, hostname, locale e GPU detectados)

2. 🛡️ **FALLBACKS** (Valores padrão do projeto)
   Caso um parâmetro não seja especificado no seu `hamra.nix`, o framework usará os fallbacks definidos na declaração das opções em [modules/nixos/options/hamra.nix](file:///home/gabrielnathan/Projetos/shell/hamra/modules/nixos/options/hamra.nix). Estes fallbacks são pré-configurados pensando no PC do desenvolvedor/criador (Gabriel):
   - Usuário: `gabrielnathan`
   - Locale: `pt_BR.UTF-8`
   - Teclado: `us`
   - GPU: `intel` (Intel Iris Xe)

3. 🛠️ **OVERRIDES** (Suas customizações livres)
   Se você quer instalar pacotes extras, ativar serviços NixOS adicionais (como Docker, PostgreSQL) ou alterar dotfiles do Home Manager, **nunca edite os arquivos do framework**.
   Escreva tudo diretamente em:
   - 👉 [hosts/main/overrides.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/overrides.nix)
   *(Este arquivo já é criado limpo e importado automaticamente pelo entrypoint do sistema, garantindo isolamento total).*

---

## Estrutura de Diretórios Atualizada

```
hamra/
├── flake.nix                          # Ponto de entrada (wiring de inputs e outputs)
├── hosts/main/
│   ├── default.nix                    # Entrypoint principal (imports e specialisations)
│   ├── hardware-configuration.nix     # Configuração física gerada automaticamente
│   ├── hamra.nix                      # Defaults do sistema (gerado na instalação)
│   └── overrides.nix                  # ← SEUS OVERRIDES E CUSTOMIZAÇÕES (edite aqui!)
├── profiles/
│   ├── base.nix                       # Módulos NixOS comuns a todas as máquinas
│   ├── recovery.nix                   # Perfil mínimo de recuperação (sem interface gráfica)
│   └── desktop/
│       ├── common.nix                 # SDDM + Wayland + apps comuns
│       ├── gnome.nix                  # Perfil completo do GNOME Desktop
│       └── plasma.nix                 # Perfil completo do KDE Plasma 6
├── modules/nixos/
│   ├── options/hamra.nix              # Declaração de todas as opções hamra.*
│   ├── core/                          # Serviços essenciais (boot, teclado, locale, etc.)
│   ├── desktop/                       # Gráficos e display (sddm pixie theme, audio, gpu)
│   ├── sessions/                      # Habilitação das DEs (gnome.nix, plasma.nix)
│   └── maintenance/                   # Manutenção automática (garbage collector)
├── modules/home/
│   └── common/                        # Home-manager: shell, git, terminal e pacotes
└── scripts/
    └── hamra-init.sh                  # Wizard de instalação/configuração do host
```

---

## Tabela de Onde Editar

### Configurações de Sistema (Identidade e Hardware)

| O que você quer mudar | Onde editar |
|---|---|
| Nome do usuário, hostname, timezone | [hosts/main/hamra.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/hamra.nix) → `hamra.userName`, `hamra.system.hostname`, etc. |
| Idioma/Locale e Layout do teclado | [hosts/main/hamra.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/hamra.nix) → `hamra.system.locale`, `hamra.system.keymap` |
| Driver de GPU (intel, nvidia, amd, none) | [hosts/main/hamra.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/hamra.nix) → `hamra.gpu` |
| Configuração de garbage collection | [hosts/main/hamra.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/hamra.nix) → `hamra.maintenance.gc.*` |

### Customizações de Desktop e Aplicações

| O que você quer mudar | Onde editar |
|---|---|
| Sessão padrão (plasma ou gnome) | [hosts/main/hamra.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/hamra.nix) → `hamra.defaultSession` |
| Adicionar apps padrão globais | [modules/home/common/apps.nix](file:///home/gabrielnathan/Projetos/shell/hamra/modules/home/common/apps.nix) |
| Mudar apps padrão hamra.* | [hosts/main/hamra.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/hamra.nix) → `hamra.apps.browser`, `hamra.apps.terminal`, etc. |
| Habilitar serviços adicionais (ex: docker) | [hosts/main/overrides.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/overrides.nix) |
| Adicionar pacotes pessoais extras | [hosts/main/overrides.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/overrides.nix) |
| customizar configurações do git, shell ou ssh | [hosts/main/overrides.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/overrides.nix) |

---

## Referência das Opções `hamra.*` (API Pública)

Declaradas em [modules/nixos/options/hamra.nix](file:///home/gabrielnathan/Projetos/shell/hamra/modules/nixos/options/hamra.nix).

| Opção | Tipo | Fallback (Seu PC) | Descrição |
|---|---|---|---|
| `hamra.userName` | string | `"gabrielnathan"` | Nome do usuário principal. |
| `hamra.system.hostname` | string | `"nixos"` | Hostname da máquina. |
| `hamra.system.timezone` | string | `"America/Sao_Paulo"` | Timezone do sistema. |
| `hamra.system.locale` | string | `"pt_BR.UTF-8"` | Locale de idioma e formatação. |
| `hamra.system.keymap` | string | `"us"` | Layout do teclado no console. |
| `hamra.boot.loader` | enum | `"grub"` | Bootloader (`grub` ou `systemd-boot`). |
| `hamra.boot.grub.device` | string | `"/dev/sda"` | Disco de instalação do GRUB. |
| `hamra.gpu` | enum | `"intel"` | Driver de vídeo (`intel`, `amd`, `nvidia`, `none`). |
| `hamra.sessions.plasma` | bool | `false` | Ativar o KDE Plasma 6. |
| `hamra.sessions.gnome` | bool | `false` | Ativar o GNOME. |
| `hamra.defaultSession` | enum | `"plasma"` | Sessão padrão no login manager (`plasma` ou `gnome`). |
| `hamra.apps.browser` | string | `"firefox"` | Navegador de internet padrão. |
| `hamra.apps.terminal` | string | `"kitty"` | Emulador de terminal padrão. |
| `hamra.apps.editor` | string | `"nvim"` | Editor de texto padrão. |
| `hamra.apps.fileManager` | string | `"nautilus"` | Gerenciador de arquivos padrão. |
| `hamra.maintenance.gc.enable` | bool | `true` | Habilitar a limpeza de cache automático do Nix. |

---

## Dicas Importantes

1. **Para restaurar ou inicializar um novo PC** → Execute `sudo bash scripts/hamra-init.sh`
2. **Para aplicar as modificações** → Execute `sudo nixos-rebuild switch --flake .#main`
3. **NÃO modifique** `hardware-configuration.nix` manualmente, ele é re-gerado sob demanda pelo wizard.
4. **NÃO altere** a pasta `modules/` ou `profiles/` para colocar coisas específicas da sua máquina; use sempre o [hosts/main/overrides.nix](file:///home/gabrielnathan/Projetos/shell/hamra/hosts/main/overrides.nix).
