{ self, inputs, ... }:
{
  flake.nixosModules.settings = { config, lib, ... }: {
    options.settings = {
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "Machine's hostname";
      };
      
      users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
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
        });
        description = "Per user config";
      };
    };
  };
}
