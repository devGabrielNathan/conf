# User Stories
## hamra

**Versão:** 1.0  
**Data:** 2025-06  

---

## Épicos

| ID | Épico |
|----|-------|
| EP-01 | Onboarding e instalação |
| EP-02 | Gestão de desktops |
| EP-03 | Personalização e extensão |
| EP-04 | Manutenção e limpeza |

---

## EP-01 — Onboarding e Instalação

### US-01 — Clonar e aplicar a configuração base

**Como** usuário NixOS com flakes habilitado,  
**Quero** clonar o repositório e aplicar a configuração com comandos simples,  
**Para que** eu tenha um sistema funcional sem precisar entender toda a estrutura do projeto.

**Critérios de Aceitação:**
- `git clone` + edição mínima de `hosts/main/hardware-configuration.nix`
- `nixos-rebuild switch --flake .#main` funciona sem erros
- O sistema inicia com base comum configurada

**Prioridade:** Alta — MVP

---

### US-02 — Configurar usuário e GPU de forma declarativa

**Como** usuário que está adaptando a configuração para minha máquina,  
**Quero** declarar meu nome de usuário e tipo de GPU em um único lugar,  
**Para que** eu não precise encontrar e substituir referências espalhadas por vários arquivos.

**Critérios de Aceitação:**
- Alterar `hamra.userName = "meu-usuario"` configura o usuário em todo o sistema
- Alterar `hamra.gpu = "amd"` configura os drivers corretos automaticamente
- Erros em valores inválidos geram mensagens claras

**Prioridade:** Alta — MVP

---

## EP-02 — Gestão de Desktops

### US-03 — Ativar Hyprland como desktop principal

**Como** usuário que prefere um tiling WM Wayland,  
**Quero** ativar Hyprland com um único comando,  
**Para que** eu tenha um ambiente funcional sem configuração manual.

**Critérios de Aceitação:**
- `nixos-rebuild switch --specialisation hyprland --flake .#main` funciona
- Hyprland inicia ao fazer login no SDDM
- waybar ou alternativa está disponível
- Configuração básica de Hyprland está presente via home-manager

**Prioridade:** Alta — MVP

---

### US-04 — Trocar de Hyprland para Plasma sem reinstalar nada

**Como** usuário que quer experimentar KDE Plasma,  
**Quero** trocar de Hyprland para Plasma sem apagar minha configuração atual,  
**Para que** eu possa avaliar o Plasma e voltar ao Hyprland se quiser.

**Critérios de Aceitação:**
- `nixos-rebuild switch --specialisation plasma --flake .#main` funciona
- KDE Plasma inicia normalmente ao fazer login
- Ao trocar de volta para Hyprland, a configuração anterior ainda funciona

**Prioridade:** Média — v0.2

---

### US-05 — Verificar qual specialisation está ativa

**Como** usuário que gerencia múltiplas specialisations,  
**Quero** saber qual desktop está ativo no momento,  
**Para que** eu saiba o contexto atual do meu sistema.

**Critérios de Aceitação:**
- Existe forma documentada de verificar a specialisation ativa (variável de ambiente, arquivo, ou comando)
- README documenta como identificar a specialisation corrente

**Prioridade:** Baixa — v1.0

---

## EP-03 — Personalização e Extensão

### US-06 — Adicionar um novo DE/WM ao projeto

**Como** usuário avançado que quer usar um DE não incluído por padrão (ex: River WM),  
**Quero** adicionar uma nova specialisation seguindo a estrutura do projeto,  
**Para que** eu possa usar meu DE preferido com a mesma estrutura modular.

**Critérios de Aceitação:**
- README documenta o processo passo a passo
- `lib/mkSpecialisation.nix` fornece helper que reduz boilerplate
- A adição requer no máximo 3 novos arquivos

**Prioridade:** Baixa — v1.0

---

### US-07 — Habilitar bundle de desenvolvimento

**Como** desenvolvedor de software,  
**Quero** habilitar um bundle com ferramentas de desenvolvimento,  
**Para que** eu tenha compiladores, LSPs e ferramentas de versionamento prontos para uso.

**Critérios de Aceitação:**
- `hamra.bundles.dev.enable = true` adiciona as ferramentas ao sistema
- Bundle inclui: git, neovim/vscode, compilador base, ferramentas de build
- Bundle é independente do desktop ativo

**Prioridade:** Baixa — v0.3

---

### US-08 — Habilitar suporte a jogos

**Como** usuário que quer jogar no Linux,  
**Quero** habilitar um bundle de gaming,  
**Para que** eu tenha Steam, Lutris e otimizações de performance configuradas.

**Critérios de Aceitação:**
- `hamra.bundles.gaming.enable = true` instala e configura Steam e Lutris
- gamemode configurado e funcional
- Drivers de jogo corretos aplicados conforme `hamra.gpu`

**Prioridade:** Baixa — v0.3

---

## EP-04 — Manutenção e Limpeza

### US-09 — Liberar espaço de gerações antigas

**Como** usuário que acumulou várias gerações de specialisations,  
**Quero** limpar as gerações antigas de forma segura,  
**Para que** eu recupere espaço em disco sem perder a geração atual.

**Critérios de Aceitação:**
- `nix-collect-garbage -d` remove gerações antigas
- A geração atual permanece intacta
- README documenta o processo de limpeza

**Prioridade:** Média — MVP

---

### US-10 — Atualizar pacotes da configuração

**Como** usuário que quer manter o sistema atualizado,  
**Quero** atualizar as dependências do flake e reconstruir o sistema,  
**Para que** eu tenha os pacotes mais recentes sem quebrar a reprodutibilidade.

**Critérios de Aceitação:**
- `nix flake update` atualiza `flake.lock` com as versões mais recentes
- `nixos-rebuild switch --flake .#main` aplica as atualizações
- `flake.lock` é commitado junto à configuração para reprodutibilidade

**Prioridade:** Média — MVP

---

## Mapa de Prioridades

| User Story | Prioridade | Fase |
|-----------|------------|------|
| US-01 | Alta | MVP |
| US-02 | Alta | MVP |
| US-03 | Alta | MVP |
| US-09 | Média | MVP |
| US-10 | Média | MVP |
| US-04 | Média | v0.2 |
| US-07 | Baixa | v0.3 |
| US-08 | Baixa | v0.3 |
| US-05 | Baixa | v1.0 |
| US-06 | Baixa | v1.0 |
