setup_main() {
  local target_dir="/etc/nixos"
  PROJECT_DIR="$SOURCE_DIR"
  HW_TARGET="$PROJECT_DIR/hosts/main/hardware-configuration.nix"
  HAMRA_CONFIG="$PROJECT_DIR/hosts/main/hamra-config.nix"

  if [ "$SOURCE_DIR" = "$target_dir" ]; then
    log_ok "Executando de $target_dir"
  elif [ -d "$target_dir" ] && [ -f "$target_dir/flake.nix" ]; then
    log_info "/etc/nixos já contém um flake"
    if [ "$(ask "Sobrescrever?" "s")" = "s" ]; then
      rm -rf /etc/nixos.old
      mv "$target_dir" /etc/nixos.old
      log_info "Backup em /etc/nixos.old"
      mkdir -p "$target_dir"
      cp -r "$SOURCE_DIR"/. "$target_dir"/
      PROJECT_DIR="$target_dir"
      HW_TARGET="$PROJECT_DIR/hosts/main/hardware-configuration.nix"
      HAMRA_CONFIG="$PROJECT_DIR/hosts/main/hamra-config.nix"
      log_ok "Arquivos copiados para $target_dir"
    fi
  else
    if [ -d "$target_dir" ]; then
      rm -rf /etc/nixos.bak
      mv "$target_dir" /etc/nixos.bak
      log_info "Backup em /etc/nixos.bak"
    fi
    mkdir -p "$target_dir"
    cp -r "$SOURCE_DIR"/. "$target_dir"/
    PROJECT_DIR="$target_dir"
    HW_TARGET="$PROJECT_DIR/hosts/main/hardware-configuration.nix"
    HAMRA_CONFIG="$PROJECT_DIR/hosts/main/hamra-config.nix"
    log_ok "Arquivos copiados para $target_dir"
  fi

  if command -v git &>/dev/null; then
    if git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
      git -C "$PROJECT_DIR" add -A
    else
      git -C "$PROJECT_DIR" init --quiet
      git -C "$PROJECT_DIR" add -A
    fi
    log_ok "Git pronto"
  fi
}
