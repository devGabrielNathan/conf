# Configura o usuário principal do sistema via hamra.userName.
# Usa mutableUsers para permitir alteração de senha fora do Nix.
{ config, lib, pkgs, ... }:

let
  cfg = config.hamra;
in
{
  users.mutableUsers = lib.mkDefault true;

  # ── Serviços que quero em todas as máquinas ─────────────────
  hardware.bluetooth.enable = true;
  programs.dconf.enable = true;
  programs.direnv.enable = true;
  services.blueman.enable = true;
  services.resolved.enable = true;
  virtualisation.containers.enable = true;
  virtualisation.docker.enable = true;

  programs.zsh.enable = true;

  users.users.${cfg.userName} = {
    isNormalUser    = lib.mkDefault true;
    description     = lib.mkDefault cfg.userName;
    extraGroups     = lib.mkDefault [ "networkmanager" "wheel" "docker" "wireshark" ];
    shell           = pkgs.zsh;
  };
}
