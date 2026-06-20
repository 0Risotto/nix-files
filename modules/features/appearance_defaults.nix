
{ self, inputs, ... }:

{
  flake.nixosModules.appearanceDefaults = { config, pkgs, lib, ... }:

  {
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    time.timeZone = "Asia/Amman";

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
        sansSerif = [ "Inter" ];
        monospace = [ "Roboto Mono" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    environment.systemPackages = with pkgs; [
      flat-remix-gtk
      flat-remix-icon-theme
      bibata-cursors 
    ];
    
  };
}

