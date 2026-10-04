# options/services.nix — optional system services.
{ lib, ... }:
{
  options.my.services = {
    flatpak = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Flatpak support";
    };

    nh = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable nh (Nix CLI helper) with system-level flake vars";
    };

    waydroid = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Waydroid (Android container) with Google Play (GApps) images";
    };

    warp = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Cloudflare WARP (Zero Trust) client daemon";
    };
  };
}
