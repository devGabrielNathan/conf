# Requisitos Funcionais e Não Funcionais
## hamra

**Versão:** 1.0  
**Data:** 2025-06  
**Status:** Em definição  

---

## 1. Requisitos Funcionais

Requisitos funcionais descrevem **o que o sistema faz** — comportamentos e funcionalidades observáveis pelo usuário.

### RF-01 — Ativação de Desktop via Specialisation

**Descrição:** O sistema deve permitir que o usuário ative um DE/WM específico executando um único comando.

**Critério de Aceitação:**
- O comando `nixos-rebuild switch --specialisation <nome> --flake .#<host>` deve funcionar sem erros
- Após o rebuild, o display manager deve apresentar a sessão correspondente como padrão
- Apenas os pacotes do DE/WM ativo devem estar instalados na geração atual

**Prioridade:** Alta — MVP

---

### RF-02 — Configuração Base Comum

**Descrição:** O sistema deve fornecer uma camada base com componentes compartilhados entre todos os desktops.

**Critério de Aceitação:**
- Shell configurado (zsh ou bash com aliases básicos)
- Git configurado com opções básicas
- Terminal emulador disponível
- Fontes essenciais instaladas
- Áudio funcionando (pipewire ou pulseaudio)
- Polkit configurado
- XDG portals configurados

**Prioridade:** Alta — MVP

---

### RF-03 — Suporte a Hyprland

**Descrição:** O sistema deve fornecer uma specialisation funcional para Hyprland.

**Critério de Aceitação:**
- Hyprland inicia corretamente ao selecionar a specialisation
- `defaultSession` do display manager aponta para Hyprland
- Configuração básica de Hyprland via home-manager disponível
- waybar, wofi ou launcher básico disponível

**Prioridade:** Alta — MVP

---

### RF-04 — Suporte a Plasma (KDE)

**Descrição:** O sistema deve fornecer uma specialisation funcional para KDE Plasma.

**Critério de Aceitação:**
- Plasma inicia corretamente com SDDM como display manager
- `defaultSession` aponta para Plasma (Wayland preferencialmente)
- Pacotes core do Plasma instalados (plasma-desktop, dolphin, konsole)

**Prioridade:** Média — v0.2

---

### RF-05 — Suporte a GNOME

**Descrição:** O sistema deve fornecer uma specialisation funcional para GNOME.

**Critério de Aceitação:**
- GNOME inicia corretamente com GDM como display manager
- `defaultSession` aponta para GNOME (Wayland)
- Pacotes core do GNOME instalados (gnome-shell, nautilus, gnome-terminal)

**Prioridade:** Média — v0.2

---

### RF-06 — Suporte a Sway

**Descrição:** O sistema deve fornecer uma specialisation funcional para Sway.

**Critério de Aceitação:**
- Sway inicia corretamente via display manager ou TTY
- Configuração básica de Sway via home-manager disponível
- waybar e launcher básico disponível

**Prioridade:** Média — v0.3

---

### RF-07 — API Declarativa

**Descrição:** O sistema deve expor uma API de opções NixOS para configuração simplificada.

**Critério de Aceitação:**
- Opção `hamra.enable` habilita o sistema
- Opção `hamra.userName` define o usuário principal
- Opção `hamra.gpu` aceita valores `"amd"`, `"nvidia"`, `"intel"` e configura drivers corretamente
- Opções inválidas devem gerar erros descritivos

**Exemplo de Uso:**
```nix
hamra = {
  enable = true;
  userName = "alice";
  gpu = "amd";
};
```

**Prioridade:** Alta — MVP

---

### RF-08 — Isolamento de Pacotes por Specialisation

**Descrição:** Ao trocar de specialisation, os pacotes do DE/WM anterior não devem estar disponíveis na geração ativa.

**Critério de Aceitação:**
- Após `nixos-rebuild switch --specialisation plasma`, os binários do Hyprland não devem estar no PATH
- O espaço em disco ocupado por uma geração deve corresponder apenas ao DE/WM ativo + base
- `nix-collect-garbage -d` deve liberar o espaço das gerações antigas

**Prioridade:** Alta — MVP

---

### RF-09 — Bundles Opcionais

**Descrição:** O sistema deve fornecer conjuntos opcionais de pacotes por finalidade.

**Critério de Aceitação:**
- Bundle `dev`: editores, compiladores, LSPs, ferramentas de versionamento
- Bundle `gaming`: Steam, Lutris, drivers de jogo, gamemode
- Bundle `media`: OBS, Kdenlive/Resolve, players de mídia, codecs
- Bundle `laptop`: TLP, powertop, gestão de brilho, bluetooth

**Prioridade:** Baixa — v0.3

---

### RF-10 — Extensibilidade para Novos Desktops

**Descrição:** O sistema deve permitir que o usuário adicione uma nova specialisation sem modificar o core do projeto.

**Critério de Aceitação:**
- Documentação descreve o processo de adição de nova specialisation
- `lib/mkSpecialisation.nix` fornece helper para criação de novas specialisations
- A adição de um novo DE/WM requer no máximo 3 arquivos novos

**Prioridade:** Baixa — v1.0

---

## 2. Requisitos Não Funcionais

Requisitos não funcionais descrevem **como o sistema se comporta** — qualidades do sistema.

### RNF-01 — Reprodutibilidade

**Categoria:** Confiabilidade

**Descrição:** O sistema deve produzir resultados idênticos quando aplicado em máquinas diferentes com o mesmo hardware, dado o mesmo flake.lock.

**Critério de Aceitação:**
- O uso de `flake.lock` deve fixar todas as dependências
- Dois `nixos-rebuild switch` com o mesmo flake.lock devem produzir o mesmo resultado
- Não deve haver dependência de estado externo ao repositório

**Prioridade:** Alta

---

### RNF-02 — Modularidade

**Categoria:** Manutenibilidade

**Descrição:** O sistema deve ser organizado em módulos independentes com responsabilidades bem definidas.

**Critério de Aceitação:**
- Cada módulo deve fazer uma única coisa (SRP)
- Módulos não devem ter dependências circulares
- Um módulo deve poder ser removido sem quebrar outros módulos não relacionados
- Cada arquivo deve ter um comentário de cabeçalho explicando sua função

**Prioridade:** Alta

---

### RNF-03 — Tempo de Build

**Categoria:** Performance

**Descrição:** O tempo de rebuild ao trocar de specialisation deve ser aceitável para uso diário.

**Critério de Aceitação:**
- Primeiro build de uma specialisation (cold cache): < 60 minutos
- Rebuild da mesma specialisation sem mudanças: < 5 minutos
- Troca entre specialisations com cache quente: < 20 minutos

**Prioridade:** Média

---

### RNF-04 — Espaço em Disco

**Categoria:** Eficiência

**Descrição:** Manter uma única specialisation ativa deve ocupar significativamente menos espaço que instalar todos os DEs simultaneamente.

**Critério de Aceitação:**
- Uma geração com 1 DE ativo deve ocupar menos de 60% do espaço de uma configuração com 4 DEs
- Após `nix-collect-garbage -d`, gerações antigas devem ser removidas completamente

**Prioridade:** Média

---

### RNF-05 — Legibilidade do Código

**Categoria:** Manutenibilidade

**Descrição:** O código Nix deve ser legível e seguir convenções da comunidade NixOS.

**Critério de Aceitação:**
- Usar `mkOption` para todas as opções expostas
- Usar `mkIf` para condicionais
- Evitar lógica complexa em `flake.nix`
- Nomenclatura consistente em todos os arquivos
- Sem duplicação de código entre specialisations

**Prioridade:** Alta

---

### RNF-06 — Compatibilidade de Hardware

**Categoria:** Portabilidade

**Descrição:** O sistema deve funcionar com as principais configurações de GPU do mercado.

**Critério de Aceitação:**
- GPU AMD: drivers amdgpu configurados corretamente
- GPU NVIDIA: drivers proprietários ou nouveau configurados via `hamra.gpu = "nvidia"`
- GPU Intel: drivers Intel configurados via `hamra.gpu = "intel"`
- Configuração de GPU incorreta deve gerar aviso descritivo

**Prioridade:** Média

---

### RNF-07 — Documentação

**Categoria:** Usabilidade

**Descrição:** O projeto deve ser autodocumentado e ter README suficiente para onboarding sem suporte externo.

**Critério de Aceitação:**
- README explica o que é o projeto em ≤ 3 parágrafos
- README contém passos de instalação reproduzíveis
- README explica como trocar de desktop
- README explica como adicionar nova specialisation
- Cada módulo Nix tem comentário de cabeçalho
- Cada opção tem `description` no `mkOption`

**Prioridade:** Alta

---

### RNF-08 — Ausência de Imperativos

**Categoria:** Confiabilidade

**Descrição:** O sistema não deve depender de scripts imperativos de pós-instalação ou stow.

**Critério de Aceitação:**
- Nenhum script shell de pós-instalação obrigatório
- Dotfiles gerenciados exclusivamente via home-manager
- Nenhum uso de `stow`, `rsync`, ou `cp` para configuração

**Prioridade:** Alta

---

## 3. Matriz de Rastreabilidade

| Requisito | Componente | Fase |
|-----------|------------|------|
| RF-01 | hosts/main/default.nix + specialisations | MVP |
| RF-02 | profiles/base.nix | MVP |
| RF-03 | profiles/desktop/hyprland.nix | MVP |
| RF-04 | profiles/desktop/plasma.nix | v0.2 |
| RF-05 | profiles/desktop/gnome.nix | v0.2 |
| RF-06 | profiles/desktop/sway.nix | v0.3 |
| RF-07 | modules/nixos/options/hamra.nix | MVP |
| RF-08 | specialisations por host | MVP |
| RF-09 | modules/bundles/ | v0.3 |
| RF-10 | lib/mkSpecialisation.nix | v1.0 |
| RNF-01 | flake.lock + flake.nix | MVP |
| RNF-02 | Estrutura de módulos | MVP |
| RNF-05 | Todos os módulos .nix | MVP |
| RNF-07 | README.md + comentários | v1.0 |
