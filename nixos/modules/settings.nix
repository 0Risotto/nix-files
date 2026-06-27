_: {
  flake.nixosModules.settings = { lib, ... }: {
    options.settings = {
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "Machine's hostname";
      };

      efi = lib.mkOption {
        type = lib.types.submodule {
          options = {
            secureBoot = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to use Secure Boot with Lanzaboote (requires enrolling keys)";
            };
            canTouchEfiVariables = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to allow the bootloader to modify EFI variables";
            };
          };
        };
        default = { };
        description = "EFI-related settings";
      };

      users = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              isAdmin = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether user gets wheel + networkmanager groups";
              };
              homeModule = lib.mkOption {
                type = lib.types.path;
                description = "Path to user's home-manager config";
              };
            };
          }
        );
        description = "Per user config";
      };
    };
  };
}
