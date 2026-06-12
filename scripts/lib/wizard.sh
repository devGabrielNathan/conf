#!/usr/bin/env bash
# wizard.sh — Assistente interativo de configuração
#
# Para cada campo de CONFIG que estiver vazio:
#   - Exibe o valor detectado (ou default) como sugestão
#   - Permite ao usuário aceitar (Enter) ou digitar novo valor
#   - Valida entradas quando aplicável
#
# Após o wizard, todos os campos de CONFIG devem estar preenchidos.

wizard_main() {
  print_section "Wizard"
  echo "  Pressione Enter para aceitar o valor sugerido."
  echo ""

  apply_defaults

  local suggested

  suggested="${CONFIG[userName]:-nixos}"
  CONFIG[userName]=$(ask "Nome do usuário" "$suggested")

  suggested="${CONFIG[hostname]:-nixos}"
  CONFIG[hostname]=$(ask "Hostname" "$suggested")

  suggested="${CONFIG[timezone]:-America/Sao_Paulo}"
  CONFIG[timezone]=$(ask "Timezone" "$suggested")

  suggested="${CONFIG[locale]:-pt_BR.UTF-8}"
  CONFIG[locale]=$(ask "Locale" "$suggested")

  suggested="${CONFIG[keymap]:-us}"
  CONFIG[keymap]=$(ask "Keymap (console)" "$suggested")

  suggested="${CONFIG[gpu]:-none}"
  CONFIG[gpu]=$(ask_choice "GPU" "amd|nvidia|intel|none" "$suggested")

  suggested="${CONFIG[loader]:-grub}"
  CONFIG[loader]=$(ask_choice "Bootloader" "grub|systemd-boot" "$suggested")

  if [ "${CONFIG[loader]}" = "grub" ]; then
    suggested="${CONFIG[grubDevice]:-/dev/sda}"
    CONFIG[grubDevice]=$(ask "Dispositivo GRUB (ex: /dev/sda)" "$suggested")
  else
    CONFIG[grubDevice]=""
  fi

  suggested="${CONFIG[session]:-niri}"
  CONFIG[session]=$(ask_choice "Sessão padrão" "niri|hyprland-caelestia|plasma|gnome" "$suggested")
}

apply_defaults() {
  [ -z "${CONFIG[userName]}" ]   && CONFIG[userName]="gabrielnathan"
  [ -z "${CONFIG[hostname]}" ]   && CONFIG[hostname]="nixos"
  [ -z "${CONFIG[timezone]}" ]   && CONFIG[timezone]="America/Sao_Paulo"
  [ -z "${CONFIG[locale]}" ]     && CONFIG[locale]="pt_BR.UTF-8"
  [ -z "${CONFIG[keymap]}" ]     && CONFIG[keymap]="us"
  [ -z "${CONFIG[gpu]}" ]        && CONFIG[gpu]="intel"
  [ -z "${CONFIG[loader]}" ]     && CONFIG[loader]="grub"
  [ -z "${CONFIG[grubDevice]}" ] && CONFIG[grubDevice]="/dev/sda"
  [ -z "${CONFIG[session]}" ]    && CONFIG[session]="hyprland-caelestia"
}
