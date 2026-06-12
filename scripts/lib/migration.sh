#!/usr/bin/env bash
# migration.sh — Importa valores de configuração NixOS legada
#
# Fontes (em ordem):
#   1. /etc/nixos.bak/configuration.nix (Calamares)
#   2. /etc/nixos/configuration.nix
#
# Apenas preenche campos vazios em CONFIG.
# Usa extração textual simples porque configuration.nix
# é um formato não padronizado e não gerado por nós.

migration_main() {
  print_section "Migração"

  local conf_file=""

  if [ -f "/etc/nixos.bak/configuration.nix" ]; then
    conf_file="/etc/nixos.bak/configuration.nix"
    echo "  Importando configuração do Calamares (/etc/nixos.bak/)..."
  elif [ -f "/etc/nixos/configuration.nix" ]; then
    conf_file="/etc/nixos/configuration.nix"
    echo "  Importando /etc/nixos/configuration.nix existente..."
  fi

  if [ -z "$conf_file" ]; then
    echo "  Nenhuma configuração legada encontrada."
    return
  fi

  if [ -z "${CONFIG[hostname]}" ]; then
    local val
    val=$(extract_nix_string "$conf_file" "networking.hostName")
    [ -n "$val" ] && CONFIG[hostname]="$val"
  fi

  if [ -z "${CONFIG[timezone]}" ]; then
    local val
    val=$(extract_nix_string "$conf_file" "time.timeZone")
    [ -n "$val" ] && CONFIG[timezone]="$val"
  fi

  if [ -z "${CONFIG[locale]}" ]; then
    local val
    val=$(extract_nix_string "$conf_file" "i18n.defaultLocale")
    [ -n "$val" ] && CONFIG[locale]="$val"
  fi

  if [ -z "${CONFIG[keymap]}" ]; then
    local val
    val=$(extract_nix_string "$conf_file" "console.keyMap")
    [ -n "$val" ] && CONFIG[keymap]="$val"
  fi

  if [ -z "${CONFIG[loader]}" ]; then
    if grep -q "boot.loader.systemd-boot.enable = true" "$conf_file" 2>/dev/null; then
      CONFIG[loader]="systemd-boot"
    fi
  fi

  if [ -z "${CONFIG[grubDevice]}" ]; then
    local val
    val=$(extract_nix_string "$conf_file" "boot.loader.grub.device")
    [ -n "$val" ] && CONFIG[grubDevice]="$val"
  fi

  echo "  ✓ Migração concluída"
}
