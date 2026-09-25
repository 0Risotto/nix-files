# options/system.nix — system-wide behavior knobs.
{ config, lib, ... }:
{
  options.my.system = {
    networking = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable NetworkManager";
    };

    bluetooth = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Bluetooth";
    };

    printing = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable printing (CUPS)";
    };

    sudo = {
      wheelNeedsPassword = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether sudo requires a password for wheel users";
      };
    };

    flakeDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.my.host.homeDirectory}/${config.my.constants.identity.flakeSubpath}";
      description = "Absolute path to this flake (used by nh, fish, ...)";
    };
  };
}
