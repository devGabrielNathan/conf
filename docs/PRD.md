# PRD — Product Requirements Document
## hamra

**Versão:** 1.0  
**Data:** 2025-06  
**Status:** Em definição  
**Autor:** Projeto hamra  

---

## 1. Visão Geral

### 1.1. Resumo do Produto

`hamra` é uma configuração NixOS modular e opinativa, inspirada no projeto Hamra, que permite ao usuário alternar entre diferentes Desktop Environments (DEs) e Window Managers (WMs) usando o mecanismo nativo de **specialisations** do NixOS.

O projeto resolve um problema central do gerenciamento de ambientes gráficos no NixOS: a necessidade de manter múltiplos DEs instalados simultaneamente, desperdiçando espaço e criando conflitos, quando na prática o usuário usa apenas um por vez.

### 1.2. Problema que Resolve

No NixOS, usuários que querem experimentar diferentes ambientes gráficos (Hyprland, Plasma, GNOME, Sway) geralmente adicionam todos à mesma configuração. Isso resulta em:

- Espaço em disco desperdiçado com pacotes de DEs não utilizados
- Possíveis conflitos de configuração entre DEs
- Configuração monolítica e difícil de manter
- Ausência de isolamento claro entre ambientes

### 1.3. Solução

Utilizar o mecanismo de `specialisations` do NixOS para criar variações isoladas da configuração, onde cada DE/WM é uma specialisation separada. O usuário ativa o desktop desejado com um único comando e apenas os pacotes daquela sessão ficam instalados na geração ativa.

---

## 2. Objetivos do Produto

### 2.1. Objetivos Primários

| ID | Objetivo |
|----|----------|
| OBJ-01 | Permitir troca de DE/WM sem manter múltiplos ambientes instalados simultaneamente |
| OBJ-02 | Fornecer estrutura modular e escalável para configurações NixOS |
| OBJ-03 | Oferecer API declarativa simples para onboarding de novos usuários |
| OBJ-04 | Suportar Hyprland, Plasma, GNOME e Sway como desktops de primeira classe |

### 2.2. Objetivos Secundários

| ID | Objetivo |
|----|----------|
| OBJ-05 | Fornecer bundles opcionais para dev, gaming, media e laptop |
| OBJ-06 | Permitir extensão para novos DEs/WMs sem modificar o core |
| OBJ-07 | Documentar o projeto de forma que qualquer usuário NixOS consiga onboardar |

### 2.3. Fora de Escopo (Non-Goals)

- Suporte a distribuições Linux que não sejam NixOS
- Gerenciamento de dotfiles via stow ou scripts imperativos
- Interface gráfica para troca de specialisations
- Suporte a versões antigas do NixOS sem flakes

---

## 3. Público-Alvo

### 3.1. Usuário Primário

**Perfil:** Usuário avançado de Linux e NixOS que:
- Conhece o básico de configuração NixOS (flakes, modules)
- Quer experimentar múltiplos DEs/WMs sem overhead
- Valoriza reprodutibilidade e configuração declarativa
- Prefere um projeto opinionado a construir do zero

### 3.2. Usuário Secundário

**Perfil:** Usuário NixOS intermediário que:
- Quer uma base sólida para construir sua própria configuração
- Está migrando de outro sistema (Arch, Fedora) para NixOS
- Busca referência de boas práticas de organização de configs NixOS

---

## 4. Funcionalidades do Produto

### 4.1. Feature Map

```
hamra
├── Core
│   ├── Configuração base comum (shell, git, terminal, áudio, fontes)
│   ├── Specialisations por DE/WM
│   └── API declarativa (hamra.enable, hamra.userName, hamra.gpu)
├── Desktops
│   ├── Hyprland (Wayland, tiling WM)
│   ├── Plasma (KDE, Wayland/X11)
│   ├── GNOME (Wayland)
│   └── Sway (Wayland, tiling WM)
├── Bundles Opcionais
│   ├── dev (ferramentas de desenvolvimento)
│   ├── gaming (Steam, Lutris, drivers)
│   ├── media (produção e consumo de mídia)
│   └── laptop (gestão de bateria, brilho)
└── Lib
    └── mkSpecialisation (helper para criar novas specialisations)
```

### 4.2. MVP — Versão Mínima Viável

O MVP inclui apenas:

1. `flake.nix` com nixpkgs e home-manager
2. `hosts/main/` com configuração base mínima
3. `profiles/base.nix` com componentes comuns
4. Uma specialisation funcional: **Hyprland**
5. README com instruções de uso

---

## 5. Fluxo Principal de Uso

### 5.1. Ativar um Desktop

```bash
# Usuário ativa Hyprland
nixos-rebuild switch --specialisation hyprland --flake .#main

# Usuário troca para Plasma
nixos-rebuild switch --specialisation plasma --flake .#main
```

### 5.2. Limpeza de Gerações

```bash
# Liberar espaço de gerações antigas
nix-collect-garbage -d
```

### 5.3. Adicionar Nova Specialisation

1. Criar módulo em `modules/nixos/sessions/<nome>.nix`
2. Criar módulo home em `modules/home/sessions/<nome>.nix`
3. Criar profile em `profiles/desktop/<nome>.nix`
4. Registrar specialisation em `hosts/main/default.nix`

---

## 6. Restrições e Premissas

| Tipo | Descrição |
|------|-----------|
| Restrição técnica | Requer NixOS com flakes habilitado |
| Restrição técnica | Requer nixpkgs unstable ou 24.05+ para pacotes recentes |
| Premissa | Usuário tem acesso root para `nixos-rebuild` |
| Premissa | Hardware compatível com Wayland para DEs baseados em Wayland |
| Restrição de design | Não usar scripts imperativos de pós-instalação |
| Restrição de design | Não usar stow para dotfiles |

---

## 7. Métricas de Sucesso

| Métrica | Meta |
|---------|------|
| Tempo para ativar um desktop após clone | < 30 minutos |
| Tempo para trocar de desktop | < 10 minutos (só o rebuild) |
| Número de DEs suportados no lançamento | 1 (MVP), 4 (v1.0) |
| Espaço em disco com 1 DE ativo | < 50% do que usar 4 DEs simultaneamente |

---

## 8. Roadmap

| Fase | Descrição | Entregáveis |
|------|-----------|-------------|
| MVP | Estrutura base + Hyprland | flake.nix, hosts/main, profiles/base, specialisation hyprland |
| v0.2 | Plasma e GNOME | specialisations plasma e gnome |
| v0.3 | Sway e bundles | specialisation sway, bundles dev/gaming/media/laptop |
| v1.0 | Lib e documentação | mkSpecialisation, README completo, guia de extensão |
