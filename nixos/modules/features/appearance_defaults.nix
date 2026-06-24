
{ self, inputs, ... }:

{
  flake.nixosModules.appearanceDefaults = { config, pkgs, ... }:

  {
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = builtins.listToAttrs(map (k: { name = k; value = "en_US.UTF-8"; }) [
      "LC_ADDRESS"
      "LC_IDENTIFICATION" 
      "LC_MEASUREMENT"  
      "LC_MONETARY" 
      "LC_NAME"
      "LC_NUMERIC"
      "LC_PAPER"
      "LC_TELEPHONE"
      "LC_TIME"
    ]);

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
      nwg-look
    ];
    
  };
}

