# Configura o bootloader do sistema via hamra.boot.loader e hamra.boot.grub.device.
# Suporta GRUB (BIOS/MBR) e systemd-boot (UEFI).
{ config, lib, ... }:

let
  cfg = config.hamra;
  isGrub = cfg.boot.loader == "grub";
  isSystemdBoot = cfg.boot.loader == "systemd-boot";
in
{
  boot.loader = {
    # GRUB (BIOS / MBR)
    grub = lib.mkIf isGrub {
      enable = true;
      device = lib.mkDefault cfg.boot.grub.device;
      useOSProber = lib.mkDefault true;
      configurationLimit = lib.mkDefault config.hamra.maintenance.gc.maxGenerations;
    };

    # systemd-boot (UEFI)
    systemd-boot = lib.mkIf isSystemdBoot {
      enable = true;
      configurationLimit = lib.mkDefault config.hamra.maintenance.gc.maxGenerations;
      editor = false; # Segurança: bloqueia edição de parâmetros de boot na tela
    };

    efi.canTouchEfiVariables = lib.mkIf isSystemdBoot (lib.mkDefault true);
  };
}
