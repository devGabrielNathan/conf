if ! declare -p CONFIG &>/dev/null 2>&1; then
  declare -A CONFIG
fi

_wiz_val() {
  declare -gA CONFIG
  local label="$1" key="$2" fallback="$3"
  if [ -n "${CONFIG[$key]-}" ]; then
    CONFIG[$key]=$(ask "$label" "${CONFIG[$key]-}")
  else
    CONFIG[$key]=$(ask_required "$label")
    if [ -z "${CONFIG[$key]-}" ]; then
      CONFIG[$key]="$fallback"
    fi
  fi
}

_wiz_choice() {
  declare -gA CONFIG
  local label="$1" key="$2" choices="$3" fallback="$4"
  if [ -n "${CONFIG[$key]-}" ]; then
    CONFIG[$key]=$(ask_choice "$label" "$choices" "${CONFIG[$key]-}")
  else
    CONFIG[$key]=$(ask_choice "$label" "$choices" "$fallback")
  fi
}

wizard_main() {
  declare -gA CONFIG
  if [ "$CONFIG_LOADED" = true ]; then
    if [ "$PASSWORD_EXISTS" != true ]; then
      CONFIG[password]=$(ask_password "Senha do usuário")
    fi
    return
  fi

  _wiz_val  "Nome do usuário (login)"    userName     "nixos"
  _wiz_val  "Nome completo (git)"        fullName     "User"
  _wiz_val  "Email (git)"                email        "user@example.com"
  _wiz_val  "Hostname"                   hostname     "nixos"
  _wiz_val  "Timezone"                   timezone     "America/Sao_Paulo"
  _wiz_val  "Locale"                     locale       "pt_BR.UTF-8"
  _wiz_val  "Keymap"                     keymap       "us"
  _wiz_choice "GPU"                      gpu          "amd|nvidia|intel|none"    "intel"
  _wiz_choice "Bootloader"               loader       "grub|systemd-boot"        "grub"
  if [ "${CONFIG[loader]-}" = "grub" ]; then
    _wiz_val "Dispositivo GRUB"          grubDevice   "/dev/sda"
  fi
  _wiz_choice "Sessão"                   session      "hyprland|plasma|gnome"  "hyprland"

  if [ "$PASSWORD_EXISTS" = true ]; then
    if prompt_yn "Trocar senha existente?"; then
      CONFIG[password]=$(ask_password "Nova senha")
    fi
  else
    log_info "Nenhuma senha detectada — obrigatório definir"
    CONFIG[password]=$(ask_password "Senha do usuário")
  fi
}
