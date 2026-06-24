{ self, inputs, ... }:
{
  flake.nixosModules.niri = { config, pkgs, lib, ... }:
  {
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      xwayland-satellite
      polkit
    ];

  };
}
