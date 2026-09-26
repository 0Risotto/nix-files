# units/home/gaming.nix — gaming applications
# steam and gamemode are provided system-wide by assemblies/gaming.nix.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gamescope
    heroic
    lutris
    pcsx2
    prismlauncher
  ];
}
