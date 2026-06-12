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
ask() {
  local prompt="$1"
  local default="$2"
  local result
  printf "  %s [%s]: " "$prompt" "$default" >&2
  read -r result
  echo "${result:-$default}"
}

ask_choice() {
  local prompt="$1"
  local options="$2"
  local default="$3"
  local result
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
}

print_header() {
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║          HAMRA — Wizard de Instalação        ║"
  echo "╚══════════════════════════════════════════════╝"
  echo ""
}

print_section() {
  echo ""
  echo "── $1 ──────────────────────────────────────────"
}

extract_nix_string() {
  local file="$1"
  local key="$2"
  grep -oP "${key//./\\.}\s*=\s*\"\K[^\"]+" "$file" 2>/dev/null || true
}

read_json() {
  local key="$1"
  local file="$2"
  grep -oP "\"${key}\"\s*:\s*\"\K[^\"]+" "$file" 2>/dev/null || true
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
echo "║  Configuração gerada: hosts/main/hamra.json  ║"
echo "║                                              ║"
echo "║  Próximos passos:                            ║"
echo "║  1. Revise hosts/main/hamra.json             ║"
echo "║  2. sudo nixos-rebuild switch --flake .#main ║"
echo "║  3. Reinicie                                 ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
