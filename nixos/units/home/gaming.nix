# units/home/gaming.nix — gaming stack
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    steam
    gamescope
    gamemode
    heroic
    lutris
    pcsx2
    prismlauncher
  ];
}
