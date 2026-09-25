_: {
  flake.nixosModules.nvidia =
    { config, lib, ... }:
    lib.mkIf config.settings.nvidia {
      hardware.graphics.enable32Bit = true;

      services.xserver.videoDrivers = [ "nvidia" ];

      programs.gpu-screen-recorder.enable = true;

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
    };
}
