{ self, inputs, ... }:
{
  flake.nixosModules.flatpak = { config, ...}: {
    services.flatpak.enable = true;
  };
}
