# Análise Arquitetural Completa — Hamra

**Data da análise:** 2026-06-10  
**Repositório:** https://github.com/devGabrielNathan/hamra  
**Commits analisados:** 1 (commit inicial)  
**Arquivos lidos:** flake.nix, README.md, docs/ARQUITETURA.md, docs/ADRs.md, docs/PRD.md, docs/REQUISITOS.md

---

## 1. Estado Atual — Diagnóstico Real

### 1.1. O que foi lido e o que existe

O repositório tem **exatamente 1 commit**. Não existe flake.lock (o que significa que o projeto nunca foi builded ou o lock foi omitido do commit inicial). A árvore real do código, conforme o README, é:

```
hamra/
├── flake.nix                          (31 linhas — só wiring)
├── .vscode/                           (diretório existe, conteúdo não acessado)
├── docs/
│   ├── ARQUITETURA.md
│   ├── ADRs.md
│   ├── PRD.md
│   ├── REQUISITOS.md
│   ├── USER_STORIES.md
│   ├── STYLE_GUIDE.md
│   ├── ONDE_EDITAR.md
│   └── GUIA_IA.md
├── hosts/main/
│   ├── default.nix
│   └── hardware-configuration.nix    (placeholder — gerado pelo setup)
├── modules/
│   ├── nixos/
│   │   ├── options.nix               ← arquivo único, flat
│   │   ├── defaults/
│   │   │   ├── apps.nix
│   │   │   ├── desktop.nix           ← áudio + printing + allowUnfree + grub
│   │   │   ├── keybinds.nix
│   │   │   └── users.nix
│   │   ├── desktop/
│   │   │   ├── fonts.nix
│   │   │   ├── keyboard.nix
│   │   │   ├── locale.nix
│   │   │   ├── network.nix
│   │   │   ├── polkit.nix
│   │   │   ├── portals.nix
│   │   │   ├── sddm.nix
│   │   │   └── wayland.nix
│   │   └── sessions/
│   │       ├── niri.nix
│   │       └── hyprland.nix
│   └── home/
│       ├── common/
│       │   ├── shell.nix
│       │   ├── git.nix
│       │   └── terminal.nix
│       ├── sessions/
│       │   ├── niri.nix
│       │   └── hyprland.nix
│       └── noctalia-shell/
│           └── default.nix
├── profiles/
│   ├── base.nix
│   └── desktop/
│       ├── niri.nix
│       └── hyprland.nix
└── scripts/
    └── hamra-setup.sh
```

### 1.2. Divergência crítica: README vs. ARQUITETURA.md

Esta é a primeira coisa que um novo contribuidor vai perceber — e vai gerar confusão.

| Elemento | README (código real) | ARQUITETURA.md (visão aspiracional) |
|---|---|---|
| Arquivo de opções | `modules/nixos/options.nix` | `modules/nixos/options/hamra.nix` |
| Pasta de base do sistema | `modules/nixos/defaults/` | `modules/nixos/core/` |
| Boot | _ausente_ | `modules/nixos/core/boot.nix` |
| Setup no boot | _ausente_ | `modules/nixos/core/setup.nix` |
| Detecção de hardware | _ausente_ | `modules/nixos/core/hardware-detect.nix` |
| Profile comum de desktop | _ausente_ | `profiles/desktop/common.nix` |
| Home manager apps | _ausente em common/_ | `modules/home/common/apps.nix` |
| Lib | _ausente_ | `lib/` |

**Conclusão:** O ARQUITETURA.md descreve um estado futuro, não o presente. Sem essa clareza, qualquer desenvolvedor que leia a doc e abra o código vai imediatamente sentir que algo está errado.

### 1.3. Análise do flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";  # correto
    };
  };
  outputs = { self, nixpkgs, home-manager, ... } @ inputs: {
    nixosConfigurations.main = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/main/default.nix
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
```

**Avaliação:**
- ✅ Limpo, sem lógica — princípio correto
- ✅ `inputs.nixpkgs.follows` evita dois nixpkgs divergentes
- ✅ `specialArgs` passa inputs para módulos internos
- ⚠️ `system = "x86_64-linux"` hardcoded — bloqueia ARM/aarch64 no futuro
- ⚠️ Sem `nixos-hardware` — hardware quirks (ASUS, ThinkPad, etc.) não são cobertos
- ⚠️ Sem `flake.lock` no commit analisado — sem reprodutibilidade real ainda
- ⚠️ Apenas `nixosConfigurations.main` — sem outputs adicionais (devShells, packages)

### 1.4. Análise do hamra-setup.sh (pelo README)

O script faz:
1. Lê `/etc/nixos.bak/configuration.nix` (deixado pelo Calamares)
2. Extrai: hostname, timezone, locale, keymap, grub device, nome do usuário, grupos
3. Lê `/etc/shadow` para extrair o hash da senha
4. Escreve os valores diretamente nos arquivos `.nix` dos módulos via `sed`/substituição
5. Copia `hardware-configuration.nix` do backup para `hosts/main/`
6. Cria sentinel em `/var/lib/hamra-setup-done`

**Problemas críticos do setup:**

1. **Calamares como dependência dura**: o script falha silenciosamente ou usa defaults se `/etc/nixos.bak/` não existir. Para instalações manuais ou sistemas existentes — que são explicitamente casos de uso desejados — o script não funciona de forma confiável.

2. **Escrita imperativa dentro de módulos declarativos**: o `sed` modifica `network.nix`, `locale.nix`, `keyboard.nix`, `users.nix`, etc. Isso cria um estado mutado no repositório que não é rastreável via git de forma limpa. Se o script rodar duas vezes ou de forma parcial, pode deixar os arquivos corrompidos.

3. **Senha em `secrets/user-password`**: copiar hash de `/etc/shadow` para um arquivo no repositório é um vetor de segurança, especialmente se o repo for público ou forkado.

4. **Sentinel em `/var/lib/`**: esse é estado imperativo fora do controle do Nix. Não é declarativo, não é limpo.

5. **Ausência total de wizard interativo**: o prompt descreve um `hamra init` com Gum que funciona com ENTER para tudo. Isso não existe.

---

## 2. Pontos Fortes da Arquitetura Atual

1. **flake.nix minimal e correto**: A decisão de não colocar lógica no flake.nix é excelente. É a forma certa de usar Flakes.

2. **ADRs bem documentados**: 7 ADRs cobrindo as decisões principais, com contexto, decisão e consequências. Isso é raro em projetos pessoais e vai ajudar muito no futuro.

3. **Separação modules vs profiles**: A distinção entre "lógica técnica" (modules) e "receita declarativa" (profiles) está documentada e é conceitualmente sólida.

4. **Specialisations para sessões**: É o mecanismo nativo do NixOS, sem hacks externos. ADR-002 justifica bem.

5. **Home Manager como módulo NixOS**: Um único `nixos-rebuild switch` configura tudo. Para um single-user workstation, é a decisão correta.

6. **`mkIf` para sessões condicionais**: O padrão de usar `hamra.sessions.niri = true` com `mkIf` nos módulos de sessão é limpo e evita vazamento entre sessões.

7. **options.nix como API centralizada**: A ideia de ter todas as opções `hamra.*` num lugar só (mesmo que ainda seja um arquivo plano) é arquiteturalmente correta.

8. **nixpkgs.follows**: Evita dois nixpkgs diferentes no mesmo sistema — problema comum em flakes mal configurados.

---

## 3. Problemas Críticos

### CRÍTICO-1: Dependência do Calamares no bootstrap

O setup assume `sudo mv /etc/nixos /etc/nixos.bak`. Se não existir, não há wizard de fallback robusto. O projeto quer suportar instalações manuais e sistemas existentes — mas o código não suporta.

**Impacto:** O fluxo de onboarding falha para os casos de uso mais importantes da visão.

### CRÍTICO-2: Escrita imperativa em arquivos declarativos

O `hamra-setup.sh` usa `sed` para substituir valores dentro dos arquivos `.nix`. Isso quebra o contrato do NixOS (configuração declarativa). Se o script rodar parcialmente, os módulos ficam em estado inconsistente.

**Impacto:** Fragilidade de setup, dificuldade de re-execução, difícil de debugar.

### CRÍTICO-3: Inconsistência documental

README.md e ARQUITETURA.md descrevem estruturas diferentes. Para um projeto que quer ser "fácil de entender", ter dois mapas que não batem é imediatamente quebrador de confiança.

**Impacto:** Primeiro contribuidor gasta energia reconciliando documentos antes de entender o projeto.

### CRÍTICO-4: Ausência de `lib/`

O lib está planejado mas ausente. Sem ele, não é possível criar abstrações reutilizáveis ou o `mkSpecialisation` helper mencionado no PRD.

**Impacto:** Toda nova sessão é adicionada por copiar e colar código sem abstração.

### CRÍTICO-5: `modules/nixos/defaults/` mistura responsabilidades

O diretório `defaults/` contém:
- `desktop.nix` — áudio, impressão, allowUnfree, grub device (isso é **infraestrutura de boot**)
- `users.nix` — definição de usuário (isso é **core**)
- `keybinds.nix` — atalhos e apps padrão (isso é **configuração de desktop**)
- `apps.nix` — lista de aplicações padrão (isso é **userland**)

Chamar tudo de "defaults" esconde a natureza e responsabilidade de cada um.

### CRÍTICO-6: `modules/nixos/desktop/` mistura infraestrutura com desktop

`keyboard.nix`, `locale.nix`, `network.nix` são **configuração de sistema** (presentes mesmo em servidores). Mas estão no mesmo nível de `sddm.nix`, `wayland.nix` — que são **configuração de desktop**. Isso torna as dependências menos óbvias.

---

## 4. Riscos Futuros

### RISCO-1: Escalonamento de specialisations sem abstração

Para adicionar GNOME, Plasma, Sway além de Niri e Hyprland, o processo atual é:
1. Criar `modules/nixos/sessions/<nome>.nix`
2. Criar `modules/home/sessions/<nome>.nix`
3. Criar `profiles/desktop/<nome>.nix`
4. Editar `hosts/main/default.nix` manualmente

Sem `lib/mkSpecialisation`, cada adição é uma operação de copy-paste com risco de divergência.

### RISCO-2: O `mkForce` em specialisations é frágil

Na specialisation Hyprland, `hamra.sessions.niri = mkForce false` desativa o Niri. Mas se módulos futuros tiverem dependências cruzadas (ex: um tema que funciona em ambos), o `mkForce` pode causar conflitos difíceis de debugar.

### RISCO-3: Ausência de recovery environment

Se uma sessão falhar durante rebuild (ex: bug no Niri 1.x), o usuário fica sem acesso gráfico. Não existe um ambiente de recuperação mínimo garantido. O mecanismo do bootloader NixOS ajuda, mas não é suficiente para usuários novatos.

### RISCO-4: nixpkgs-unstable sem pinning de pacotes críticos

ADR-007 é "Em discussão" mas o projeto já usa unstable. Pacotes como Hyprland e Niri evoluem rapidamente e podem quebrar entre updates do flake.lock sem aviso. Isso é especialmente problemático para um projeto que quer ser estável.

### RISCO-5: Hardware-configuration hardcoded no repositório

O `hosts/main/hardware-configuration.nix` no repositório é um arquivo placeholder ou o arquivo real do hardware do desenvolvedor. Para outros usuários, substituir esse arquivo via `sed` no script de setup é frágil.

### RISCO-6: Sem CI/CD

Sem `nix flake check` em CI, regressões silenciosas são prováveis conforme o projeto cresce.

### RISCO-7: Senha no repositório

O setup copia o hash de `/etc/shadow` para `secrets/user-password`. Se esse arquivo for acidentalmente commitado (sem .gitignore adequado), é uma exposição de credenciais.

---

## 5. Arquitetura Alvo Recomendada

### 5.1. Princípio Orientador

**A configuração do usuário não deve existir dentro dos módulos do framework.**

O setup atual escreve valores do usuário (hostname, timezone, etc.) diretamente dentro dos arquivos `.nix` do framework. A arquitetura alvo separa essas duas coisas:

```
framework/              ← o que você commita, imutável
└── modules/            
└── profiles/           
└── lib/                

host/                   ← o que é específico da máquina
└── hosts/main/
    ├── default.nix     ← imports + hamra.* options
    ├── hardware.nix    ← gerado por nixos-generate-config
    └── hamra.nix       ← valores do usuário (gerado por hamra init)
```

O `hamra init` gera apenas `hosts/main/hamra.nix`. Não modifica nada dos módulos.

### 5.2. Nova Estrutura de Diretórios

```
hamra/
├── flake.nix                          # Entrypoint — só wiring
├── flake.lock                         # Fixado
│
├── lib/
│   ├── default.nix                    # Re-exporta tudo de lib/
│   ├── mkSpecialisation.nix           # Helper para criar sessões
│   └── validators.nix                 # lib.hamra.assertGpu, etc.
│
├── hosts/
│   └── main/
│       ├── default.nix                # imports + specialisations
│       ├── hardware.nix               # gerado por nixos-generate-config
│       └── hamra.nix                  # gerado por hamra init (gitignored ou commitável)
│
├── profiles/
│   ├── base.nix                       # base comum a todos os hosts
│   ├── desktop/
│   │   ├── common.nix                 # SDDM + Wayland env (compartilhado)
│   │   ├── niri.nix
│   │   ├── hyprland.nix
│   │   ├── gnome.nix                  # futuro
│   │   └── plasma.nix                 # futuro
│   └── bundles/
│       ├── dev.nix                    # futuro
│       ├── gaming.nix                 # futuro
│       └── laptop.nix                 # futuro
│
├── modules/
│   ├── nixos/
│   │   ├── options/
│   │   │   └── hamra.nix              # ÚNICA fonte de opções hamra.*
│   │   ├── core/                      # Presente em qualquer NixOS
│   │   │   ├── boot.nix               # bootloader, kernel
│   │   │   ├── locale.nix             # timezone, i18n, keyboard
│   │   │   ├── network.nix            # NetworkManager, hostname
│   │   │   ├── users.nix              # usuário via hamra.userName
│   │   │   └── security.nix           # sudo, polkit base
│   │   ├── desktop/                   # Específico de desktop gráfico
│   │   │   ├── audio.nix              # pipewire + wireplumber
│   │   │   ├── fonts.nix
│   │   │   ├── gpu.nix                # drivers AMD/NVIDIA/Intel via hamra.gpu
│   │   │   ├── polkit.nix             # agente gráfico do polkit
│   │   │   ├── portals.nix            # XDG portals (Wayland)
│   │   │   └── display-manager.nix    # SDDM + defaultSession
│   │   ├── sessions/                  # Habilitação de WM no sistema
│   │   │   ├── niri.nix
│   │   │   ├── hyprland.nix
│   │   │   ├── gnome.nix              # futuro
│   │   │   └── plasma.nix             # futuro
│   │   └── maintenance/               # NOVO
│   │       ├── gc.nix                 # garbage collection automático
│   │       └── health.nix             # verificações periódicas
│   │
│   └── home/
│       ├── common/
│       │   ├── shell.nix
│       │   ├── git.nix
│       │   ├── terminal.nix
│       └── apps.nix                   # apps comuns
│       ├── sessions/
│       │   ├── niri.nix
│       │   ├── hyprland.nix
│       │   └── [...]
│       └── noctalia-shell/
│           └── default.nix
│
├── scripts/
│   └── hamra-init.sh                  # RENOMEADO + redesenhado
│
└── docs/                              # (existente)
```

### 5.3. O novo `hamra init`

O script deve ter três fases distintas, com fallback elegante entre elas:

```
hamra init
│
├── FASE 1 — Detectar hardware
│   ├── /etc/nixos/hardware-configuration.nix existe?
│   │   └── SIM → copiar para hosts/main/hardware.nix
│   └── NÃO → executar nixos-generate-config --show-hardware-config
│           └── salvar em hosts/main/hardware.nix
│
├── FASE 2 — Importar configuração existente
│   ├── /etc/nixos/configuration.nix existe?
│   │   └── SIM → extrair:
│   │           networking.hostName
│   │           time.timeZone
│   │           i18n.defaultLocale
│   │           console.keyMap
│   │           users.users.* (nome do usuário)
│   │           boot.loader.* (tipo de bootloader)
│   └── NÃO → pular para Fase 3 com todos os valores em branco
│
└── FASE 3 — Wizard interativo (Gum)
    ├── Mostrar valores encontrados (se existirem)
    ├── Perguntar apenas o que falta (ou tudo, se nada foi encontrado)
    ├── Perguntas com defaults sensatos:
    │   ├── Hostname [nixos]
    │   ├── Timezone [America/Sao_Paulo]
    │   ├── Locale [pt_BR.UTF-8]
    │   ├── Keymap [br-abnt2]
    │   ├── Nome do usuário [nixos]
    │   ├── GPU [amd/intel/nvidia] (auto-detect via lspci)
    │   └── Sessão padrão [niri]
    └── Gerar hosts/main/hamra.nix com os valores
```

### 5.4. O arquivo `hosts/main/hamra.nix` gerado

Em vez de escrever em módulos do framework, o `hamra init` gera este arquivo:

```nix
# Gerado por hamra init — pode ser editado manualmente
# Este arquivo NÃO deve ser modificado pelos módulos do framework
{ ... }: {
  hamra = {
    userName = "gabriel";
    gpu = "amd";
    sessions.niri = true;
    defaultSession = "niri";

    system = {
      hostname = "workstation";
      timezone = "America/Sao_Paulo";
      locale = "pt_BR.UTF-8";
      keymap = "br-abnt2";
    };

    boot = {
      loader = "systemd-boot";  # ou "grub"
      # grub.device = "/dev/sda";  # só se loader = "grub"
    };
  };
}
```

**Por que isso é melhor?**
- O framework não é modificado pelo usuário
- O arquivo do usuário é fácil de versionar, compartilhar, ou regenerar
- Não há mais `sed` escrevendo em código Nix
- É 100% declarativo

### 5.5. Recuperação garantida

Adicionar uma specialisation `recovery` que sempre existe:

```nix
# Em hosts/main/default.nix
specialisation = {
  recovery.configuration = {
    imports = [ ../../profiles/recovery.nix ];
    # Sem sessão gráfica, sem home-manager
    # Só TTY + ferramentas essenciais
  };
  hyprland.configuration = { ... };
};
```

```nix
# profiles/recovery.nix
{ pkgs, ... }: {
  # Sem display manager
  services.displayManager.enable = false;

  # Sem Home Manager na recovery
  home-manager.users = lib.mkForce {};

  # Ferramentas mínimas
  environment.systemPackages = with pkgs; [
    git vim nano
    nixos-rebuild
    parted gptfdisk
    curl wget
  ];

  # Boot sempre mostra esta opção
  boot.loader.systemd-boot.editor = false;
}
```

Esta specialisation é leve, sempre buildável, e garante que o usuário sempre tem acesso a um ambiente funcional mesmo que todas as sessões gráficas falhem.

### 5.6. Retenção de gerações

```nix
# modules/nixos/maintenance/gc.nix
{ config, lib, ... }:
let cfg = config.hamra.maintenance;
in {
  # Limite de gerações no bootloader
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;
  # ou para GRUB:
  # boot.loader.grub.configurationLimit = lib.mkDefault 10;

  # Garbage collection automático
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Otimização do store
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
```

Para gerações "pinadas", o NixOS não tem um mecanismo nativo de pin. A solução mais pragmática é documentar que o usuário pode criar um tag Git para a geração que quer preservar, e usar `nix build .#nixosConfigurations.main.config.system.build.toplevel` para manter o derivado no store.

### 5.7. Governança Arquitetural

#### Na camada Nix — Validações em Options

```nix
# modules/nixos/options/hamra.nix
options.hamra.gpu = lib.mkOption {
  type = lib.types.enum [ "amd" "nvidia" "intel" "none" ];
  default = "none";
  description = "GPU do sistema. Configura drivers automaticamente.";
};

# Validação estrutural
config = lib.mkIf (config.hamra.gpu == "nvidia") {
  assertions = [{
    assertion = config.hamra.sessions.gnome -> false; 
    # GNOME + NVIDIA tem fricção — avisar
    message = "hamra: GNOME com NVIDIA pode ter problemas. Use hamra.sessions.plasma ou hamra.sessions.hyprland.";
  }];
};
```

#### Na camada de CI — GitHub Actions

```yaml
# .github/workflows/check.yml
name: Nix Flake Check
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v26
        with:
          extra_nix_config: "experimental-features = nix-command flakes"
      - run: nix flake check
      - run: nix fmt -- --check .  # formata com nixfmt ou alejandra
```

#### Para o VSCode — nixd LSP

```json
// .vscode/settings.json
{
  "nix.enableLanguageServer": true,
  "nix.serverPath": "nixd",
  "nix.serverSettings": {
    "nixd": {
      "nixpkgs": {
        "expr": "import (builtins.getFlake (builtins.toString ./.)).inputs.nixpkgs {}"
      },
      "options": {
        "nixos": {
          "expr": "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.main.options"
        }
      }
    }
  },
  "[nix]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "jnoortheen.nix-ide"
  }
}
```

Com nixd configurado corretamente, erros em opções `hamra.*` aparecem diretamente no editor antes do build.

#### Detecção de dependências — `nix-linter` / `statix`

```nix
# Adicionar ao flake.nix como devShell
devShells.default = pkgs.mkShell {
  buildInputs = [ pkgs.statix pkgs.deadnix pkgs.alejandra ];
  shellHook = ''
    echo "Hamra dev environment"
    echo "  statix check . — lint"
    echo "  deadnix .      — detectar imports mortos"
    echo "  alejandra .    — formatar"
  '';
};
```

### 5.8. Overrides sem modificar módulos

```nix
# hosts/main/default.nix — estrutura recomendada
{ inputs, ... }: {
  imports = [
    ./hardware.nix
    ./hamra.nix                         # gerado por hamra init
    ../../modules/nixos/options/hamra.nix
    ../../profiles/base.nix
    ../../profiles/desktop/common.nix
    ../../profiles/desktop/niri.nix

    # Overrides do usuário — opcional, ignorado se não existir
    (if builtins.pathExists ./overrides.nix then ./overrides.nix else {})
  ];

  specialisation = {
    recovery.configuration.imports = [ ../../profiles/recovery.nix ];
    hyprland.configuration = {
      imports = [ ../../profiles/desktop/hyprland.nix ];
      hamra.sessions.niri = lib.mkForce false;
      hamra.sessions.hyprland = lib.mkForce true;
    };
  };
}
```

O arquivo `hosts/main/overrides.nix` é opcional e nunca é modificado pelo framework. O usuário coloca customizações lá sem tocar nos módulos internos.

---

## 6. Roadmap de Implementação

### Fase 0 — Estabilização (1-2 semanas)
**Objetivo: fazer o que existe funcionar de forma confiável e consistente**

| Prioridade | Tarefa |
|---|---|
| P0 | Sincronizar README.md com ARQUITETURA.md — um único mapa verdadeiro |
| P0 | Gerar e commitar `flake.lock` |
| P0 | Adicionar `.gitignore` cobrindo `secrets/`, `hosts/main/hardware.nix` |
| P1 | Renomear `modules/nixos/defaults/` → `modules/nixos/core/` |
| P1 | Mover `keyboard.nix`, `locale.nix`, `network.nix` de `desktop/` → `core/` |
| P1 | Criar `profiles/desktop/common.nix` (SDDM + Wayland vars) |
| P1 | Mover `modules/nixos/options.nix` → `modules/nixos/options/hamra.nix` |
| P2 | Adicionar `home-manager.useGlobalPkgs = true` e `home-manager.useUserPackages = true` no flake (evita incompatibilidades) |

### Fase 1 — Bootstrap Declarativo (2-3 semanas)
**Objetivo: `hamra init` funcional sem dependência do Calamares**

| Prioridade | Tarefa |
|---|---|
| P0 | Redesenhar `hamra-setup.sh` para gerar `hosts/main/hamra.nix` em vez de escrever em módulos |
| P0 | Implementar Fase 1 do init: detecção/geração de hardware-configuration |
| P0 | Implementar Fase 2: importação de `/etc/nixos/configuration.nix` se existir |
| P1 | Implementar Fase 3: wizard Gum com defaults sensatos |
| P1 | Implementar auto-detecção de GPU via `lspci` |
| P2 | Criar `modules/nixos/options/hamra.nix` completo com tipos e validações |
| P2 | Mover configuração de boot para `modules/nixos/core/boot.nix` |

### Fase 2 — Recovery e Manutenção (1-2 semanas)
**Objetivo: sistema que nunca fica inacessível**

| Prioridade | Tarefa |
|---|---|
| P0 | Criar `profiles/recovery.nix` — ambiente mínimo sem DE |
| P0 | Registrar specialisation `recovery` em `hosts/main/default.nix` |
| P1 | Criar `modules/nixos/maintenance/gc.nix` — GC automático e limite de gerações |
| P2 | Documentar processo de "pin" de geração via Git tags |

### Fase 3 — Governança e IDE-First (2 semanas)
**Objetivo: erros aparecem antes do build**

| Prioridade | Tarefa |
|---|---|
| P0 | Configurar `.vscode/settings.json` com nixd LSP |
| P0 | Criar GitHub Actions com `nix flake check` |
| P1 | Criar `flake.nix#devShells.default` com statix, deadnix, alejandra |
| P1 | Adicionar `assertions` nos options para validações estruturais |
| P2 | Adicionar `nix fmt` check no CI |

### Fase 4 — Lib e Extensibilidade (3+ semanas)
**Objetivo: adicionar nova sessão sem copy-paste**

| Prioridade | Tarefa |
|---|---|
| P1 | Criar `lib/mkSpecialisation.nix` — helper para novas sessões |
| P1 | Criar `lib/validators.nix` — funções de validação reutilizáveis |
| P2 | Refatorar especialisations existentes usando o helper |
| P2 | Documentar processo de extensão com exemplos concretos |
| P3 | Adicionar specialisation GNOME (v0.2) |
| P3 | Adicionar specialisation Plasma (v0.2) |

---

## 7. Priorização das Mudanças

### Críticas (fazer antes de qualquer coisa)

1. **Gerar flake.lock** — sem isso o projeto não é reproduzível
2. **Sincronizar docs** — escolher uma estrutura e fazer código e docs baterem
3. **Redesenhar bootstrap** — separar valores do usuário dos módulos do framework

### Importantes (fazer logo após)

4. **Renomear defaults/ → core/** — clareza de responsabilidade
5. **Mover infraestrutura de sistema para core/** — separar do que é desktop
6. **Criar recovery specialisation** — garantir que o sistema sempre tem saída
7. **Configurar nixd no .vscode** — feedback imediato no editor

### Desejáveis (médio prazo)

8. **CI com nix flake check** — regressões detectadas automaticamente
9. **maintenance/gc.nix** — sistema que cuida de si mesmo
10. **lib/mkSpecialisation** — extensibilidade real sem copy-paste

### Futuro (quando o núcleo estiver estável)

11. GNOME, Plasma, Sway
12. Bundles (dev, gaming, laptop)
13. nixos-hardware para hardware quirks comuns

---

## 8. Exemplo Concreto: Estrutura Final de Diretórios

```
hamra/
├── flake.nix
├── flake.lock
├── .gitignore                         # secrets/, hosts/*/hardware.nix (opcional)
│
├── lib/
│   ├── default.nix                    # { mkSpecialisation = import ./mkSpecialisation.nix; ... }
│   └── mkSpecialisation.nix
│
├── hosts/
│   └── main/
│       ├── default.nix                # só imports + specialisations
│       ├── hardware.nix               # nixos-generate-config (gitignored ou versionado)
│       └── hamra.nix                  # gerado por hamra init
│
├── profiles/
│   ├── base.nix                       # core/ + desktop/ comuns
│   ├── recovery.nix                   # ambiente mínimo sem DE
│   └── desktop/
│       ├── common.nix                 # SDDM + wayland env vars
│       ├── niri.nix
│       └── hyprland.nix
│
├── modules/
│   ├── nixos/
│   │   ├── options/
│   │   │   └── hamra.nix              # mkOption para tudo — API pública
│   │   ├── core/
│   │   │   ├── boot.nix
│   │   │   ├── locale.nix
│   │   │   ├── network.nix
│   │   │   ├── users.nix
│   │   │   └── security.nix
│   │   ├── desktop/
│   │   │   ├── audio.nix
│   │   │   ├── fonts.nix
│   │   │   ├── gpu.nix
│   │   │   ├── polkit.nix
│   │   │   ├── portals.nix
│   │   │   └── display-manager.nix
│   │   ├── sessions/
│   │   │   ├── niri.nix
│   │   │   └── hyprland.nix
│   │   └── maintenance/
│   │       └── gc.nix
│   └── home/
│       ├── common/
│       │   ├── shell.nix
│       │   ├── git.nix
│       │   ├── terminal.nix
│       │   └── apps.nix
│       ├── sessions/
│       │   ├── niri.nix
│       │   └── hyprland.nix
│       └── noctalia-shell/
│           └── default.nix
│
└── scripts/
    └── hamra-init.sh                  # wizard: detecta → importa → pergunta → gera hamra.nix
```

---

## 9. Resumo Executivo

O Hamra tem **excelente base conceitual**: as ADRs são bem fundamentadas, o flake.nix está correto, e a separação modules/profiles é sólida. A documentação é mais completa do que a maioria dos projetos NixOS pessoais.

O problema central é que **o código não implementa ainda a visão documentada**, e parte da visão documentada (ARQUITETURA.md) não bate com o código atual (README.md). O bootstrap ainda tem dependência do Calamares e usa escrita imperativa em código declarativo.

Para transformar o Hamra em um framework de workstations NixOS:

1. **Curto prazo**: sincronizar docs, renomear pastas, gerar flake.lock
2. **Médio prazo**: redesenhar bootstrap para ser Calamares-independente, criar recovery
3. **Longo prazo**: lib, governança, CI, extensibilidade real

A boa notícia é que as decisões arquiteturais fundamentais (Flakes, specialisations, HM como módulo) são **corretas** e não precisam ser revertidas. O trabalho necessário é de refinamento e implementação consistente — não de refazer do zero.
