# hosts/legion.nix
_:
let
  hostSettings = {
    hostname = "legion";
    username = "legion";
    timezone = "Asia/Amman";
    stateVersion = "26.05";
    nvidia = true;
    displayManager = true;
    niri = true;
    noctalia = true;
    flatpak = true;
    kvm = true;
    yubikey = true;
    efi.secureBoot = true;
  };
in
{
  flake.nixosModules.legion =
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
        kernelModules = [ "kvm-intel" ];
        zswap.enable = true;
      };
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
          fsType = "btrfs";
        };
        "/home" = {
          device = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
          fsType = "btrfs";
          options = [ "subvol=home" ];
        };
        "/nix" = {
          device = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
          fsType = "btrfs";
          options = [ "subvol=nix" ];
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

      swapDevices = [
        {
          device = "/swapfile";
          size = 8192;
        }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      settings = hostSettings;
    };

  flake.hostSettings.legion = hostSettings;
}
