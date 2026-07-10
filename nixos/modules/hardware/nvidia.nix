_: {
  flake.nixosModules.nvidia =
    { config, lib, ... }:
    lib.mkIf config.settings.nvidia {
      hardware.graphics.enable32Bit = true;

      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        open = true;
        modesetting.enable = true;
        package = config.boot.kernelPackages.nvidiaPackages.production;

        prime = {
          sync.enable = true;
          nvidiaBusId = "PCI:1:0:0";
          intelBusId = "PCI:0:0:0";
        };

        nvidiaSettings = true;
        powerManagement.enable = true;
      };

      environment.sessionVariables = {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
      };
    };
}
