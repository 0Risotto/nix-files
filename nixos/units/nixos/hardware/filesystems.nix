# units/hardware/filesystems.nix — disks and swap from host facts
{ config, lib, ... }:
let
  disks = config.my.host.disks;
in
{
  fileSystems = {
    "/" = {
      device = disks.root;
      fsType = "btrfs";
    };
    "/home" = {
      device = disks.root;
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };
    "/nix" = {
      device = disks.root;
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };
    "/boot" = {
      device = disks.boot;
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = lib.optional (config.my.host.swap != null) config.my.host.swap;
}
