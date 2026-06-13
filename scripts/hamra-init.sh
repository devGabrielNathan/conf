#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# HAMRA — Wizard de Inicialização do NixOS
# ═══════════════════════════════════════════════════════════════
# Pré-requisitos: git
# Uso: sudo bash scripts/hamra-init.sh
# ═══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"

# ── Cores ────────────────────────────────────────────────────
RST=$(tput sgr0); BLD=$(tput bold)
RED=$(tput setaf 1); GRN=$(tput setaf 2); YLW=$(tput setaf 3); BLU=$(tput setaf 4); CYN=$(tput setaf 6)

# ── Estado ────────────────────────────────────────────────────
declare -A CONFIG
CONFIG=( [userName]="" [fullName]="" [email]="" [hostname]="" [timezone]="" [locale]="" [keymap]=""
         [gpu]="" [loader]="" [grubDevice]="" [session]="" [password]="" )
PROJECT_DIR=""; HW_TARGET=""; HAMRA_CONFIG=""
PASSWORD_EXISTS=false; CONFIG_LOADED=false

# ── Utilitários ──────────────────────────────────────────────
logo() {
  clear
  local art; art=$(cat << 'ART'
 _   _
| | | | __ _ _ __ ___  _ __ __ _
| |_| |/ _` | '_ ` _ \| '__/ _` |
|  _  | (_| | | | | | | | | (_| |
|_| |_|\__,_|_| |_| |_|_|  \__,_|
ART
)
  printf "%b%s%b\n\n" "${BLD}${CYN}" "$art" "${RST}"
  printf "  %b%s%b\n"  "${BLD}${GRN}" "Hamra — Wizard de Inicializacao do NixOS" "${RST}"
  printf "  %b%s%b\n\n" "${BLU}" "$1" "${RST}"
}

ok()   { printf "  %b✓%b %s\n" "$GRN" "$RST" "$1"; }
info() { printf "  %b•%b %s\n" "$BLU" "$RST" "$1"; }
warn() { printf "  %b⚠%b %s\n" "$YLW" "$RST" "$1"; }
err()  { printf "  %b✗%b %s\n" "$RED" "$RST" "$1"; }

check_root() { [ "$EUID" -eq 0 ] || { err "Execute com sudo"; exit 1; }; }

nix_read() { grep -oP "${2//./\\.}\s*=\s*\"\K[^\"]+" "$1" 2>/dev/null || true; }

prompt_yn() {
  while :; do
    printf "  ${BLD}${GRN}%s${RST} [y/N]: " "$1"
    read -r yn
    case "$yn" in [Yy]) return 0;; [Nn]|"") return 1;; *) ;; esac
  done
}

prompt_val() {
  local val
  printf "  ${BLD}${CYN}%s${RST} [%s]: " "$1" "$2" >&2
  read -r val; echo "${val:-$2}"
}

prompt_required() {
  local val
  while true; do
    printf "  ${BLD}${RED}%s${RST} (obrigatório): " "$1" >&2
    read -r val
    [ -n "$val" ] && echo "$val" && return
    err "Valor obrigatório"
  done
}

prompt_choice() {
  local val
  while true; do
    printf "  ${BLD}${CYN}%s${RST} (%s) [%s]: " "$1" "$2" "$3" >&2
    read -r val; val="${val:-$3}"
    echo "$2" | tr '|' '\n' | grep -qx "$val" && echo "$val" && return
    err "Valor invalido. Escolha entre: $2"
  done
}

prompt_pass() {
  local pw1 pw2
  while true; do
    printf "  ${BLD}${CYN}Senha${RST} (Enter = nixos): " >&2
    read -rs pw1; echo >&2
    [ -z "$pw1" ] && echo "nixos" && return
    printf "  ${BLD}${CYN}Confirme${RST}: " >&2
    read -rs pw2; echo >&2
    [ "$pw1" = "$pw2" ] && echo "$pw1" && return
    err "Senhas nao conferem"
  done
}

# ── Aliases para compatibilidade com módulos ────────────────
ask()            { prompt_val "$@"; }
ask_required()   { prompt_required "$@"; }
ask_choice()     { prompt_choice "$@"; }
ask_password()   { prompt_pass "$@"; }
log_ok()       { ok "$@"; }
log_info()     { info "$@"; }
log_warn()     { warn "$@"; }
log_error()    { err "$@"; }

# ── Módulos ──────────────────────────────────────────────────
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/setup.sh"
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/wizard.sh"
source "$SCRIPT_DIR/lib/generate.sh"

# ── Fases ────────────────────────────────────────────────────
logo "Bem-vindo ao Hamra"
info "Este wizard vai preparar seu NixOS com a configuracao Hamra"
info "Ele vai:"
info "  Copiar os arquivos para /etc/nixos e iniciar git"
info "  Detectar configuracao existente, GPU e hardware"
info "  Perguntar dados do usuario, sistema e sessao"
info "  Gerar a configuracao e definir a senha"
echo ""

prompt_yn "Deseja continuar?" || { info "Cancelado"; exit 0; }
echo ""

# ── Fase 1: Setup ────────────────────────────────────────────
logo "[1/4] Setup — preparando ambiente"
setup_main
sleep 1

# ── Fase 2: Deteccao ─────────────────────────────────────────
logo "[2/4] Deteccao — lendo configuracoes"
detect_main
sleep 1

# ── Fase 3: Wizard ───────────────────────────────────────────
logo "[3/4] Wizard — preenchendo dados"
wizard_main
sleep 1

# ── Fase 4: Geracao ──────────────────────────────────────────
logo "[4/4] Geracao — escrevendo arquivos"
generate_main
sleep 1

# ── Conclusao ────────────────────────────────────────────────
logo "Instalacao concluida!"
echo "  ${BLD}${GRN}Proximos passos:${RST}"
echo ""
echo "  ${BLD}cd /etc/nixos${RST}"
echo "  ${BLD}sudo nixos-rebuild switch --flake .#main${RST}"
echo "  ${BLD}sudo reboot${RST}"
echo ""

if prompt_yn "Deseja reiniciar agora?"; then
  echo ""
  info "Reiniciando..."
  sleep 1
  sudo reboot
fi
