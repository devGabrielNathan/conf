# ═══════════════════════════════════════════════════════════════
# HOST PRINCIPAL — entrypoint da máquina
# ═══════════════════════════════════════════════════════════════
# Sessão ativa é controlada por hamra.nix → hamra.sessions.*
#   Apenas UMA sessão desktop pode estar ativa por vez.
#
# Specialisations disponíveis (use --specialisation <nome>):
#   plasma   → KDE Plasma 6
#   gnome    → GNOME
#   recovery → ambiente mínimo sem DE
#
# Para trocar de sessão:
#   edite hosts/main/hamra.nix → sessions.* e defaultSession
# ═══════════════════════════════════════════════════════════════
{ config, lib, ... }:

let
  inherit (lib) optional optionalAttrs;
  cfg = config.hamra;
in
{
  imports = [
    ./hardware-configuration.nix
    ./hamra.nix
    ./overrides.nix
    ../../profiles/base.nix
  ] ++ optional cfg.sessions.plasma ../../profiles/desktop/plasma.nix
    ++ optional cfg.sessions.gnome ../../profiles/desktop/gnome.nix;

  # ═══════════════════════════════════════════
  # HOME MANAGER
  # ═══════════════════════════════════════════
  home-manager = {
    useUserPackages     = true;
    useGlobalPkgs       = true;
    backupFileExtension = "backup";
    users.${cfg.userName} = {
      home = {
        username      = cfg.userName;
        homeDirectory = "/home/${cfg.userName}";
        stateVersion  = "26.05";
      };
    };
  };

  # ═══════════════════════════════════════════
  # SPECIALISATIONS
  # ═══════════════════════════════════════════
  specialisation = {}
  // optionalAttrs cfg.sessions.plasma {
    plasma.configuration = {
      imports = [ ../../profiles/desktop/plasma.nix ];
    };
  }
  // optionalAttrs cfg.sessions.gnome {
    gnome.configuration = {
      imports = [ ../../profiles/desktop/gnome.nix ];
    };
  }
  // optionalAttrs cfg.sessions.recovery {
    recovery.configuration = {
      imports = [ ../../profiles/recovery.nix ];
    };
  };

  # ═══════════════════════════════════════════
  # ASSERTIONS — segurança contra configuração inválida
  # ═══════════════════════════════════════════
  # Garante que defaultSession corresponde a uma sessão ativa.
  # Se falhar, o Nix aborta o build com a mensagem abaixo.
  assertions = [
    {
      assertion = cfg.sessions.${cfg.defaultSession};
      message = ''
        Hamra: defaultSession ("${cfg.defaultSession}") não está habilitada.

        Edite hosts/main/hamra.nix e corrija:

          sessions.${cfg.defaultSession} = true;
          defaultSession = "${cfg.defaultSession}";
      '';
    }
  ];

  system.stateVersion = "26.05";
}
