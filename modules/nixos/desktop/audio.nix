# Configura áudio do sistema via PipeWire + WirePlumber.
# PulseAudio é desabilitado explicitamente para evitar conflito.
{ lib, ... }:
{
  services.pulseaudio.enable = lib.mkDefault false;
  security.rtkit.enable      = lib.mkDefault true;

  services.pipewire = {
    enable              = lib.mkDefault true;
    alsa.enable         = lib.mkDefault true;
    alsa.support32Bit   = lib.mkDefault true;
    pulse.enable        = lib.mkDefault true;
    wireplumber.enable  = lib.mkDefault true;
  };

  # Impressão (CUPS)
  services.printing.enable = lib.mkDefault true;

  # Pacotes não-livres habilitados por padrão (Obsidian, Spotify, etc.)
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
