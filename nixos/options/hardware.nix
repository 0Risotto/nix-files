# options/hardware.nix — hardware capability toggles.
{ config, lib, ... }:
{
  options.my.hardware = {
    audio = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable PipeWire audio (rtkit, ALSA, Pulse, JACK)";
    };

    nvidia = lib.mkOption {
      type = lib.types.bool;
      default = (config.my.host.gpu or { }) ? nvidiaBusId;
      description = "Enable NVIDIA GPU drivers (offload mode for hybrid laptops)";
    };

    kvm = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable KVM virtualization (libvirtd, virt-manager)";
    };
  };
}
