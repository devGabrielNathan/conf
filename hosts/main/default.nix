{ config, lib, ... }:

let
  inherit (lib) optionalAttrs;
in
{
  imports = [
    ./hardware-configuration.nix
    ./hamra.nix
    ./overrides.nix
    ../../profiles/base.nix
    ../../profiles/desktop/common.nix
    ../../modules/nixos/sessions/hyprland.nix
    ../../modules/nixos/sessions/plasma.nix
    ../../modules/nixos/sessions/gnome.nix
  ];

  home-manager = {
    useUserPackages     = true;
    useGlobalPkgs       = true;
    backupFileExtension = "backup";
    users.${config.hamra.userName} = {
      home = {
        username      = config.hamra.userName;
        homeDirectory = "/home/${config.hamra.userName}";
        stateVersion  = "26.05";
      };
    };
  };

  specialisation = let cfg = config.hamra; in {}
  // optionalAttrs cfg.sessions.hyprland-caelestia {
    hyprland-caelestia.configuration = {
      imports = [ ../../profiles/desktop/hyprland-caelestia.nix ];
    };
  }
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

  assertions = let cfg = config.hamra; in [
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
