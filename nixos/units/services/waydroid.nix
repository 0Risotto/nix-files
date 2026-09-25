# units/services/waydroid.nix — Waydroid Android container with Google Play (GApps).
#
# GPU note: Waydroid hard-rejects the NVIDIA driver (unsupported=["nvidia"] in
# tools/helpers/gpu.py) and falls back to swiftshader software rendering, which
# is extremely laggy. Enable hybrid graphics in the BIOS so the Intel iGPU is
# exposed; Waydroid then auto-selects gralloc=gbm / egl=mesa / vulkan=intel.
#
# Android images are not part of the Nix store. Initialize them once:
#   sudo waydroid-init-gapps
# Then start a session in your compositor with:
#   waydroid session start   (or launch the "Waydroid" app)
# Certify Google Play with:
#   sudo waydroid-register   (prints the Android ID + registration URL)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  initGapps = pkgs.writeShellApplication {
    name = "waydroid-init-gapps";
    runtimeInputs = [ config.virtualisation.waydroid.package ];
    text = ''
      if [ -f /var/lib/waydroid/waydroid.cfg ]; then
        echo "Waydroid is already initialized; nothing to do."
        exit 0
      fi
      waydroid init -s GAPPS
    '';
  };

  register = pkgs.writeShellApplication {
    name = "waydroid-register";
    runtimeInputs = [
      config.virtualisation.waydroid.package
      pkgs.coreutils
    ];
    text = ''
      if [ "$(id -u)" -ne 0 ]; then
        echo "Run this with sudo: sudo waydroid-register"
        exit 1
      fi
      id="$(waydroid shell -- sqlite3 /data/data/com.google.android.gsf/databases/gservices.db \
        "select value from main where name = 'android_id'" 2>/dev/null \
        | tr -d '\\r\\n' || true)"
      if [ -z "$id" ]; then
        echo "Could not read the Android ID."
        echo "Start the Waydroid session, open Google Play once, then retry."
        exit 1
      fi
      echo "Android ID: $id"
      echo "Register it at: https://www.google.com/android/uncertified/"
    '';
  };
in
lib.mkIf config.my.services.waydroid {
  # The default package picks iptables-legacy when both exist, which fails on
  # NixOS' nftables-backed firewall; the nftables variant is the working one.
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  environment.systemPackages = [
    initGapps
    register
  ];
}
