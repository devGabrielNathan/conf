# Configura drivers de GPU via hamra.gpu (amd, nvidia, intel, none).
# Habilita aceleração de hardware Wayland para cada fabricante.
{ config, lib, pkgs, ... }:

let
  cfg = config.hamra;
  gpu = cfg.gpu;
  isAmd    = gpu == "amd";
  isIntel  = gpu == "intel";
  isNvidia = gpu == "nvidia";
  hasGpu   = gpu != "none";
in
{
  # ═══════════════════════════════════════════
  # GRÁFICOS — bloco único para evitar conflito
  # de atributo duplicado entre AMD e Intel
  # ═══════════════════════════════════════════
  hardware.graphics = lib.mkIf hasGpu {
    enable      = true;
    enable32Bit = true;

    # VA-API para Intel (decodificação de vídeo por hardware)
    extraPackages = lib.mkIf isIntel (with pkgs; [
      intel-media-driver
      # intel-vaapi-driver
      # libva-vdpau-driver
      # libvdpau-va-gl
    ]);
  };

  # ═══════════════════════════════════════════
  # AMD — amdgpu
  # ═══════════════════════════════════════════
  hardware.amdgpu = lib.mkIf isAmd {
    opencl.enable = lib.mkDefault true;
    amdvlk.enable = lib.mkDefault false; # Mesa RADV é preferível
  };

  # ═══════════════════════════════════════════
  # NVIDIA — driver proprietário + Wayland
  # ═══════════════════════════════════════════
  hardware.nvidia = lib.mkIf isNvidia {
    modesetting.enable     = true;
    powerManagement.enable = lib.mkDefault false;
    open                   = lib.mkDefault false; # driver proprietário
    nvidiaSettings         = lib.mkDefault true;
    package                = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = lib.mkIf isNvidia [ "nvidia" ];

  # Variáveis de ambiente Wayland para NVIDIA
  environment.sessionVariables = lib.mkIf isNvidia {
    GBM_BACKEND               = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME         = "nvidia";
    NVD_BACKEND               = "direct";
  };

  # Aviso sobre GNOME + NVIDIA (para quando GNOME for suportado)
  assertions = lib.mkIf isNvidia [
    {
      assertion = true; # placeholder — refinar quando GNOME for adicionado
      message   = "hamra: NVIDIA detectado. Se usar GNOME, pode haver problemas de integração. Prefira Hyprland ou Niri.";
    }
  ];
}
