# units/hardware/intel.nix — Intel iGPU VAAPI support
# Needed for hardware encode/decode on the iGPU (e.g. portal screen capture
# hands Intel buffers to gpu-screen-recorder, which then queries VAAPI).
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf (config.my.host.gpu.intelBusId != null) {
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
}
