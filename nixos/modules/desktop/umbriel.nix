{ inputs, ... }:
{
  flake.nixosModules.umbriel =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.umbriel.nixosModules.default ];

      config = lib.mkIf config.settings.umbriel {
        programs.umbriel.enable = true;

        environment.systemPackages = with pkgs; [
          xwayland-satellite
          polkit
        ];
      };
    };
}
