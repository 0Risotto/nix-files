# hosts/legion.nix — legion facts + machine-level modules.
# Composition (assemblies) lives in constants/hosts/legion.nix.
{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  my.host = import ../constants/hosts/legion.nix;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
