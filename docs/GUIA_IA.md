# Guia de Desenvolvimento Guiado por IA
## hamra

**Versão:** 1.0  
**Data:** 2025-06  

---

## 1. Propósito deste Documento

Este guia explica como usar os documentos de engenharia do projeto para guiar uma IA (Claude, Copilot, etc.) na geração de código Nix de forma precisa e consistente.

A regra de ouro é: **contexto preciso → código preciso**. Quanto mais contexto você fornecer, menos a IA vai inventar estruturas que não existem no projeto.

---

## 2. Documentos do Projeto

| Documento | Quando Usar |
|-----------|-------------|
| `PRD.md` | Contexto geral do projeto, objetivos, escopo |
| `REQUISITOS.md` | O que o sistema deve fazer (RF) e como se comportar (RNF) |
| `ADRs.md` | Por que certas decisões foram tomadas (evitar que IA sugira alternativas já descartadas) |
| `USER_STORIES.md` | O que o usuário precisa fazer — guia o que implementar primeiro |
| `ARQUITETURA.md` | Estrutura de pastas, responsabilidades, convenções — base para geração de código |

---

## 3. Templates de Prompt por Tarefa

### 3.1. Criar um novo arquivo de módulo

```
Contexto do projeto:
- [colar conteúdo relevante de ARQUITETURA.md — seções 2, 4 e 6]

Tarefa: Criar o arquivo `modules/nixos/sessions/hyprland.nix`.

Responsabilidade deste arquivo (conforme ARQUITETURA.md):
- Habilitar Hyprland no sistema NixOS
- Instalar dependências de sistema
- Usar mkIf quando necessário
- NÃO declarar opções (mkOption)
- NÃO configurar userland (isso vai em modules/home/sessions/hyprland.nix)

Requisito relacionado: RF-03 (REQUISITOS.md)
Decisão de arquitetura relacionada: ADR-002, ADR-005

Gere o arquivo seguindo as convenções de nomenclatura e regras de design do projeto.
```

---

### 3.2. Criar a estrutura de specialisations no host

```
Contexto do projeto:
- [colar conteúdo de ARQUITETURA.md — seção 4.2]
- [colar ADR-002 de ADRs.md]

Tarefa: Criar o arquivo `hosts/main/default.nix` com:
- Importação de profiles/base.nix
- Declaração das specialisations: hyprland, plasma, gnome, sway
- Opções hamra.enable, hamra.userName, hamra.gpu
- Importação de hardware-configuration.nix

Fase atual: MVP (apenas Hyprland é obrigatório; as demais podem ser comentadas)

Gere o arquivo seguindo exatamente a estrutura descrita em ARQUITETURA.md seção 4.2.
```

---

### 3.3. Expandir a API declarativa

```
Contexto do projeto:
- [colar ARQUITETURA.md seção 4.6]
- [colar RF-07 de REQUISITOS.md]
- [colar ADR-006 de ADRs.md]

Tarefa: Adicionar ao arquivo `modules/nixos/options/hamra.nix` as seguintes opções:
- hamra.bundles.dev.enable (bool, default false)
- hamra.bundles.gaming.enable (bool, default false)

Cada opção deve ter description, type e default conforme o padrão mkOption já existente.
```

---

### 3.4. Criar um novo profile de desktop

```
Contexto do projeto:
- [colar ARQUITETURA.md seções 4.3 e exemplos de profiles/desktop/hyprland.nix]
- [colar RF-04 (Plasma) de REQUISITOS.md]
- [colar ADR-005 (Display Manager) de ADRs.md]

Tarefa: Criar `profiles/desktop/plasma.nix`.

Responsabilidade: Profile não tem lógica, apenas:
- imports de modules/nixos/sessions/plasma.nix e modules/home/sessions/plasma.nix
- import de profiles/desktop/common.nix
- services.displayManager.defaultSession = "plasma"

Não adicionar lógica extra — isso vai nos módulos.
```

---

## 4. Anti-Padrões a Evitar nos Prompts

| Anti-padrão | Por quê evitar | Alternativa |
|-------------|----------------|-------------|
| "Crie uma config NixOS para Hyprland" | Sem contexto, a IA vai inventar estrutura diferente da sua | Fornecer ARQUITETURA.md e pedir arquivo específico |
| "Adicione suporte a Plasma" | Ambíguo demais | Especificar quais arquivos criar e suas responsabilidades |
| "Melhore o código" | A IA pode mudar decisões de arquitetura | Referenciar ADRs e pedir melhora específica |
| Pedir múltiplos arquivos de uma vez | Aumenta chance de inconsistências | Pedir um arquivo por vez, revisar antes de continuar |

---

## 5. Fluxo de Desenvolvimento Recomendado

```
1. Definir tarefa
   └── Consultar USER_STORIES.md para saber o que implementar

2. Identificar arquivos afetados
   └── Consultar ARQUITETURA.md para saber a estrutura

3. Verificar requisitos relacionados
   └── Consultar REQUISITOS.md para os critérios de aceitação

4. Verificar decisões de arquitetura
   └── Consultar ADRs.md para não contradizer decisões já tomadas

5. Montar prompt com contexto relevante
   └── Usar templates da seção 3 deste documento

6. Revisar código gerado
   └── Verificar se segue convenções da seção 6 de ARQUITETURA.md

7. Testar
   └── nixos-rebuild switch --specialisation <nome> --flake .#main
```

---

## 6. Checklist de Revisão de Código Gerado por IA

Antes de adicionar qualquer arquivo gerado ao projeto, verifique:

- [ ] O arquivo tem comentário de cabeçalho explicando o que faz?
- [ ] O arquivo faz apenas uma coisa?
- [ ] Módulos usam `mkOption` para opções? (apenas em `options/hamra.nix`)
- [ ] Módulos usam `mkIf` para condicionais quando necessário?
- [ ] O código não duplica lógica de outro módulo?
- [ ] Profiles só têm imports e atribuições, sem lógica?
- [ ] `flake.nix` só tem wiring, sem lógica?
- [ ] Nomenclatura segue as convenções (camelCase para opções, kebab-case para arquivos)?
- [ ] Toda opção gerada tem `description`?
- [ ] O código segue as decisões dos ADRs (ex: SDDM como DM padrão)?
