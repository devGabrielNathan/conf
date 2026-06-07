# Guia de Estilo - Keybinds

## Regras de formatação

### 1. Ordenação

Os atalhos são ordenados por **quantidade de teclas** (menos primeiro) e depois **alfabeticamente**:

```
# 1 tecla (apenas modifier + tecla)
${mod}+A              ...
${mod}+Return         ...

# 2 teclas (modifier + Shift + tecla)
${mod}+Shift+A        ...
${mod}+Shift+Return   ...

# 3 teclas (modifier + Alt + tecla)
${mod}+Alt+Return     ...
```

### 2. Alinhamento

A coluna de ação começa na **mesma posição** para todas as linhas de um mesmo bloco.

**Niri (KDL):**
```
${mod}+A              { spawn "chromium" "--app=https://chatgpt.com";  }
${mod}+Return         { spawn "${cfg.apps.terminal}";                   }
${mod}+Shift+A        { spawn "chromium" "--app=https://claude.ai";    }
```

**Hyprland (Nix):**
```
"${mod}, A,                      exec, chromium --app=https://chatgpt.com"
"${mod}, Return,                 exec, ${cfg.apps.terminal}"
"${mod} SHIFT, A,                exec, chromium --app=https://claude.ai"
```

### 3. Espaçamento

- **1 linha em branco** entre categorias (Aplicações, Janelas, Workspaces, etc.)
- **Sem linhas em branco** entre atalhos da mesma categoria
- **Comentário de categoria** antes de cada bloco com separadores visuais

### 4. Categorias

| Categoria | Descrição |
|-----------|-----------|
| APLICAÇÕES | Abrir apps (terminal, browser, file manager, etc.) |
| JANELAS | Gerenciar janelas (fechar, maximizar, flutuar, etc.) |
| NOCTALIA | Controles do Noctalia Shell (launcher, settings, control center) |
| UTILITÁRIOS | Ferramentas (btop, tmux, etc.) |
| WORKSPACES | Navegação entre workspaces |

### 5. Exemplo completo (Niri)

```
binds {
    // ═══════════════════════════════════════════
    // APLICAÇÕES
    // ═══════════════════════════════════════════
    ${mod}+A              { spawn "chromium" "--app=https://chatgpt.com";  }
    ${mod}+B              { spawn "${cfg.apps.browser}";                    }
    ${mod}+Return         { spawn "${cfg.apps.terminal}";                   }
    ${mod}+Space          { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }

    // ═══════════════════════════════════════════
    // JANELAS
    // ═══════════════════════════════════════════
    ${mod}+F              { maximize-window;        }
    ${mod}+Q              { close-window;           }
    ${mod}+Shift+F        { fullscreen-window;      }
    ${mod}+Shift+Q        { close-window; force-close; }
}
```

### 6. Exemplo completo (Hyprland)

```
bind = [
    # Aplicações
    "${mod}, A,                      exec, chromium --app=https://chatgpt.com"
    "${mod}, Return,                 exec, ${cfg.apps.terminal}"
    "${mod}, Space,                  exec, noctalia-shell ipc call launcher toggle"
    "${mod} SHIFT, A,                exec, chromium --app=https://claude.ai"

    # Janelas
    "${mod}, Q,                      killactive"
    "${mod}, F,                      fullscreen, maximized"
    "${mod} SHIFT, F,                fullscreen, fullscreen"
];
```
