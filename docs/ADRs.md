# ADR — Architecture Decision Records
## hamra

**Formato:** [Título] → Contexto → Decisão → Consequências  

---

## ADR-001 — Uso de Flakes como sistema de configuração

**Status:** Aceito  
**Data:** 2025-06  

### Contexto

NixOS pode ser configurado de duas formas principais: via `configuration.nix` tradicional com channels, ou via Flakes. Flakes são um sistema mais moderno que oferece reprodutibilidade explícita através do `flake.lock`.

### Decisão

**Usar Flakes** como base do projeto.

### Consequências

**Positivas:**
- Reprodutibilidade garantida via `flake.lock` (todas as dependências fixadas)
- Interface padronizada: `nixos-rebuild switch --flake .#host`
- Facilita composição com outros flakes (home-manager, nixpkgs)
- Amplamente adotado pela comunidade NixOS moderna

**Negativas:**
- Requer `experimental-features = nix-command flakes` habilitado
- Curva de aprendizado maior para usuários novos em NixOS
- Não compatível com configurações NixOS legadas (channels)

---

## ADR-002 — Uso de Specialisations para variações de desktop

**Status:** Aceito  
**Data:** 2025-06  

### Contexto

Para suportar múltiplos DEs/WMs sem instalá-los todos simultaneamente, existem algumas abordagens:

1. **Profiles separados por host**: criar um host por DE (main-hyprland, main-plasma, etc.)
2. **Feature flags**: uma única config com todos os DEs, habilitados/desabilitados por opção
3. **Specialisations**: variações da mesma configuração base usando o recurso nativo do NixOS

### Decisão

**Usar Specialisations** como mecanismo de variação de desktop.

### Consequências

**Positivas:**
- Mecanismo nativo do NixOS, sem hacks externos
- Uma única base de código por host, com variações bem definidas
- Troca com um único comando: `nixos-rebuild switch --specialisation <nome>`
- Entrada separada no bootloader para cada specialisation
- Isolamento real: apenas os pacotes da specialisation ativa ficam instalados

**Negativas:**
- Cada troca de specialisation requer um `nixos-rebuild` (rebuild, não instantâneo)
- Usuários menos familiarizados com NixOS podem achar o conceito não intuitivo
- Todas as specialisations devem ser declaradas no mesmo `hosts/main/default.nix`

---

## ADR-003 — Integração de Home Manager como módulo NixOS

**Status:** Aceito  
**Data:** 2025-06  

### Contexto

Home Manager pode ser usado de três formas:
1. **Standalone**: gerenciado separadamente com `home-manager switch`
2. **Módulo NixOS**: integrado ao `nixosConfigurations`, ativado junto ao `nixos-rebuild`
3. **Flake module**: importado como módulo do flake

### Decisão

**Usar Home Manager como módulo NixOS** (opção 2), integrado ao `nixosConfigurations`.

### Consequências

**Positivas:**
- Um único comando (`nixos-rebuild switch`) configura sistema e userland
- Compartilha o mesmo `nixpkgs` do sistema, evitando inconsistências
- Specialisations do NixOS se propagam automaticamente para o home-manager
- Mais simples para o usuário final

**Negativas:**
- Home Manager fica acoplado ao ciclo de rebuild do sistema
- Mudanças de dotfiles exigem `sudo nixos-rebuild`, não apenas `home-manager switch`
- Menos flexível para multi-usuário (cada usuário precisaria de config separada)

---

## ADR-004 — Estrutura de diretórios: profiles vs modules

**Status:** Aceito  
**Data:** 2025-06  

### Contexto

Em projetos NixOS, existe debate sobre a diferença entre "profiles" e "modules". Algumas configs usam apenas `modules/`, outras usam apenas `profiles/`, e outras misturam os dois.

### Decisão

**Usar dois níveis distintos:**

- `modules/`: lógica técnica com opções (`mkOption`, `mkIf`). Fazem uma única coisa. Podem ser usados em qualquer contexto.
- `profiles/`: composições de módulos com defaults. Definem o que uma "sessão Hyprland" significa em termos de módulos importados e valores padrão.

### Consequências

**Positivas:**
- Separação clara de responsabilidades
- Módulos são reutilizáveis sem carregar defaults
- Profiles são legíveis como "receitas" de configuração
- Facilita testes unitários de módulos isolados

**Negativas:**
- Dois níveis de indireção podem confundir novos contribuidores
- Requer disciplina para não misturar lógica em profiles ou defaults em modules

---

## ADR-005 — Display Manager padrão

**Status:** Aceito  
**Data:** 2025-06  

### Contexto

Cada DE/WM tem afinidade com um display manager diferente:
- Hyprland → sem DM (iniciar via TTY) ou greetd/tuigreet
- Plasma → SDDM
- GNOME → GDM
- Sway → sem DM ou greetd

Usar DMs diferentes por specialisation pode criar conflitos no mesmo host.

### Decisão

**Usar SDDM como display manager unificado** para todas as specialisations, com `defaultSession` diferente por specialisation.

### Consequências

**Positivas:**
- Um único DM em todo o sistema, sem conflitos
- SDDM funciona bem com sessões Wayland e X11
- Configuração centralizada do DM na base comum
- SDDM é leve e compatível com Hyprland, Plasma, GNOME e Sway

**Negativas:**
- GNOME é otimizado para GDM; pequenas perdas de integração possíveis
- Usuários do GNOME podem notar ausência de funcionalidades exclusivas do GDM

**Revisão futura:** Se a integração GNOME/SDDM causar problemas, pode-se criar uma opção `hamra.displayManager` para sobrescrever por specialisation.

---

## ADR-006 — GPU como opção de primeira classe

**Status:** Aceito  
**Data:** 2025-06  

### Contexto

Configuração de GPU no NixOS varia significativamente entre AMD, NVIDIA e Intel:
- AMD: amdgpu, mesa, rocm (opcional)
- NVIDIA: drivers proprietários, configuração de Wayland mais complexa
- Intel: i915, mesa

Sem uma abstração, o usuário precisaria saber qual módulo NixOS usar para cada GPU.

### Decisão

**Criar opção `hamra.gpu`** que aceita `"amd"`, `"nvidia"`, `"intel"` e configura os drivers automaticamente.

```nix
hamra.gpu = "amd";
```

### Consequências

**Positivas:**
- Onboarding simplificado: usuário não precisa saber qual módulo de GPU usar
- Configuração centralizada e documentada
- Fácil de expandir para outros valores no futuro

**Negativas:**
- Abstração pode esconder configurações avançadas que o usuário precise
- NVIDIA no NixOS tem particularidades que podem exigir opções adicionais
- Requer manutenção quando o NixOS mudar a forma de configurar drivers

---

## ADR-007 — Estratégia de nixpkgs: unstable vs stable

**Status:** Em discussão  
**Data:** 2025-06  

### Contexto

O projeto usa pacotes que podem estar desatualizados no channel estável do NixOS (ex: Hyprland evolui rapidamente). A opção é usar `nixpkgs-unstable` para ter pacotes mais recentes.

### Decisão

**Usar `nixpkgs-unstable` como input principal**, com possibilidade de fazer override para pacotes específicos se necessário.

### Consequências

**Positivas:**
- Hyprland, waybar e outros pacotes Wayland mais atualizados
- Maior compatibilidade com configurações modernas de Wayland

**Negativas:**
- nixpkgs-unstable pode ter quebras ocasionais
- Reprodutibilidade dependente do momento do `flake.lock`
- Usuários que preferem estabilidade podem ter problemas

**Revisão futura:** Considerar expor `hamra.nixpkgsChannel` para permitir ao usuário escolher.
