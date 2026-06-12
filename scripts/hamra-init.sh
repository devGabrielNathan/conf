#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# hamra-init.sh — Orquestrador de inicialização do Hamra
# ═══════════════════════════════════════════════════════════════
#
# Fluxo:
#   bootstrap → discovery → migration → hardware → wizard → generator → git
#
# Cada fase é implementada em scripts/lib/*.sh com responsabilidade única.
# A estrutura central CONFIG é um associative array global compartilhado.
#
# Fonte da verdade (prioridade):
#   1. hosts/main/hamra.json (configuração existente)
#   2. nix eval no flake
#   3. /etc/nixos/configuration.nix legado
#   4. Sistema atual (timedatectl, localectl, /etc/passwd)
#   5. Fallback para defaults do wizard
#
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────────────────────────
# Utilitários compartilhados (definidos antes dos módulos)
# ─────────────────────────────────────────────────────────────
detect_gum() {
  command -v gum &>/dev/null && echo true || echo false
}

HAVE_GUM=$(detect_gum)

ask() {
  local prompt="$1"
  local default="$2"
  local result
  if [ "$HAVE_GUM" = true ]; then
    result=$(gum input --placeholder "$prompt" --value "$default" --width 50)
    echo "${result:-$default}"
  else
    printf "  %s [%s]: " "$prompt" "$default" >&2
    read -r result
    echo "${result:-$default}"
  fi
}

ask_choice() {
  local prompt="$1"
  local options="$2"
  local default="$3"
  local result
  if [ "$HAVE_GUM" = true ]; then
    IFS='|' read -ra opts <<< "$options"
    result=$(gum choose "${opts[@]}" --header "$prompt")
    echo "${result:-$default}"
  else
    while true; do
      printf "  %s (%s) [%s]: " "$prompt" "$options" "$default" >&2
      read -r result
      result="${result:-$default}"
      if echo "$options" | tr '|' '\n' | grep -qx "$result"; then
        echo "$result"
        return
      fi
      echo "  Valor inválido. Escolha entre: $options" >&2
    done
  fi
}

ask_password() {
  local prompt="$1"
  local pw1 pw2
  if [ "$HAVE_GUM" = true ]; then
    while true; do
      pw1=$(gum input --password --placeholder "$prompt (Enter = 'nixos')" --width 50)
      if [ -z "$pw1" ]; then
        echo "nixos"
        return
      fi
      pw2=$(gum input --password --placeholder "Confirme a senha" --width 50)
      if [ "$pw1" = "$pw2" ]; then
        echo "$pw1"
        return
      fi
      gum style --foreground 1 "Senhas não conferem. Tente novamente."
    done
  else
    while true; do
      printf "  %s (deixe em branco para 'nixos'): " "$prompt" >&2
      read -rs pw1
      echo >&2
      if [ -z "$pw1" ]; then
        echo "nixos"
        return
      fi
      printf "  Confirme a senha: " >&2
      read -rs pw2
      echo >&2
      if [ "$pw1" = "$pw2" ]; then
        echo "$pw1"
        return
      fi
      echo "  Senhas não conferem. Tente novamente." >&2
    done
  fi
}

print_header() {
  if [ "$HAVE_GUM" = true ]; then
    gum style \
      --border double --padding "1 2" --margin "0 0" --align center \
      --foreground 212 --width 50 \
      "HAMRA" "Wizard de Instalação"
  else
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║          HAMRA — Wizard de Instalação        ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
  fi
}

print_section() {
  if [ "$HAVE_GUM" = true ]; then
    echo ""
    gum style --foreground 99 --bold "$1"
  else
    echo ""
    echo "── $1 ──────────────────────────────────────────"
  fi
}

extract_nix_string() {
  local file="$1"
  local key="$2"
  grep -oP "${key//./\\.}\s*=\s*\"\K[^\"]+" "$file" 2>/dev/null || true
}

check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "  ERRO: Execute com sudo."
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────
# Carregar módulos
# ─────────────────────────────────────────────────────────────
source "$SCRIPT_DIR/lib/bootstrap.sh"
source "$SCRIPT_DIR/lib/discovery.sh"
source "$SCRIPT_DIR/lib/migration.sh"
source "$SCRIPT_DIR/lib/hardware.sh"
source "$SCRIPT_DIR/lib/wizard.sh"
source "$SCRIPT_DIR/lib/generator.sh"
source "$SCRIPT_DIR/lib/git.sh"

# ─────────────────────────────────────────────────────────────
# Estrutura central de dados
# ─────────────────────────────────────────────────────────────
declare -A CONFIG

CONFIG[userName]=""
CONFIG[hostname]=""
CONFIG[timezone]=""
CONFIG[locale]=""
CONFIG[keymap]=""
CONFIG[gpu]=""
CONFIG[loader]=""
CONFIG[grubDevice]=""
CONFIG[session]=""
CONFIG[password]=""

# ─────────────────────────────────────────────────────────────
# Variáveis de ambiente do projeto (definidas pelo bootstrap)
# ─────────────────────────────────────────────────────────────
PROJECT_DIR=""
HW_TARGET=""
HAMRA_TARGET=""
HAMRA_JSON=""

# ─────────────────────────────────────────────────────────────
# Fluxo principal
# ─────────────────────────────────────────────────────────────
print_header
check_root
bootstrap_main
discovery_main
migration_main
hardware_main
wizard_main
generator_main
git_main

# ─────────────────────────────────────────────────────────────
# Resumo final
# ─────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║               Setup Concluído!               ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  Configuração gerada: hosts/main/hamra-config ║"
echo "║                                              ║"
echo "║  Próximos passos:                            ║"
echo "║    cd /etc/nixos                              ║"
echo "║    sudo nixos-rebuild switch --flake .#main  ║"
echo "║    sudo reboot                               ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
