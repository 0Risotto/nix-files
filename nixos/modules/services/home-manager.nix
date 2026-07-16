{ inputs, ... }:
{
  flake.nixosModules.home =
    { config, lib, ... }:
    let
      primaryUser = config.settings.username;
      primaryCfg = config.settings.users.${primaryUser} or { homeModule = null; };
      extraUsers = lib.filterAttrs (name: _: name != primaryUser) config.settings.users;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";

        users = {
          ${primaryUser} = {
            imports = lib.optional (primaryCfg.homeModule != null) primaryCfg.homeModule ++ [ ../../home.nix ];
            home = {
              username = config.settings.username;
              homeDirectory = config.settings.homeDirectory;
              stateVersion = config.settings.stateVersion;
            };
            programs.home-manager.enable = true;
          };
        }
        // lib.mapAttrs (name: cfg: {
          imports = lib.optional (cfg.homeModule != null) cfg.homeModule ++ [ ../../home.nix ];
          home = {
            username = name;
            homeDirectory = "/home/${name}";
            stateVersion = config.settings.stateVersion;
          };
          programs.home-manager.enable = true;
        }) extraUsers;

        extraSpecialArgs = {
          inherit inputs;
          inherit (config) settings;
        };
      };
    };
}
