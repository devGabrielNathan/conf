#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# hamra-init.sh — Wizard de inicialização do Hamra
# ═══════════════════════════════════════════════════════════════
# Não modifica nenhum módulo do framework.
# Apenas gera hosts/main/hamra.nix com os valores do usuário.
#
# Fases:
#   1. Detectar hardware (nixos-generate-config ou copiar backup)
#   2. Importar config existente (/etc/nixos/configuration.nix)
#   3. Wizard interativo — preencher o que falta
#   4. Gerar hosts/main/hamra.nix
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

PROJECT_DIR="${HAMRA_PROJECT_DIR:-/etc/nixos}"
HW_TARGET="$PROJECT_DIR/hosts/main/hardware-configuration.nix"
HAMRA_TARGET="$PROJECT_DIR/hosts/main/hamra.nix"
CALAMARES_CONF="/etc/nixos.bak/configuration.nix"
CALAMARES_HW="/etc/nixos.bak/hardware-configuration.nix"
SYS_CONF="/etc/nixos/configuration.nix"

# ─────────────────────────────────────────────────────────────
# Utilitários
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
  local options="$2"   # ex: "amd|nvidia|intel|none"
  local default="$3"
  local result
  while true; do
    printf "  %s (%s) [%s]: " "$prompt" "$options" "$default" >&2
    read -r result
    result="${result:-$default}"
    if echo "$options" | grep -qw "$result"; then
      echo "$result"
      return
    fi
    echo "  Valor inválido. Escolha entre: $options" >&2
  done
}

detect_gpu() {
  # 1. Tentar via sysfs (mais confiável em ambientes mínimos e não depende de lspci)
  if [ -d /sys/class/drm ]; then
    local uevents
    uevents=$(cat /sys/class/drm/card*/device/uevent 2>/dev/null || true)
    if [ -n "$uevents" ]; then
      if echo "$uevents" | grep -qi "PCI_ID=10de:\|DRIVER=nvidia\|DRIVER=nouveau"; then
        echo "nvidia"
        return
      elif echo "$uevents" | grep -qi "PCI_ID=1002:\|DRIVER=amdgpu\|DRIVER=radeon"; then
        echo "amd"
        return
      elif echo "$uevents" | grep -qi "PCI_ID=8086:\|DRIVER=i915\|DRIVER=xe"; then
        echo "intel"
        return
      elif echo "$uevents" | grep -qiE "DRIVER=virtio|DRIVER=vmwgfx|DRIVER=vboxvideo|DRIVER=qxl"; then
        echo "none"
        return
      fi
    fi
  fi

  # 2. Fallback para lspci
  local lspci_cmd="lspci"
  if ! command -v lspci &>/dev/null; then
    if [ -f "/usr/bin/lspci" ]; then
      lspci_cmd="/usr/bin/lspci"
    elif [ -f "/run/current-system/sw/bin/lspci" ]; then
      lspci_cmd="/run/current-system/sw/bin/lspci"
    else
      echo "none"
      return
    fi
  fi

  local gpu_info
  gpu_info=$($lspci_cmd | grep -i "vga\|3d\|display" || true)
  if echo "$gpu_info" | grep -qi "nvidia"; then
    echo "nvidia"
  elif echo "$gpu_info" | grep -qi "amd\|radeon"; then
    echo "amd"
  elif echo "$gpu_info" | grep -qi "intel"; then
    echo "intel"
  else
    echo "none"
  fi
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

# ─────────────────────────────────────────────────────────────
# FASE 0 — Copiar e configurar /etc/nixos se necessário
# ─────────────────────────────────────────────────────────────
setup_etc_nixos() {
  local target_dir="/etc/nixos"
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local source_dir
  source_dir="$(dirname "$script_dir")"

  # Se o diretório atual de onde o script está rodando já for /etc/nixos, não precisamos copiar
  if [ "$source_dir" = "$target_dir" ]; then
    echo "  ✓ Executando diretamente de $target_dir"
    return
  fi

  print_section "Configurando /etc/nixos"

  if [ -d "$target_dir" ]; then
    if [ ! -f "$target_dir/flake.nix" ]; then
      echo "  Detectado /etc/nixos existente (sem flake.nix)."
      echo "  Fazendo backup de $target_dir para /etc/nixos.bak..."
      rm -rf /etc/nixos.bak
      mv "$target_dir" /etc/nixos.bak
      echo "  ✓ Backup concluído."
    else
      echo "  Aviso: $target_dir já contém uma configuração baseada em flakes."
      local confirm
      confirm=$(ask "Deseja sobrescrever /etc/nixos com os arquivos do Hamra?" "s")
      if [ "$confirm" = "s" ] || [ "$confirm" = "S" ]; then
        echo "  Fazendo backup da configuração antiga para /etc/nixos.old..."
        rm -rf /etc/nixos.old
        mv "$target_dir" /etc/nixos.old
      else
        echo "  Usando o diretório atual ($source_dir) como base do projeto."
        PROJECT_DIR="$source_dir"
        HW_TARGET="$PROJECT_DIR/hosts/main/hardware-configuration.nix"
        HAMRA_TARGET="$PROJECT_DIR/hosts/main/hamra.nix"
        return
      fi
    fi
  fi

  echo "  Copiando arquivos do projeto para $target_dir..."
  mkdir -p "$target_dir"
  cp -r "$source_dir"/. "$target_dir"/
  
  PROJECT_DIR="$target_dir"
  HW_TARGET="$PROJECT_DIR/hosts/main/hardware-configuration.nix"
  HAMRA_TARGET="$PROJECT_DIR/hosts/main/hamra.nix"
  
  echo "  ✓ Arquivos copiados com sucesso para $PROJECT_DIR."
}

post_setup_git() {
  if command -v git &>/dev/null; then
    if git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
      echo "  ✓ Repositório Git ativo em $PROJECT_DIR."
      git -C "$PROJECT_DIR" add -A || true
    else
      echo "  Inicializando repositório Git em $PROJECT_DIR..."
      if git -C "$PROJECT_DIR" init && git -C "$PROJECT_DIR" add -A; then
        echo "  ✓ Repositório Git inicializado e arquivos adicionados."
      else
        echo "  [AVISO]: Falha ao inicializar o Git."
      fi
    fi
  else
    echo ""
    echo "  [AVISO]: O comando 'git' não está instalado neste ambiente."
    echo "  O NixOS continuará compilando a configuração via path local normal,"
    echo "  mas recomendamos instalar o git para obter os benefícios do Nix Flakes."
  fi
}

# ─────────────────────────────────────────────────────────────
# FASE 1 — Hardware
# ─────────────────────────────────────────────────────────────
phase1_hardware() {
  print_section "FASE 1: Hardware"

  if [ -f "$HW_TARGET" ] && grep -q "fileSystems" "$HW_TARGET" 2>/dev/null; then
    echo "  ✓ hardware-configuration.nix já existe"
    return
  fi

  if [ -f "$CALAMARES_HW" ]; then
    echo "  Copiando hardware-configuration.nix do Calamares..."
    cp "$CALAMARES_HW" "$HW_TARGET"
    echo "  ✓ Copiado de /etc/nixos.bak/"
  else
    echo "  Gerando hardware-configuration.nix via nixos-generate-config..."
    nixos-generate-config --show-hardware-config > "$HW_TARGET"
    echo "  ✓ Gerado"
  fi

  if ! grep -q "fileSystems" "$HW_TARGET" 2>/dev/null; then
    echo "  ERRO: hardware-configuration.nix inválido"
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────
# FASE 2 — Importar config existente
# ─────────────────────────────────────────────────────────────
DETECTED_HOSTNAME="nixos"
DETECTED_TIMEZONE="America/Sao_Paulo"
DETECTED_LOCALE="pt_BR.UTF-8"
DETECTED_KEYMAP="us"
DETECTED_USER=""
DETECTED_GPU=""
DETECTED_LOADER="grub"
DETECTED_GRUB_DEV="/dev/sda"

phase2_import() {
  print_section "FASE 2: Importar configuração existente"

  local conf_file=""
  if [ -f "$CALAMARES_CONF" ]; then
    conf_file="$CALAMARES_CONF"
    echo "  Lendo configuração do Calamares em /etc/nixos.bak/..."
  elif [ -f "$SYS_CONF" ]; then
    conf_file="$SYS_CONF"
    echo "  Lendo /etc/nixos/configuration.nix existente..."
  else
    echo "  Nenhuma configuração encontrada. Usando valores padrão."
    return
  fi

  DETECTED_HOSTNAME=$(grep -oP 'networking\.hostName\s*=\s*"\K[^"]+' "$conf_file" 2>/dev/null || echo "nixos")
  DETECTED_TIMEZONE=$(grep -oP 'time\.timeZone\s*=\s*"\K[^"]+' "$conf_file" 2>/dev/null || echo "America/Sao_Paulo")
  DETECTED_LOCALE=$(grep -oP 'i18n\.defaultLocale\s*=\s*"\K[^"]+' "$conf_file" 2>/dev/null || echo "pt_BR.UTF-8")
  DETECTED_KEYMAP=$(grep -oP 'console\.keyMap\s*=\s*"\K[^"]+' "$conf_file" 2>/dev/null || echo "us")
  DETECTED_GRUB_DEV=$(grep -oP 'boot\.loader\.grub\.device\s*=\s*"\K[^"]+' "$conf_file" 2>/dev/null || echo "/dev/sda")

  # Detectar tipo de loader
  if grep -q "boot.loader.systemd-boot.enable = true" "$conf_file" 2>/dev/null; then
    DETECTED_LOADER="systemd-boot"
  fi

  # Detectar usuário
  DETECTED_USER=$(grep -oP 'users\.users\."?\K[^"]+(?="?\s*=\s*\{)' "$conf_file" 2>/dev/null | head -1 || true)
  if [ -z "$DETECTED_USER" ]; then
    DETECTED_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" && $1 != "nfsnobody" {print $1; exit}' /etc/passwd 2>/dev/null || echo "nixos")
  fi

  # Detectar GPU
  DETECTED_GPU=$(detect_gpu)

  echo "  ✓ Detectado: user=$DETECTED_USER, host=$DETECTED_HOSTNAME, tz=$DETECTED_TIMEZONE, gpu=$DETECTED_GPU"
}

# ─────────────────────────────────────────────────────────────
# FASE 3 — Wizard interativo
# ─────────────────────────────────────────────────────────────
phase3_wizard() {
  print_section "FASE 3: Confirmar valores"
  echo "  Pressione Enter para aceitar o valor detectado."
  echo ""

  local userName
  local hostname
  local timezone
  local locale
  local keymap
  local gpu
  local loader
  local grubDevice
  local session

  userName=$(ask "Nome do usuário"   "${DETECTED_USER:-nixos}")
  hostname=$(ask "Hostname"          "${DETECTED_HOSTNAME:-nixos}")
  timezone=$(ask "Timezone"          "${DETECTED_TIMEZONE:-America/Sao_Paulo}")
  locale=$(ask   "Locale"            "${DETECTED_LOCALE:-pt_BR.UTF-8}")
  keymap=$(ask   "Keymap (console)"  "${DETECTED_KEYMAP:-us-acentos}")
  gpu=$(ask      "GPU (amd/nvidia/intel/none)" "${DETECTED_GPU:-none}")
  loader=$(ask   "Bootloader (grub/systemd-boot)" "${DETECTED_LOADER:-grub}")

  grubDevice="/dev/sda"
  if [ "$loader" = "grub" ]; then
    grubDevice=$(ask "Dispositivo GRUB (ex: /dev/sda)" "${DETECTED_GRUB_DEV:-/dev/sda}")
  fi

  session=$(ask "Sessão padrão (hyprland-caelestia/plasma/gnome)" "hyprland-caelestia")

  # ─────────────────────────────────────────────────────────────
  # FASE 4 — Gerar hamra.nix
  # ─────────────────────────────────────────────────────────────
  print_section "FASE 4: Gerando hosts/main/hamra.nix"

  local bootConfig
  if [ "$loader" = "systemd-boot" ]; then
    bootConfig="      loader = \"systemd-boot\";"
  else
    bootConfig="      loader = \"grub\";
      grub.device = \"${grubDevice}\";"
  fi

  cat > "$HAMRA_TARGET" <<NIXEOF
# ═══════════════════════════════════════════════════════════════
# HAMRA.NIX — configuração específica desta máquina
# ═══════════════════════════════════════════════════════════════
# Gerado por: scripts/hamra-init.sh em $(date '+%Y-%m-%d %H:%M')
# Pode ser editado manualmente após a geração.
#
# Este arquivo NÃO deve ser modificado pelos módulos do framework.
# Para regenerar: bash scripts/hamra-init.sh
# ═══════════════════════════════════════════════════════════════
{ lib, ... }:
{
  hamra = {
    # ── Identidade ─────────────────────────────────────────────
    userName = "${userName}";

    # ── Sistema ────────────────────────────────────────────────
    system = {
      hostname = "${hostname}";
      timezone = "${timezone}";
      locale   = "${locale}";
      keymap   = "${keymap}";
    };

    # ── Boot ───────────────────────────────────────────────────
    boot = {
${bootConfig}
    };

    # ── GPU ────────────────────────────────────────────────────
    gpu = "${gpu}";

    # ── Sessão ─────────────────────────────────────────────────
    sessions.${session} = true;
    defaultSession      = "${session}";

    # ── Manutenção ─────────────────────────────────────────────
    maintenance.gc = {
      enable         = true;
      maxGenerations = 10;
      schedule       = "weekly";
      keepDays       = 30;
    };
  };
}
NIXEOF

  echo "  ✓ Gerado: $HAMRA_TARGET"

  # Também atualiza Home Manager no default.nix com o usuário correto
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║               Setup Concluído!               ║"
  echo "╠══════════════════════════════════════════════╣"
  echo "║  Arquivo gerado: hosts/main/hamra.nix        ║"
  echo "║                                              ║"
  echo "║  Próximos passos:                            ║"
  echo "║  1. Revise hosts/main/hamra.nix              ║"
  echo "║  2. sudo nixos-rebuild switch --flake .#main ║"
  echo "║  3. Reinicie                                 ║"
  echo "╚══════════════════════════════════════════════╝"
  echo ""
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────
print_header

if [ "$EUID" -ne 0 ]; then
  echo "  ERRO: Execute com sudo."
  exit 1
fi

setup_etc_nixos
phase1_hardware
phase2_import
phase3_wizard
post_setup_git
