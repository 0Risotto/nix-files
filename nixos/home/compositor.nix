{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
    nautilus
    vicinae
    wl-clipboard
    grim
    slurp
  ];
}
