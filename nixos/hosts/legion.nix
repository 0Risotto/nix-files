# hosts/legion.nix — legion composition: facts + feature flags.
_:
let
  flags = {
    nvidia = true;
    displayManager = true;
    niri = true;
    umbriel = true;
    noctalia = true;
    flatpak = true;
    kvm = true;
    yubikey = true;
  };
in
{
  flake.nixosModules.legion =
    {
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      my.host = import ../constants/hosts/legion.nix;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      settings = flags;
    };

  flake.hostSettings.legion = flags;
}
