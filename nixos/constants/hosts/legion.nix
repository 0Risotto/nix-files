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
    "vpn"
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
    # zram (swap.zramPercent) supersedes zswap as the compressed-swap tier.
    zswap = false;
  };

  swap = {
    device = "/swapfile";
    size = 8192;
    zramPercent = 30;
  };

  disks = {
    root = "/dev/disk/by-uuid/6ca0d3c8-df36-4776-9c33-458b4cac1ebb";
    boot = "/dev/disk/by-uuid/5AA0-1761";
  };

  gpu = {
    nvidiaBusId = "PCI:1:0:0";
    # Intel UHD iGPU (i5-11400H), exposed only when BIOS uses hybrid graphics.
    intelBusId = "PCI:0:2:0";
  };

  displays = {
    primary = "HDMI-A-1";
    secondary = "eDP-1";
  };

  efi = {
    secureBoot = true;
    canTouchEfiVariables = true;
  };
}
