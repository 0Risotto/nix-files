# units/services/flatpak.nix — Flatpak support
{ config, lib, ... }:
lib.mkIf config.my.services.flatpak {
  services.flatpak.enable = true;
}
