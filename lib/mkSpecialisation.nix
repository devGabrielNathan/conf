# Helper para criar specialisations de desktop de forma padronizada.
# Evita copy-paste ao adicionar novos DEs/WMs.
#
# Uso em hosts/main/default.nix:
#
#   let hamraLib = import ../../lib/mkSpecialisation.nix; in
#   specialisation = {
#     hyprland = hamraLib {
#       profile       = ../../profiles/desktop/hyprland.nix;
#       sessionName   = "hyprland";
#       disableSessions = [ "niri" ];
#     };
#   };
#
{ lib }:
{ profile, sessionName, disableSessions ? [] }:
{
  configuration = {
    imports = [ profile ];

    # Ativa a sessão alvo
    hamra.sessions.${sessionName} = lib.mkForce true;
    hamra.defaultSession = lib.mkForce sessionName;

    # Desativa sessões conflitantes
    hamra.sessions = lib.mkMerge (
      map (s: { ${s} = lib.mkForce false; }) disableSessions
    );
  };
}
