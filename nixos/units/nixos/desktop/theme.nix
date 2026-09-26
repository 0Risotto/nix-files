# units/desktop/theme.nix — fonts, icons, cursors, GTK theme
{ config, pkgs, ... }:
let
  fonts = config.my.constants.theme.fonts;
in
{
  fonts = {
    packages = with pkgs; [
      inter
      roboto
      roboto-mono
      noto-fonts
      noto-fonts-color-emoji
      liberation_ttf
      nerd-fonts.jetbrains-mono
    ];

    fontconfig.defaultFonts = {
      sansSerif = [ fonts.sansSerif ];
      monospace = [ fonts.monospace ];
      serif = [ fonts.serif ];
      emoji = [ fonts.emoji ];
    };
  };

  environment.systemPackages = with pkgs; [
    flat-remix-icon-theme
    bibata-cursors
  ];
}
