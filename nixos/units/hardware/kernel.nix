# units/hardware/kernel.nix — kernel packages, modules, microcode, zswap
_: {
  flake.nixosModules.kernel =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      boot = {
        kernelPackages = pkgs.linuxPackages_latest;

        initrd.availableKernelModules = config.my.host.boot.initrdAvailableKernelModules;
        kernelModules = config.my.host.boot.kernelModules;
        zswap.enable = config.my.host.boot.zswap;
      };

      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
