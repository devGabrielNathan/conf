#!/usr/bin/env bash
# bootstrap.sh — Configura o diretório /etc/nixos
#
# Se o script não estiver rodando de dentro de /etc/nixos,
# faz backup do diretório existente e copia os arquivos do projeto.
#
# Define:
#   PROJECT_DIR — diretório base do projeto
#   HW_TARGET   — caminho para hardware-configuration.nix
#   HAMRA_TARGET — caminho para hamra.nix
#   HAMRA_JSON  — caminho para hamra.json

bootstrap_main() {
  print_section "Bootstrap"

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  local source_dir
  source_dir="$(dirname "$script_dir")"
  local target_dir="/etc/nixos"

  PROJECT_DIR="$source_dir"
  HW_TARGET="$PROJECT_DIR/hosts/main/hardware-configuration.nix"
  HAMRA_TARGET="$PROJECT_DIR/hosts/main/hamra.nix"
  HAMRA_JSON="$PROJECT_DIR/hosts/main/hamra.json"

  if [ "$source_dir" = "$target_dir" ]; then
    echo "  ✓ Executando diretamente de $target_dir"
    return
  fi

  if [ -d "$target_dir" ]; then
    if [ ! -f "$target_dir/flake.nix" ]; then
      echo "  /etc/nixos existente (sem flake.nix). Backup para /etc/nixos.bak..."
      rm -rf /etc/nixos.bak
      mv "$target_dir" /etc/nixos.bak
      echo "  ✓ Backup concluído em /etc/nixos.bak"
    else
      echo "  /etc/nixos já contém uma configuração baseada em flakes."
      local confirm
      confirm=$(ask "Deseja sobrescrever /etc/nixos com os arquivos do Hamra?" "s")
      if [ "$confirm" = "s" ] || [ "$confirm" = "S" ]; then
        echo "  Backup da configuração antiga para /etc/nixos.old..."
        rm -rf /etc/nixos.old
        mv "$target_dir" /etc/nixos.old
      else
        echo "  Usando diretório atual como base do projeto."
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
  HAMRA_JSON="$PROJECT_DIR/hosts/main/hamra.json"

  echo "  ✓ Arquivos copiados para $PROJECT_DIR"
}
