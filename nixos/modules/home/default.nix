{ self, inputs, ... }:
{
  flake.nixosModules.home = { config, pkgs, lib, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      
      users = lib.mapAttrs (name: cfg: { config, pkgs, lib, ... }: {
        imports = [ cfg.homeModule ];
        home.username = name;
        home.homeDirectory = "/home/${name}";
        home.stateVersion = "26.05";
        programs.home-manager.enable = true;
      }) config.settings.users;

      extraSpecialArgs = { inherit inputs; settings = config.settings; };
    };
  };
}
