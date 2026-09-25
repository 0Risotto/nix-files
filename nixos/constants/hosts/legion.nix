# constants/hosts/legion.nix — facts for the legion machine.
# Pure data: no config, no lib, no pkgs, no module imports.
{
  hostname = "legion";
  username = "legion";
  homeDirectory = "/home/legion";
  timezone = "Asia/Amman";
  locale = "en_US.UTF-8";
  stateVersion = "26.05";

  users = { };

  # Assemblies this host composes (resolved against assemblies/<name>.nix).
  assemblies = [
    "desktop"
    "development"
    "gaming"
    "media"
    "virtualization"
  ];

  boot = {
    initrdAvailableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
    zswap = true;
  };

  swap = {
    device = "/swapfile";
    size = 8192;
  };

  disks = {
    root = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
    boot = "/dev/disk/by-uuid/5AA0-1761";
  };

  monitors = {
    "HDMI-A-1" = {
      mode = "1920x1080@200";
      position = {
        x = 0;
        y = 0;
      };
      workspaces = [
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
      ];
    };
    "eDP-1" = {
      position = {
        x = 1920;
        y = 0;
      };
      workspaces = [ "10" ];
    };
  };

  gpu = {
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:0:0";
  };

  efi = {
    secureBoot = true;
    canTouchEfiVariables = true;
  };
}
