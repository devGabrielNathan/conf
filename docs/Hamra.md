# Apps Disponíveis no Nixpkgs — hamra

Mapa de disponibilidade dos aplicativos no nixpkgs e sua configuração no projeto.  
Apps marcados com **✅ unfree** requerem `nixpkgs.config.allowUnfree = true` (habilitado por padrão).

---

## Apps instalados em todas as sessões

Configurados em `modules/home/common/apps.nix` (lista de pacotes) e `modules/nixos/desktop/apps.nix` (defaults de apps padrão).

| App | Nixpkgs | Pacote | Observação |
|-----|---------|--------|------------|
| **Git** | ✅ | `pkgs.git` | Via `programs.git.enable` |
| **Helix** | ✅ | `pkgs.helix` | Editor modal moderno |
| **Mise** | ✅ | `pkgs.mise` | Runtime version manager |
| **Lazygit** | ✅ | `pkgs.lazygit` | Git TUI |
| **Lazydocker** | ✅ | `pkgs.lazydocker` | Docker TUI |
| **Fastfetch** | ✅ | `pkgs.fastfetch` | System info |
| **Btop** | ✅ | `pkgs.btop` | Monitor de recursos |
| **Opencode** | ✅ | `pkgs.opencode` | AI no terminal (unstable) |
| **DBeaver** | ✅ | `pkgs.dbeaver-bin` | SQL client universal |
| **Postman** | ✅ unfree | `pkgs.postman` | HTTP client |
| **Firefox** | ✅ | `programs.firefox.enable` | Navegador padrão |
| **Discord** | ✅ unfree | `pkgs.discord` | Comunicação |
| **OBS Studio** | ✅ | `pkgs.obs-studio` | Gravação e streaming |
| **Spotify** | ✅ unfree | `pkgs.spotify` | Música |
| **VLC** | ✅ | `pkgs.vlc` | Media player |
| **Obsidian** | ✅ unfree | `pkgs.obsidian` | Notas pessoais |
| **VSCode** | ✅ unfree | `pkgs.vscode` | IDE |
| **Wireshark** | ✅ | `pkgs.wireshark` | Análise de rede |
| **Camunda Modeler** | ✅ | `pkgs.camunda-modeler` | BPMN modeling |

---

## Apps configurados no sistema (não só instalados)

| App | Nixpkgs | Configuração | Observação |
|-----|---------|--------------|------------|
| **Zsh** | ✅ | `programs.zsh.enable` | + Starship como prompt |
| **Kitty** | ✅ | `programs.kitty.enable` | Terminal padrão |
| **Git** | ✅ | `programs.git.enable` | + delta como pager |
| **Starship** | ✅ | `programs.starship.enable` | Prompt |

---

## Ativar allowUnfree

Habilitado por padrão em `modules/nixos/desktop/audio.nix`:

```nix
nixpkgs.config.allowUnfree = true;
```

Para desabilitar, sobrescreva em `hosts/main/overrides.nix`:

```nix
nixpkgs.config.allowUnfree = lib.mkForce false;
```