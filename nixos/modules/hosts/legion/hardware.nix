_: {
  flake.nixosModules.legionHardware =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        initrd.availableKernelModules = [
          "xhci_pci"
          "thunderbolt"
          "ahci"
          "nvme"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];

        initrd.kernelModules = [ ];

        kernelModules = [
          "kvm-intel"
        ];

        extraModulePackages = [ ];
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
          fsType = "btrfs";
        };

        "/home" = {
          device = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
          fsType = "btrfs";
          options = [
            "subvol=home"
          ];
        };

        "/nix" = {
          device = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
          fsType = "btrfs";
          options = [
            "subvol=nix"
          ];
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/5AA0-1761";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };
      };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
