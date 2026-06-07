# Configura o display manager SDDM com o tema pixie-sddm e sessão padrão.
{ pkgs, config, lib, ... }:

let
  pixie-sddm = pkgs.stdenv.mkDerivation {
    name = "pixie-sddm";
    src = pkgs.fetchFromGitHub {
      owner = "xCaptaiN09";
      repo = "pixie-sddm";
      rev = "730072544f3785c43eb05674c334a7d0fb07681b";
      sha256 = "1ma7y9nibyvaa6hsfsdrijhw6df0av635gf5c03wszf9qrgxdw6l";
    };
    installPhase = ''
      mkdir -p $out/share/sddm/themes/pixie
      cp -aR * $out/share/sddm/themes/pixie
    '';
  };
in
{
  services.displayManager.sddm = {
    enable          = true;
    wayland.enable  = true;
    theme           = "pixie";
    extraPackages   = [
      pixie-sddm
      pkgs.kdePackages.qtsvg
      pkgs.kdePackages.qt5compat
    ];
  };

  services.displayManager.defaultSession =
    lib.mkDefault config.hamra.defaultSession;

  environment.systemPackages = [
    pixie-sddm
  ];
}
