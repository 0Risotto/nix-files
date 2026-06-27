{ inputs, ... }:
{
  flake.nixosModules.efi =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (config.settings.efi) secureBoot canTouchEfiVariables;
    in
    {
      # Import unconditionally, use mkIf to control effects
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      environment.systemPackages =
        with pkgs;
        lib.optionals secureBoot [
          sbctl
        ];

      boot = {
        loader.systemd-boot.enable = lib.mkIf (!secureBoot) true;
        loader.efi.canTouchEfiVariables = lib.mkIf (!secureBoot) canTouchEfiVariables;

        lanzaboote = lib.mkIf secureBoot {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };
      };
    };
}
