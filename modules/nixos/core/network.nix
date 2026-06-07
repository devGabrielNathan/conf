# Configura hostname e NetworkManager via hamra.system.hostname.
{ config, lib, ... }:

let
  cfg = config.hamra;
in
{
  networking.hostName              = lib.mkDefault cfg.system.hostname;
  networking.networkmanager.enable = lib.mkDefault true;
}
