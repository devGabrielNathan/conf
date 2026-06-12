# Configura o usuário principal do sistema via hamra.userName.
# Usa mutableUsers para permitir alteração de senha fora do Nix.
{ config, lib, pkgs, ... }:

let
  cfg = config.hamra;
in
{
  users.mutableUsers = lib.mkDefault true;

  virtualisation.docker.enable = true;

  programs.wireshark.enable = true;

  programs.zsh.enable = true;

  users.users.${cfg.userName} = {
    isNormalUser    = lib.mkDefault true;
    description     = lib.mkDefault cfg.userName;
    extraGroups     = lib.mkDefault [ "networkmanager" "wheel" "docker" "wireshark" ];
    shell           = pkgs.zsh;
    initialPassword = "nixos";
  };
}
