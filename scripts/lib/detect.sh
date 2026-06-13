detect_main() {
  read_existing_config
  read_flake_config
  read_legacy_config
  read_system_state
  read_password_state
  detect_gpu_hardware
  _detect_hardware
}

read_existing_config() {
  if [ ! -f "$HAMRA_CONFIG" ]; then return; fi
  if head -5 "$HAMRA_CONFIG" 2>/dev/null | grep -q 'Gerado/sobrescrito por'; then
    log_info "hamra-config.nix é template — valores serão detectados do sistema"
    return
  fi
  log_info "Lendo hamra-config.nix existente"
  local found=false
  for key in "userName" "full_name" "email_address" "hostname" "timezone" "locale" "keymap" "gpu" "loader" "defaultSession"; do
    local val
    val=$(nix_read "$HAMRA_CONFIG" "$key")
    if [ -z "$val" ]; then continue; fi
    case "$key" in
      defaultSession) CONFIG[session]="$val" ;;
      full_name)      CONFIG[fullName]="$val" ;;
      email_address)  CONFIG[email]="$val" ;;
      *)              CONFIG[$key]="$val" ;;
    esac
    found=true
  done
  local grub_val
  grub_val=$(nix_read "$HAMRA_CONFIG" "grub.device")
  if [ -n "$grub_val" ]; then CONFIG[grubDevice]="$grub_val" && found=true; fi
  if $found; then CONFIG_LOADED=true; log_ok "Configuração restaurada"; else log_warn "hamra-config.nix vazio"; fi
}

read_flake_config() {
  if [ -n "${CONFIG[hostname]}" ] && [ -n "${CONFIG[timezone]}" ] && [ -n "${CONFIG[locale]}" ]; then return; fi
  if ! command -v nix &>/dev/null; then return; fi
  if [ ! -f "$PROJECT_DIR/flake.nix" ]; then return; fi
  log_info "Avaliando flake com nix eval"
  local hamra_json
  hamra_json=$(nix eval ".#nixosConfigurations.main.config.hamra" --json 2>/dev/null || true)
  if [ -z "$hamra_json" ]; then return; fi
  local tmp
  tmp=$(mktemp)
  echo "$hamra_json" > "$tmp"
  if [ -z "${CONFIG[hostname]}" ];     then CONFIG[hostname]=$(jq -r '.system.hostname // empty' "$tmp" 2>/dev/null || true); fi
  if [ -z "${CONFIG[timezone]}" ];     then CONFIG[timezone]=$(jq -r '.system.timezone // empty' "$tmp" 2>/dev/null || true); fi
  if [ -z "${CONFIG[locale]}" ];       then CONFIG[locale]=$(jq -r '.system.locale // empty' "$tmp" 2>/dev/null || true); fi
  if [ -z "${CONFIG[session]}" ];      then CONFIG[session]=$(jq -r '.defaultSession // empty' "$tmp" 2>/dev/null || true); fi
  rm -f "$tmp"
}

read_legacy_config() {
  if [ -n "${CONFIG[hostname]}" ] && [ -n "${CONFIG[timezone]}" ] && [ -n "${CONFIG[locale]}" ]; then return; fi
  local conf
  if [ -f "/etc/nixos.bak/configuration.nix" ]; then conf="/etc/nixos.bak/configuration.nix"
  elif [ -f "/etc/nixos/configuration.nix" ];     then conf="/etc/nixos/configuration.nix"
  else return
  fi
  local found=false
  if [ -z "${CONFIG[hostname]}" ] && val=$(nix_read "$conf" "networking.hostName") && [ -n "$val" ]; then CONFIG[hostname]="$val"; found=true; fi
  if [ -z "${CONFIG[timezone]}" ] && val=$(nix_read "$conf" "time.timeZone") && [ -n "$val" ]; then CONFIG[timezone]="$val"; found=true; fi
  if [ -z "${CONFIG[locale]}" ] && val=$(nix_read "$conf" "i18n.defaultLocale") && [ -n "$val" ]; then CONFIG[locale]="$val"; found=true; fi
  if [ -z "${CONFIG[keymap]}" ] && val=$(nix_read "$conf" "console.keyMap") && [ -n "$val" ]; then CONFIG[keymap]="$val"; found=true; fi
  if [ -z "${CONFIG[grubDevice]}" ] && val=$(nix_read "$conf" "boot.loader.grub.device") && [ -n "$val" ]; then CONFIG[grubDevice]="$val"; found=true; fi
  if [ -z "${CONFIG[loader]}" ] && grep -q "boot.loader.systemd-boot.enable = true" "$conf" 2>/dev/null; then CONFIG[loader]="systemd-boot"; found=true; fi
  if $found; then log_info "Importada configuração legada"; fi
}

read_password_state() {
  local user="${CONFIG[userName]}"
  if [ -z "$user" ]; then log_warn "Nenhum usuário para verificar senha"; return; fi
  local hash
  hash=$(grep "^$user:" /etc/shadow 2>/dev/null | cut -d: -f2 || true)
  if [ -z "$hash" ]; then
    log_info "Usuário $user sem entrada em /etc/shadow"
  elif [ "$hash" = "!" ] || [ "$hash" = "*" ] || [ "$hash" = "!!" ]; then
    log_info "Usuário $user com senha bloqueada ($hash)"
  else
    PASSWORD_EXISTS=true
    log_info "Senha existente detectada para $user"
  fi
}

read_system_state() {
  if [ -z "${CONFIG[userName]}" ]; then
    CONFIG[userName]=$(awk -F: '$3>=1000 && $1!="nobody"{print $1;exit}' /etc/passwd 2>/dev/null || true)
  fi
  if [ -z "${CONFIG[userName]}" ] && command -v whoami &>/dev/null; then
    CONFIG[userName]=$(whoami)
  fi
  if [ -n "${CONFIG[userName]}" ]; then
    log_info "Usuário detectado: ${CONFIG[userName]}"
  fi
  if [ -z "${CONFIG[timezone]}" ]; then
    CONFIG[timezone]=$(timedatectl show --property=Timezone --value 2>/dev/null || true)
  fi
  if [ -z "${CONFIG[locale]}" ]; then
    CONFIG[locale]=$(localectl show --property=Locale --value 2>/dev/null | head -1 || echo "${LANG:-}")
  fi
  if [ -z "${CONFIG[keymap]}" ]; then
    CONFIG[keymap]=$(localectl show --property=VCKeymap --value 2>/dev/null || true)
  fi
  if [ -z "${CONFIG[keymap]}" ]; then
    CONFIG[keymap]=$(localectl show --property=X11Layout --value 2>/dev/null || true)
  fi
  if [ -z "${CONFIG[keymap]}" ]; then
    CONFIG[keymap]="${KEYMAP:-}"
  fi
  if [ -z "${CONFIG[keymap]}" ] && [ -f /etc/vconsole.conf ]; then
    CONFIG[keymap]=$(grep -oP 'KEYMAP="?\K[^" ]+' /etc/vconsole.conf 2>/dev/null || true)
  fi
  if [ -z "${CONFIG[session]}" ]; then
    case "$(echo "${XDG_SESSION_DESKTOP:-}" | tr '[:upper:]' '[:lower:]')" in
      hyprland*|Hyprland*) CONFIG[session]="hyprland" ;;
      plasma*|kde*)        CONFIG[session]="plasma" ;;
      gnome*)              CONFIG[session]="gnome" ;;
    esac
  fi
}

detect_gpu_hardware() {
  if [ -n "${CONFIG[gpu]}" ]; then return; fi
  local gpu
  gpu=$(detect_gpu_pci_sysfs)
  if [ -z "$gpu" ]; then gpu=$(detect_gpu_drm); fi
  if [ -z "$gpu" ]; then gpu=$(detect_gpu_lspci); fi
  if [ -n "$gpu" ]; then CONFIG[gpu]="$gpu"; log_ok "GPU detectada: $gpu"; fi
}

detect_gpu_pci_sysfs() {
  for dev in /sys/bus/pci/devices/*; do
    local class vendor
    class=$(cat "$dev/class" 2>/dev/null || true)
    vendor=$(cat "$dev/vendor" 2>/dev/null || true)
    if [[ ! "$class" =~ ^0x03 ]]; then continue; fi
    case "${vendor#0x}" in 10de*) echo "nvidia"; return;; 1002*) echo "amd"; return;; 8086*) echo "intel"; return;; esac
  done; echo ""
}

detect_gpu_drm() {
  if [ ! -d /sys/class/drm ]; then echo ""; return; fi
  local ue
  ue=$(cat /sys/class/drm/card*/device/uevent 2>/dev/null || true)
  if echo "$ue" | grep -qi "PCI_ID=10de:"; then echo "nvidia"; return; fi
  if echo "$ue" | grep -qi "PCI_ID=1002:"; then echo "amd";   return; fi
  if echo "$ue" | grep -qi "PCI_ID=8086:"; then echo "intel"; return; fi
  echo ""
}

detect_gpu_lspci() {
  if ! command -v lspci &>/dev/null; then echo ""; return; fi
  local info
  info=$(lspci | grep -iE "vga|3d|display" || true)
  if echo "$info" | grep -qi "nvidia";    then echo "nvidia"; return; fi
  if echo "$info" | grep -qi "amd\|radeon"; then echo "amd";   return; fi
  if echo "$info" | grep -qi "intel";     then echo "intel"; return; fi
  echo ""
}

ensure_hardware_config() {
  if [ -f "$HW_TARGET" ] && grep -q 'fileSystems' "$HW_TARGET" 2>/dev/null; then return; fi

  for src in \
    "/etc/nixos.bak/hardware-configuration.nix" \
    "/etc/nixos.bak/hosts/main/hardware-configuration.nix" \
    "/etc/nixos.old/hardware-configuration.nix" \
    "/etc/nixos.old/hosts/main/hardware-configuration.nix"; do
    if [ -f "$src" ] && grep -q 'fileSystems' "$src" 2>/dev/null; then
      cp "$src" "$HW_TARGET"
      ok "Restaurado hardware-config de $(basename "$(dirname "$(dirname "$src")")")"
      return
    fi
  done

  if ! command -v nixos-generate-config &>/dev/null; then
    err "nixos-generate-config nao encontrado"
    return 1
  fi
  nixos-generate-config --show-hardware-config > "$HW_TARGET" 2>/dev/null
  if grep -q 'fileSystems' "$HW_TARGET" 2>/dev/null; then return; fi

  err "Nao foi possível obter um hardware-configuration.nix valido"
  err "Crie manualmente: nixos-generate-config --show-hardware-config > $HW_TARGET"
  return 1
}

_detect_hardware() {
  if ensure_hardware_config; then return; fi
  err "hardware-configuration.nix invalido ou ausente — abortando"
  exit 1
}
