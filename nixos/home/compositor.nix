{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ]
  ++ (with pkgs; [
    kitty
    nautilus
    vicinae
    wl-clipboard
    grim
    slurp
  ]);

}
