# Configura locale, timezone e configurações regionais do sistema via hamra.system.*.
{ config, lib, ... }:

let
  cfg = config.hamra;
in
{
  time.timeZone      = lib.mkDefault cfg.system.timezone;
  i18n.defaultLocale = lib.mkDefault cfg.system.locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS        = lib.mkDefault cfg.system.locale;
    LC_IDENTIFICATION = lib.mkDefault cfg.system.locale;
    LC_MEASUREMENT    = lib.mkDefault cfg.system.locale;
    LC_MONETARY       = lib.mkDefault cfg.system.locale;
    LC_NAME           = lib.mkDefault cfg.system.locale;
    LC_NUMERIC        = lib.mkDefault cfg.system.locale;
    LC_PAPER          = lib.mkDefault cfg.system.locale;
    LC_TELEPHONE      = lib.mkDefault cfg.system.locale;
    LC_TIME           = lib.mkDefault cfg.system.locale;
  };
}
