{ config, lib, inputs, ... }:

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
    ../../modules/nixos/sessions/plasma.nix
    ../../modules/nixos/sessions/gnome.nix
    ../../modules/nixos/sessions/hyprland.nix
  ];

  home-manager = {
    useUserPackages     = true;
    useGlobalPkgs       = true;
    backupFileExtension = "backup";
    extraSpecialArgs    = { inherit inputs; };
    users.${config.hamra.userName} = {
      home = {
        username      = config.hamra.userName;
        homeDirectory = "/home/${config.hamra.userName}";
        stateVersion  = "26.05";
      };
    };
  };

  specialisation = let cfg = config.hamra; in {}
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
  // optionalAttrs cfg.sessions.hyprland {
    hyprland.configuration = {
      imports = [ ../../profiles/desktop/hyprland.nix ];
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
