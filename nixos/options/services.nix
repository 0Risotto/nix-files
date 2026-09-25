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

    yubikey = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable YubiKey support (pcscd, udev rules, GPG agent, ykman)";
    };
  };
}
