{ self, inputs, ... }:
{
  flake.nixosModules.legionHardware =
    { config, lib, pkgs, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];

      boot.initrd.kernelModules = [ ];

      boot.kernelModules = [
        "kvm-intel"
      ];

      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
        fsType = "btrfs";
      };

      fileSystems."/home" = {
        device = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
        fsType = "btrfs";
        options = [
          "subvol=home"
        ];
      };

      fileSystems."/nix" = {
        device = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
        fsType = "btrfs";
        options = [
          "subvol=nix"
        ];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/5AA0-1761";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      hardware.cpu.intel.updateMicrocode =
        lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
