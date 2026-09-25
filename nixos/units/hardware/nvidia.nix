# units/hardware/nvidia.nix — NVIDIA drivers, PRIME offload
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.my.hardware.nvidia {
  hardware.graphics.enable32Bit = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  programs.gpu-screen-recorder = {
    enable = true;
    # Nixpkgs' ffmpeg 9 requires NVENC API 13.1; the 595.99 driver exposes
    # 13.0. Use ffmpeg 8 so nvenc works instead of falling back to CPU.
    package = pkgs.gpu-screen-recorder.override { ffmpeg = pkgs.ffmpeg_8; };
  };

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;

    prime = {
      sync.enable = true;
      inherit (config.my.host.gpu) nvidiaBusId intelBusId;
    };

    nvidiaSettings = true;
    powerManagement.enable = false;
  };

  environment.sessionVariables = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
  };
}
