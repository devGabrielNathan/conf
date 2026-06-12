#!/usr/bin/env bash
# discovery.sh — Descobre valores de configuração a partir de fontes Nix
#
# Prioridade:
#   1. hosts/main/hamra.json (se existir)
#   2. hosts/main/hamra.nix  (via nix eval)
#   3. nix eval no flake
#   4. Sistema atual (/etc/passwd, timedatectl, localectl)
#   5. Fallback para defaults do módulo de opções
#
# Operações sobre CONFIG — não sobrescreve valores já preenchidos.

discovery_main() {
  print_section "Descoberta"

  local found_any=false

  # ── 1ª fonte: hamra-config.nix existente ─────────────────
  if [ -f "${HAMRA_JSON:-}" ]; then
    echo "  Lendo configuração existente de hamra-config.nix..."
    local val
    val=$(extract_nix_string "$HAMRA_JSON" "userName")
    [ -n "$val" ] && CONFIG[userName]="$val" && found_any=true

    val=$(extract_nix_string "$HAMRA_JSON" "hostname")
    [ -n "$val" ] && CONFIG[hostname]="$val" && found_any=true

    val=$(extract_nix_string "$HAMRA_JSON" "timezone")
    [ -n "$val" ] && CONFIG[timezone]="$val" && found_any=true

    val=$(extract_nix_string "$HAMRA_JSON" "locale")
    [ -n "$val" ] && CONFIG[locale]="$val" && found_any=true

    val=$(extract_nix_string "$HAMRA_JSON" "keymap")
    [ -n "$val" ] && CONFIG[keymap]="$val" && found_any=true

    val=$(extract_nix_string "$HAMRA_JSON" "gpu")
    [ -n "$val" ] && CONFIG[gpu]="$val" && found_any=true

    val=$(extract_nix_string "$HAMRA_JSON" "loader")
    [ -n "$val" ] && CONFIG[loader]="$val" && found_any=true

    val=$(extract_nix_string "$HAMRA_JSON" "grub.device")
    [ -n "$val" ] && CONFIG[grubDevice]="$val" && found_any=true

    val=$(extract_nix_string "$HAMRA_JSON" "defaultSession")
    [ -n "$val" ] && CONFIG[session]="$val" && found_any=true

    if $found_any; then
      echo "  ✓ Configuração restaurada de hamra-config.nix"
      return
    fi
  fi

  # ── 2ª fonte: nix eval no flake ────────────────────────────
  if command -v nix &>/dev/null && [ -f "$PROJECT_DIR/flake.nix" ]; then
    echo "  Tentando nix eval no flake..."
    local eval_target=".#nixosConfigurations.main.config.hamra"
    local result
    result=$(nix eval "$eval_target" --json 2>/dev/null || true)
    if [ -n "$result" ] && [ "$result" != "{}" ]; then
      local tmpfile
      tmpfile=$(mktemp)
      echo "$result" > "$tmpfile"
      local val
      val=$(read_json "userName" "$tmpfile")
      [ -n "$val" ] && CONFIG[userName]="$val"
      val=$(read_json "hostname" "$tmpfile")
      [ -n "$val" ] && CONFIG[hostname]="$val"
      # Timezone, locale, keymap estão aninhados em "system"
      val=$(grep -oP '"system"\s*:\s*\{[^}]*"hostname"\s*:\s*"\K[^"]+' "$tmpfile" 2>/dev/null || true)
      [ -n "$val" ] && CONFIG[hostname]="$val"
      val=$(grep -oP '"system"\s*:\s*\{[^}]*"timezone"\s*:\s*"\K[^"]+' "$tmpfile" 2>/dev/null || true)
      [ -n "$val" ] && CONFIG[timezone]="$val"
      val=$(grep -oP '"system"\s*:\s*\{[^}]*"locale"\s*:\s*"\K[^"]+' "$tmpfile" 2>/dev/null || true)
      [ -n "$val" ] && CONFIG[locale]="$val"
      val=$(grep -oP '"system"\s*:\s*\{[^}]*"keymap"\s*:\s*"\K[^"]+' "$tmpfile" 2>/dev/null || true)
      [ -n "$val" ] && CONFIG[keymap]="$val"
      val=$(read_json "gpu" "$tmpfile")
      [ -n "$val" ] && CONFIG[gpu]="$val"
      val=$(read_json "defaultSession" "$tmpfile")
      [ -n "$val" ] && CONFIG[session]="$val"
      rm -f "$tmpfile"
      echo "  ✓ Valores obtidos do flake"
    fi
  fi

  # ── 3ª fonte: sistema atual ────────────────────────────────
  if [ -z "${CONFIG[userName]}" ]; then
    local user
    user=$(awk -F: '$3 >= 1000 && $1 != "nobody" && $1 != "nfsnobody" {print $1; exit}' /etc/passwd 2>/dev/null || true)
    [ -n "$user" ] && CONFIG[userName]="$user"
  fi

  if [ -z "${CONFIG[timezone]}" ]; then
    local tz
    tz=$(timedatectl show --property=Timezone --value 2>/dev/null || true)
    [ -n "$tz" ] && CONFIG[timezone]="$tz"
  fi

  if [ -z "${CONFIG[locale]}" ]; then
    local loc
    loc=$(localectl show --property=Locale --value 2>/dev/null | head -1 || true)
    [ -z "$loc" ] && loc="${LANG:-}"
    [ -n "$loc" ] && CONFIG[locale]="$loc"
  fi

  if [ -z "${CONFIG[keymap]}" ]; then
    local km
    km=$(localectl show --property=VCKeymap --value 2>/dev/null || true)
    [ -z "$km" ] && km="${KEYMAP:-}"
    [ -n "$km" ] && CONFIG[keymap]="$km"
  fi

  if [ -z "${CONFIG[session]}" ]; then
    local sess
    sess=$(echo "${XDG_SESSION_DESKTOP:-}" | tr '[:upper:]' '[:lower:]' || true)
    case "$sess" in
      hyprland|hyprland-caelestia) CONFIG[session]="hyprland-caelestia" ;;
      plasma|kde|plasmawayland)    CONFIG[session]="plasma" ;;
      gnome|gnome-wayland|gnome-xorg) CONFIG[session]="gnome" ;;
      niri|niri-wlroots)           CONFIG[session]="niri" ;;
    esac
  fi

  # ── 4ª fonte: senha existente em /etc/shadow ──────────────
  if [ -n "${CONFIG[userName]}" ]; then
    local shadow_entry
    shadow_entry=$(grep "^${CONFIG[userName]}:" /etc/shadow 2>/dev/null || true)
    if [ -n "$shadow_entry" ]; then
      local hash
      hash=$(echo "$shadow_entry" | cut -d: -f2)
      if [ -n "$hash" ] && [ "$hash" != "!" ] && [ "$hash" != "*" ] && [ "$hash" != "!!" ]; then
        CONFIG[password]="__EXISTS__"
        echo "  ✓ Senha existente detectada para ${CONFIG[userName]}"
      fi
    fi
  fi

  # ── 5ª fonte: fallbacks do módulo de opções ────────────────
  # (não aplicamos defaults aqui — o wizard pergunta ao usuário)
  # Apenas registramos o que foi descoberto.
  local discovered=()
  [ -n "${CONFIG[userName]}" ] && discovered+=("userName=${CONFIG[userName]}")
  [ -n "${CONFIG[hostname]}" ] && discovered+=("hostname=${CONFIG[hostname]}")
  [ -n "${CONFIG[timezone]}" ] && discovered+=("timezone=${CONFIG[timezone]}")
  [ -n "${CONFIG[locale]}" ]   && discovered+=("locale=${CONFIG[locale]}")
  [ -n "${CONFIG[keymap]}" ]   && discovered+=("keymap=${CONFIG[keymap]}")
  [ -n "${CONFIG[gpu]}" ]      && discovered+=("gpu=${CONFIG[gpu]}")
  [ -n "${CONFIG[loader]}" ]   && discovered+=("loader=${CONFIG[loader]}")
  [ -n "${CONFIG[session]}" ]  && discovered+=("session=${CONFIG[session]}")

  if [ ${#discovered[@]} -gt 0 ]; then
    echo "  ✓ Descoberto: ${discovered[*]}"
  else
    echo "  Nenhuma configuração existente encontrada."
  fi
}
