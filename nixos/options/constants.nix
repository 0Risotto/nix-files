# options/constants.nix — injection points for immutable data.
{ lib, ... }:
{
  options.my = {
    constants = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = import ../constants/shared.nix;
      description = "Host-independent constants shared by all machines";
    };

    host = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Per-host facts, set by hosts/<name>.nix";
    };
  };
}
