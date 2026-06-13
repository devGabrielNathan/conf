generate_main() {
  mkdir -p "$(dirname "$HAMRA_CONFIG")"

  cat > "$HAMRA_CONFIG" <<NIX
{ lib, ... }: {
  hamra = {
    userName = "${CONFIG[userName]}";
    full_name = "${CONFIG[fullName]}";
    email_address = "${CONFIG[email]}";
    system = {
      hostname = "${CONFIG[hostname]}";
      timezone = "${CONFIG[timezone]}";
      locale   = "${CONFIG[locale]}";
      keymap   = "${CONFIG[keymap]}";
    };
    gpu = "${CONFIG[gpu]}";
    boot = {
      loader = "${CONFIG[loader]}";
      grub.device = "${CONFIG[grubDevice]}";
    };
    defaultSession = "${CONFIG[session]}";
    sessions.${CONFIG[session]} = true;
  };
}
NIX
  log_ok "Configuração gerada: $HAMRA_CONFIG"

  if [ "$SOURCE_DIR" != "$PROJECT_DIR" ]; then
    local hw_dst="$PROJECT_DIR/hosts/main/hardware-configuration.nix"
    local hw_src="$SOURCE_DIR/hosts/main/hardware-configuration.nix"
    if [ -f "$hw_dst" ]; then
      if [ ! -f "$hw_src" ] || ! diff -q "$hw_dst" "$hw_src" &>/dev/null; then
        mkdir -p "$(dirname "$hw_src")"
        cp "$hw_dst" "$hw_src"
      fi
    fi
    local cfg_src="$SOURCE_DIR/hosts/main/hamra-config.nix"
    mkdir -p "$(dirname "$cfg_src")"
    cp "$HAMRA_CONFIG" "$cfg_src"
  fi

  if command -v git &>/dev/null && git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    git -C "$PROJECT_DIR" add -f "$HAMRA_CONFIG" "$HW_TARGET"
  fi

  if [ -n "${CONFIG[password]}" ] && [ "$PASSWORD_EXISTS" != true ]; then
    if id "${CONFIG[userName]}" &>/dev/null; then
      printf '%s\n%s\n' "${CONFIG[password]}" "${CONFIG[password]}" | passwd "${CONFIG[userName]}"
      log_ok "Senha definida para ${CONFIG[userName]}"
    else
      log_warn "Usuário ${CONFIG[userName]} não existe no sistema atual"
      log_warn "A senha será aplicada ao rodar: nixos-rebuild switch --flake .#main"
    fi
  fi
}
