{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nautilus
    vicinae
    wl-clipboard
    grim
    slurp
  ];
}
