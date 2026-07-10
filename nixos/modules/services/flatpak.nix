_: {
  flake.nixosModules.flatpak =
    { config, lib, ... }:
    lib.mkIf config.settings.flatpak {
      services.flatpak.enable = true;
    };
}
