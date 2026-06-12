#!/usr/bin/env bash
# generator.sh — Gera hosts/main/hamra-config.nix
#
# Escreve os dados coletados em CONFIG como um módulo Nix
# que é importado pelo hamra.nix.

generator_main() {
  print_section "Gerando configuração"

  local target
  target="$(dirname "$HAMRA_TARGET")/hamra-config.nix"

  cat > "$target" <<NIXEOF
# ═══════════════════════════════════════════════════════════════
# HAMRA-CONFIG.NIX — Gerado por scripts/hamra-init.sh
# ═══════════════════════════════════════════════════════════════
# Para regenerar: sudo bash scripts/hamra-init.sh
# ═══════════════════════════════════════════════════════════════
{ lib, ... }:

{
  hamra = {
    userName = "${CONFIG[userName]}";
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
NIXEOF

  echo "  ✓ Gerado: $target"

  # ── Senha (injeção direta no sistema, sem arquivo) ───────────
  if [ -n "${CONFIG[password]}" ] && [ "${CONFIG[password]}" != "__EXISTS__" ]; then
    echo "  Definindo senha para ${CONFIG[userName]}..."
    echo "${CONFIG[userName]}:${CONFIG[password]}" | chpasswd
    echo "  ✓ Senha definida"
  fi

  # Se o PROJECT_DIR difere da origem, copia também
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  local source_dir
  source_dir="$(dirname "$script_dir")"
  if [ "$source_dir" != "$PROJECT_DIR" ]; then
    local target_source="$source_dir/hosts/main/hamra-config.nix"
    cp "$target" "$target_source"
    echo "  ✓ Copiado também para $target_source"
  fi
}
