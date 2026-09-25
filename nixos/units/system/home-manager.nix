{ inputs, ... }:
{
  flake.nixosModules.home =
    { config, lib, ... }:
    let
      host = config.my.host;
      primaryUser = host.username;
      primaryCfg = host.users.${primaryUser} or { homeModule = null; };
      extraUsers = lib.filterAttrs (name: _: name != primaryUser) host.users;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";

        users = {
          ${primaryUser} = {
            imports = lib.optional (primaryCfg.homeModule != null) primaryCfg.homeModule ++ [
              ../home/base.nix
            ];
            home = {
              inherit (host) username homeDirectory stateVersion;
            };
            programs.home-manager.enable = true;
          };
        }
        // lib.mapAttrs (name: cfg: {
          imports = lib.optional (cfg.homeModule != null) cfg.homeModule ++ [ ../home/base.nix ];
          home = {
            username = name;
            homeDirectory = "/home/${name}";
            inherit (host) stateVersion;
          };
          programs.home-manager.enable = true;
        }) extraUsers;

        extraSpecialArgs = {
          inherit inputs;
          inherit (config) settings my;
        };
      };
    };
}
