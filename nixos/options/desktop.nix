# options/desktop.nix — desktop shell choices.
{ config, lib, ... }:
{
  options.my.desktop = {
    compositors = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "niri"
          "umbriel"
        ]
      );
      default = config.my.host.compositors or [ ];
      description = "Wayland compositors to install and configure";
    };

    displayManager = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable SDDM display manager with SilentSDDM theme";
    };

    noctalia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Noctalia bar/launcher and cachix cache";
    };
  };
}
