# options/desktop.nix — desktop shell choices.
{ lib, ... }:
{
  options.my.desktop = {
    displayManager = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable SDDM display manager with SilentSDDM theme";
    };

    ryoku = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Ryoku desktop with its niri session";
    };
  };
}
