#!/usr/bin/env bash
# hardware.sh — Detecta hardware do sistema
#
# GPU detection via PCI Vendor IDs (não depende de drivers):
#   10de → nvidia
#   1002 → amd
#   8086 → intel
#
# Ordem de detecção:
#   1. PCI class via sysfs (/sys/bus/pci/devices/*/class + vendor)
#   2. DRM uevent (/sys/class/drm/card*/device/uevent)
#   3. lspci (fallback clássico)
#
# Gera hardware-configuration.nix se ausente.
# Apenas preenche CONFIG[gpu] se estiver vazio.

hardware_main() {
  print_section "Hardware"

  # ── hardware-configuration.nix ──────────────────────────────
  if [ -f "$HW_TARGET" ] && grep -q "fileSystems" "$HW_TARGET" 2>/dev/null; then
    echo "  ✓ hardware-configuration.nix já existe"
  else
    if [ -f "/etc/nixos.bak/hardware-configuration.nix" ]; then
      echo "  Copiando hardware-configuration.nix do Calamares..."
      cp "/etc/nixos.bak/hardware-configuration.nix" "$HW_TARGET"
    else
      echo "  Gerando hardware-configuration.nix..."
      nixos-generate-config --show-hardware-config > "$HW_TARGET"
    fi

    if ! grep -q "fileSystems" "$HW_TARGET" 2>/dev/null; then
      echo "  ERRO: hardware-configuration.nix inválido"
      exit 1
    fi
    echo "  ✓ hardware-configuration.nix pronto"
  fi

  # ── GPU ─────────────────────────────────────────────────────
  if [ -n "${CONFIG[gpu]}" ]; then
    echo "  GPU já configurada: ${CONFIG[gpu]}"
    return
  fi

  CONFIG[gpu]=$(detect_gpu)
  if [ -n "${CONFIG[gpu]}" ]; then
    echo "  GPU detectada: ${CONFIG[gpu]}"
  else
    echo "  GPU não detectada."
  fi
}

detect_gpu() {
  local gpu

  # 1. PCI vendor ID via sysfs (sem dependências externas)
  gpu=$(detect_gpu_pci_sysfs)
  [ -n "$gpu" ] && echo "$gpu" && return

  # 2. DRM uevent
  gpu=$(detect_gpu_drm)
  [ -n "$gpu" ] && echo "$gpu" && return

  # 3. lspci
  gpu=$(detect_gpu_lspci)
  [ -n "$gpu" ] && echo "$gpu" && return

  echo ""
}

detect_gpu_pci_sysfs() {
  for dev in /sys/bus/pci/devices/*; do
    local class vendor
    class=$(cat "$dev/class" 2>/dev/null || true)
    vendor=$(cat "$dev/vendor" 2>/dev/null || true)
    # PCI class 0x03xxxx = Display controller
    if [[ "$class" =~ ^0x03 ]]; then
      case "${vendor#0x}" in
        10de*) echo "nvidia"; return ;;
        1002*) echo "amd";    return ;;
        8086*) echo "intel";  return ;;
      esac
    fi
  done
  echo ""
}

detect_gpu_drm() {
  if [ ! -d /sys/class/drm ]; then
    echo ""
    return
  fi
  local uevents
  uevents=$(cat /sys/class/drm/card*/device/uevent 2>/dev/null || true)
  if [ -z "$uevents" ]; then
    echo ""
    return
  fi
  if echo "$uevents" | grep -qi "PCI_ID=10de:"; then echo "nvidia"; return; fi
  if echo "$uevents" | grep -qi "PCI_ID=1002:"; then echo "amd";    return; fi
  if echo "$uevents" | grep -qi "PCI_ID=8086:"; then echo "intel";  return; fi
  echo ""
}

detect_gpu_lspci() {
  if ! command -v lspci &>/dev/null; then
    echo ""
    return
  fi
  local gpu_info
  gpu_info=$(lspci | grep -iE "vga|3d|display" || true)
  if [ -z "$gpu_info" ]; then
    echo ""
    return
  fi
  if echo "$gpu_info" | grep -qi "nvidia"; then echo "nvidia"; return; fi
  if echo "$gpu_info" | grep -qi "amd\|radeon"; then echo "amd"; return; fi
  if echo "$gpu_info" | grep -qi "intel"; then echo "intel"; return; fi
  echo ""
}
