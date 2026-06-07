# ═══════════════════════════════════════════════════════════════
# WAYLAND — variáveis de ambiente
# ═══════════════════════════════════════════════════════════════
# Variáveis comuns a todas as sessões Wayland.
# ═══════════════════════════════════════════════════════════════
{ ... }:
{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
