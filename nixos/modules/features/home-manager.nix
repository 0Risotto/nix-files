{ inputs, ... }:
{
  flake.nixosModules.home = { config, lib, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users = lib.mapAttrs (name: cfg: { ... }: {
        imports = [ cfg.homeModule ];
        home = {
          username = name;
          homeDirectory = "/home/legion/git/dotties/home/${name}";
          stateVersion = config.settings.stateVersion;
        };
        programs.home-manager.enable = true;
      }) config.settings.users;

      extraSpecialArgs = {
        inherit inputs;
        inherit (config) settings;
      };
    };
  };
}
