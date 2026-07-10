{ inputs, ... }:

{
  flake.nixosModules.display-manager =
    { config, lib, ... }:
    {
      imports = [ inputs.silent-sddm.nixosModules.default ];

      config = lib.mkIf config.settings.displayManager {
        services.displayManager.sddm.enable = true;

        programs.silentSDDM = {
          enable = true;
          theme = "default";
        };
      };
    };
}
