# Configura sudo e polkit base para autenticação do sistema.
# O agente polkit gráfico fica em modules/nixos/desktop/polkit.nix.
{ pkgs, lib, ... }:
{
  # sudo: wheel sem senha de confirmação (opcional — comentar para exigir senha)
  security.sudo.wheelNeedsPassword = lib.mkDefault true;

  # polkit é necessário mesmo sem DE gráfico
  security.polkit.enable = lib.mkDefault true;
}
