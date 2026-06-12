#!/usr/bin/env bash
# generator.sh — Gera hosts/main/hamra.json
#
# Escreve os dados coletados em CONFIG para hamra.json,
# que é consumido pelo hamra.nix em tempo de avaliação.
#
# Não gera código Nix — apenas dados JSON.
# O Nix é responsável por traduzir os dados em configuração.

generator_main() {
  print_section "Gerando configuração"

  mkdir -p "$(dirname "$HAMRA_JSON")"

  cat > "$HAMRA_JSON" <<EOF
{
  "userName": "${CONFIG[userName]}",
  "hostname": "${CONFIG[hostname]}",
  "timezone": "${CONFIG[timezone]}",
  "locale": "${CONFIG[locale]}",
  "keymap": "${CONFIG[keymap]}",
  "gpu": "${CONFIG[gpu]}",
  "loader": "${CONFIG[loader]}",
  "grubDevice": "${CONFIG[grubDevice]}",
  "session": "${CONFIG[session]}"
}
EOF

  echo "  ✓ Gerado: $HAMRA_JSON"
}
