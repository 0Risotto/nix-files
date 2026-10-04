# units/home/desktop-apps.nix — workbench apps for the desktop session
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nautilus
    vicinae
    wl-clipboard
    grim
    slurp
    hyprpicker
    zbar

    # Communication
    signal-desktop
    (discord.override {
      withVencord = true;
    })
  ];
}
